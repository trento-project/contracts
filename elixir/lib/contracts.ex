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

    additional_attributes = Keyword.get(opts, :additional_attributes, %{})

    time_attr = %Google.Protobuf.Timestamp{seconds: time |> DateTime.to_unix()}
    expiration_attr = %Google.Protobuf.Timestamp{seconds: expiration |> DateTime.to_unix()}

    default_attributes = %{
      "time" => %CloudEvents.CloudEventAttributeValue{attr: {:ce_timestamp, time_attr}},
      "expiration" => %CloudEvents.CloudEventAttributeValue{
        attr: {:ce_timestamp, expiration_attr}
      }
    }

    data = Protobuf.Encoder.encode(struct)

    cloud_event = %CloudEvents.CloudEvent{
      data: {:proto_data, %Google.Protobuf.Any{value: data, type_url: get_type(mod)}},
      spec_version: "1.0",
      type: get_type(mod),
      id: id,
      attributes:
        Map.merge(
          default_attributes,
          encode_additional_attributes(additional_attributes)
        ),
      source: source
    }

    CloudEvents.CloudEvent.encode(cloud_event)
  end

  @doc """
  Decode and unwrap a protobuf CloudEvent to an event struct.
  """
  @spec from_event(binary(), Keyword.t()) ::
          {:ok, struct()}
          | {:error, :decoding_error}
          | {:error, :invalid_envelope}
          | {:error, :unknown_event}
  def from_event(value, opts \\ []) do
    validate_expiration =
      Keyword.get(
        opts,
        :validate_expiration,
        false
      )

    case decode_and_validate(value, validate_expiration) do
      {:ok, event} ->
        {:ok, event}

      {:error, reason} ->
        Logger.error("Invalid trento event: #{inspect(reason)}")

        {:error, reason}
    end
  end

  @spec attributes_from_event(binary()) ::
          {:ok, map()} | {:error, :invalid_envelope | :decoding_error}
  def attributes_from_event(event) do
    with {:ok, _, attributes, _} <- extract_event(event) do
      {:ok, decode_attributes(attributes)}
    end
  end

  defp decode_and_validate(value, validate_expiration) do
    with {:ok, event_type, attributes, event_data} <- extract_event(value),
         {:ok, decoded_event} <- decode_trento_event(event_type, event_data),
         :ok <- maybe_validate_expiration(attributes, validate_expiration) do
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
  rescue
    error ->
      Logger.error("Decoding error: #{inspect(error)}")

      {:error, :decoding_error}
  end

  defp encode_additional_attributes(attributes) do
    Enum.into(attributes, %{}, fn {key, {type, value}} ->
      {Atom.to_string(key), %CloudEvents.CloudEventAttributeValue{attr: {type, value}}}
    end)
  end

  defp decode_attributes(attributes) do
    Enum.into(attributes, %{}, fn {key, %CloudEvents.CloudEventAttributeValue{attr: {_, value}}} ->
      {key, value}
    end)
  end

  defp decode_trento_event(type, data) do
    module_name = Macro.camelize(type)
    module = Module.safe_concat([module_name])

    {:ok, module.decode(data)}
  rescue
    ArgumentError -> {:error, :unknown_event}
  end

  defp get_type(mod) do
    mod
    |> Atom.to_string()
    |> String.replace("Elixir.", "")
  end

  defp maybe_validate_expiration(_payload, false), do: :ok

  defp maybe_validate_expiration(
         %{
           "expiration" => %CloudEvents.CloudEventAttributeValue{
             attr: {:ce_timestamp, %Google.Protobuf.Timestamp{seconds: unix_expiration}}
           }
         },
         true
       ) do
    expiration = DateTime.from_unix!(unix_expiration)

    if DateTime.after?(expiration, DateTime.utc_now()) do
      :ok
    else
      {:error, :event_expired}
    end
  end

  defp maybe_validate_expiration(_, _skip_validation) do
    {:error, :expiration_attribute_not_found}
  end
end
