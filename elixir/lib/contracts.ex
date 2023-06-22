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
        "time" => %CloudEvents.CloudEventAttributeValue{attr: {:ce_timestamp, time_attr}}
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
end
