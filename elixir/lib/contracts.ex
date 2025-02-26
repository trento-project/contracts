defmodule Trento.Contracts do
  @moduledoc """
  This facade contains functions to eoncode/decode events to/from protobuf
  """

  require Logger

  @default_expiration_window_minutes 5

  @doc """
  Return the content type of contracts
  """
  def content_type, do: "application/x-protobuf"

  @doc """
  Encode and wrap an event struct to a protobuf CloudEvent.
  """
  @spec to_event(struct(), Keyword.t()) :: binary()
  def to_event(%mod{} = struct, opts \\ []) do
    id = Keyword.get(opts, :id, UUID.uuid4())
    source = Keyword.get(opts, :source, "https://github.com/trento-project")

    time =
      Keyword.get(
        opts,
        :time,
        DateTime.utc_now()
      )

    expiration =
      Keyword.get(
        opts,
        :expiration,
        DateTime.add(time, @default_expiration_window_minutes, :minute)
      )

    time_attr = %Google.Protobuf.Timestamp{seconds: time |> DateTime.to_unix()}
    expiration_attr = %Google.Protobuf.Timestamp{seconds: expiration |> DateTime.to_unix()}

    data = Protobuf.Encoder.encode(struct)

    cloud_event = %CloudEvents.CloudEvent{
      data: {:proto_data, %Google.Protobuf.Any{value: data, type_url: get_type(mod)}},
      spec_version: "1.0",
      type: get_type(mod),
      id: id,
      attributes: %{
        "time" => %CloudEvents.CloudEventAttributeValue{attr: {:ce_timestamp, time_attr}},
        "expiration" => %CloudEvents.CloudEventAttributeValue{
          attr: {:ce_timestamp, expiration_attr}
        }
      },
      source: source
    }

    CloudEvents.CloudEvent.encode(cloud_event)
  end

  @doc """
  Decode and unwrap a protobuf CloudEvent to an event struct.
  """
  @spec from_event(binary()) ::
          {:ok, struct()}
          | {:error, :decoding_error}
          | {:error, :invalid_envelope}
          | {:error, :event_not_found}
  def from_event(value) do
    try do
      case decode_and_validate(value) do
        {:ok, event} ->
          {:ok, event}

        {:error, reason} ->
          Logger.error("Invalid trento event: #{inspect(reason)}")

          {:error, reason}
      end
    rescue
      error ->
        Logger.error("Decoding error: #{inspect(error)}")

        {:error, :decoding_error}
    end
  end

  defp decode_and_validate(value) do
    with {:ok, event_type, attributes, event_data} <- extract_event(value),
         {:ok, decoded_event} <- decode_trento_event(event_type, event_data),
         {:ok, _} <- validate_event_expiration(attributes) do
      {:ok, decoded_event}
    end
  end

  defp extract_event(value) do
    case CloudEvents.CloudEvent.decode(value) do
      %{
        type: event_type,
        attributes: attributes,
        data: {:proto_data, %Google.Protobuf.Any{value: event_data}}
      } ->
        {:ok, event_type, attributes, event_data}

      invalid_event ->
        Logger.error("Invalid cloud event: #{inspect(invalid_event)}")
        {:error, :invalid_envelope}
    end
  end

  defp decode_trento_event(type, data) do
    try do
      module_name = Macro.camelize(type)
      module = Module.safe_concat([module_name])

      {:ok, module.decode(data)}
    rescue
      ArgumentError -> {:error, :unknown_event}
    end
  end

  defp get_type(mod) do
    mod
    |> Atom.to_string()
    |> String.replace("Elixir.", "")
  end

  defp validate_event_expiration(%{
         "expiration" => %CloudEvents.CloudEventAttributeValue{
           attr: {:ce_timestamp, %Google.Protobuf.Timestamp{seconds: unix_expiration}}
         }
       }) do
    expiration = DateTime.from_unix!(unix_expiration)

    if DateTime.after?(expiration, DateTime.utc_now()) do
      {:ok, expiration}
    else
      {:error, :event_expired}
    end
  end

  defp validate_event_expiration(_) do
    {:error, :expiration_attribute_not_found}
  end
end
