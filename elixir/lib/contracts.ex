defmodule Trento.Contracts do
  @moduledoc """
  This facade contains functions to eoncode/decode events to/from protobuf
  """

  require Logger

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
    source = Keyword.get(opts, :source, "trento")
    private_key = Keyword.get(opts, :private_key, "")

    time =
      Keyword.get(
        opts,
        :time,
        DateTime.utc_now()
      )

    time_attr = %Google.Protobuf.Timestamp{seconds: time |> DateTime.to_unix()}
    data = Protobuf.Encoder.encode(struct)

    cloud_event = %CloudEvents.CloudEvent{
      data: {:proto_data, %Google.Protobuf.Any{value: data, type_url: get_type(mod)}},
      spec_version: "1.0",
      type: get_type(mod),
      id: id,
      attributes: %{
        "time" => %CloudEvents.CloudEventAttributeValue{attr: {:ce_timestamp, time_attr}},
      },
      source: source
    } |> add_signature(private_key)

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
      case CloudEvents.CloudEvent.decode(value) do
        %{type: type, data: {:proto_data, %Google.Protobuf.Any{value: data}}} ->
          decode(type, data)

        event ->
          Logger.error("Invalid cloud event: #{inspect(event)}")

          {:error, :invalid_envelope}
      end
    rescue
      error ->
        Logger.error("Decoding error: #{inspect(error)}")

        {:error, :decoding_error}
    end
  end

  defp decode(type, data) do
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

  defp add_signature(event, ""), do: event

  defp add_signature(
    %CloudEvents.CloudEvent{
      data: {:proto_data, %Google.Protobuf.Any{value: data}},
      attributes: %{
        "time" => %CloudEvents.CloudEventAttributeValue{
          attr: {:ce_timestamp, %{seconds: time}}
        }
      } = current_attrs
    } = event, private_key) do

    time_str = Integer.to_string(time)
    signature = :public_key.sign(data <> time_str, :sha256, private_key)

    %CloudEvents.CloudEvent{
      event |
      attributes: Map.put(
        current_attrs,
        "signature",
        %CloudEvents.CloudEventAttributeValue{attr: {:ce_bytes, signature}}
      )
    }
  end

  # def add_signature(event, private_key) do
  #   decoded_event = %{
  #     data: {:proto_data, %Google.Protobuf.Any{value: data}},
  #     attributes: %{
  #       "time" => %CloudEvents.CloudEventAttributeValue{attr: {:ce_timestamp, time}}
  #     } = current_attrs
  #   } = CloudEvents.CloudEvent.decode(event)

  #   %{seconds: seconds} = time
  #   time_str = Integer.to_string(seconds)
  #   signature = :public_key.sign(data <> time_str, :sha256, private_key)

  #   updated_event = %CloudEvents.CloudEvent{
  #     decoded_event |
  #     attributes: Map.put(
  #       current_attrs,
  #       "signature",
  #       %CloudEvents.CloudEventAttributeValue{attr: {:ce_bytes, signature}}
  #     )
  #   }

  #   CloudEvents.CloudEvent.encode(updated_event)
  # end
end
