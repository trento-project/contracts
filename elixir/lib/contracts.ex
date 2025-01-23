defmodule Trento.Contracts do
  @moduledoc """
  This facade contains functions to eoncode/decode events to/from protobuf
  """

  require Logger

  @default_event_validity 20

  @doc """
  Return the content type of contracts
  """
  def content_type, do: "application/x-protobuf"

  @doc """
  Encode and wrap an event struct to a protobuf CloudEvent.
  """
  @spec to_event(struct(), Keyword.t()) :: binary()
  def to_event(%{} = struct, opts \\ []) do
    struct
    |> build_cloud_event(opts)
    |> CloudEvents.CloudEvent.encode()
  end

  @doc """
  Encode and wrap an event struct to a signed protobuf Cloudevent.
  Accepts the private key as a pem file content.
  Accepts the same options as to_event/2
  """
  @spec to_signed_event(struct(), binary(), Keyword.t()) :: binary()
  def to_signed_event(struct, pem_private_key, opts \\ []) do
    updated_opts = [{:will_be_signed?, true} | opts]

    struct
    |> build_cloud_event(updated_opts)
    |> add_signature(pem_private_key, struct)
    |> CloudEvents.CloudEvent.encode()
  end

  @doc """
  Decode and unwrap a protobuf CloudEvent to an event struct.
  """
  @spec from_event(binary()) ::
          {:ok, struct()}
          | {:error, :decoding_error}
          | {:error, :invalid_envelope}
          | {:error, :unknown_event}
          | {:error, :event_expired}
  def from_event(value) do
    with {:ok, type, cloud_event} <- decode_cloud_event(value),
         {:ok, cloud_event} <- verify_event_validity(cloud_event) do
      decode_trento_event(type, cloud_event)
    end
  end

  @doc """
  Decode and unwrap a signed protobuf CloudEvent to an event struct.
  """
  @spec from_signed_event(binary(), binary()) ::
          {:ok, struct()}
          | {:error, :decoding_error}
          | {:error, :invalid_envelope}
          | {:error, :unknown_event}
          | {:error, :event_expired}
          | {:error, :invalid_event_signature}
  def from_signed_event(value, public_key) do
    with {:ok, event_type, event_data} <- decode_cloud_event(value),
         {:ok, canonical_plain_text} <- verify_event_signature(event_data, public_key),
         {:ok, event_with_ts} <- Jason.decode(canonical_plain_text),
         {:ok, valid_event} <- verify_signed_event_validity(event_with_ts),
         {:ok, event_decoded} <-
           decode_json_trento_event(
             event_type,
             Map.drop(valid_event, ["signature", "expire_at", "time"])
           ) do
      {:ok, event_decoded}
    end
  end

  defp build_cloud_event(%mod{} = struct, opts) do
    id = Keyword.get(opts, :id, UUID.uuid4())
    source = Keyword.get(opts, :source, "trento")
    validity_in_seconds = Keyword.get(opts, :validity_in_seconds, @default_event_validity)
    will_be_signed? = Keyword.get(opts, :will_be_signed?, false)

    time =
      Keyword.get(
        opts,
        :time,
        DateTime.utc_now()
      )

    expiration = DateTime.add(time, validity_in_seconds)

    time_attr = %Google.Protobuf.Timestamp{seconds: time |> DateTime.to_unix()}
    expire_at_attr = %Google.Protobuf.Timestamp{seconds: expiration |> DateTime.to_unix()}

    data =
      case will_be_signed? do
        true ->
          %{}

        false ->
          Protobuf.Encoder.encode(struct)
      end

    %CloudEvents.CloudEvent{
      data: {:proto_data, %Google.Protobuf.Any{value: data, type_url: get_type(mod)}},
      spec_version: "1.0",
      type: get_type(mod),
      id: id,
      attributes: %{
        "time" => %CloudEvents.CloudEventAttributeValue{attr: {:ce_timestamp, time_attr}},
        "expire_at" => %CloudEvents.CloudEventAttributeValue{
          attr: {:ce_timestamp, expire_at_attr}
        }
      },
      source: source
    }
  end

  defp add_signature(
         %CloudEvents.CloudEvent{
           data: {:proto_data, %Google.Protobuf.Any{value: _data}},
           attributes:
             %{
               "time" => %CloudEvents.CloudEventAttributeValue{
                 attr: {:ce_timestamp, %{seconds: time}}
               },
               "expire_at" => %CloudEvents.CloudEventAttributeValue{
                 attr: {:ce_timestamp, %{seconds: expire_at}}
               }
             } = current_attrs
         } = event,
         pem_private_key,
         struct
       ) do
    jwk = JOSE.JWK.from_pem(pem_private_key)

    {:ok, json_encodable_map} = Protobuf.JSON.to_encodable(struct, emit_unpopulated: false)

    wire_time =
      time |> DateTime.from_unix!() |> DateTime.to_iso8601()

    wire_expire_at =
      expire_at |> DateTime.from_unix!() |> DateTime.to_iso8601()

    ts = %{"time" => wire_time, "expire_at" => wire_expire_at}

    json_encodable_map_with_ts = Map.merge(json_encodable_map, ts)
    canonical_plain_text = Jcs.encode(json_encodable_map_with_ts)
    jws = %{"alg" => "RS512"}
    signature = JOSE.JWS.sign(jwk, canonical_plain_text, jws)
    {_alg, compacted_signature} = JOSE.JWS.compact(signature)

    updated_data_encodeable =
      Map.merge(json_encodable_map_with_ts, %{"signature" => compacted_signature})

    updated_data = Jason.encode!(updated_data_encodeable)

    %CloudEvents.CloudEvent{
      event
      | attributes:
          Map.put(
            current_attrs,
            "signature",
            %CloudEvents.CloudEventAttributeValue{attr: {:ce_bytes, updated_data}}
          )
    }
  end

  defp decode_cloud_event(data) do
    try do
      case CloudEvents.CloudEvent.decode(data) do
        %{type: type, data: {:proto_data, %Google.Protobuf.Any{value: _data}}} = cloud_event ->
          {:ok, type, cloud_event}

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

  defp verify_event_signature(
         %CloudEvents.CloudEvent{
           data: {:proto_data, %Google.Protobuf.Any{value: _data}},
           attributes: %{
             "time" => %CloudEvents.CloudEventAttributeValue{
               attr: {:ce_timestamp, %{seconds: _time}}
             },
             "expire_at" => %CloudEvents.CloudEventAttributeValue{
               attr: {:ce_timestamp, %{seconds: _expire_at}}
             },
             "signature" => %CloudEvents.CloudEventAttributeValue{
               attr: {:ce_bytes, payload_with_signature}
             }
           }
         } = _event,
         public_key
       ) do
    jwk = JOSE.JWK.from_pem(public_key)
    payload_decoded = Jason.decode!(payload_with_signature)
    signature = payload_decoded["signature"]

    case JOSE.JWS.verify(jwk, {%{}, signature}) do
      {true, canonical_plain_text, _jws} -> {:ok, canonical_plain_text}
      _err -> {:error, :invalid_event_signature}
    end
  end

  defp verify_event_signature(_, _), do: {:error, :invalid_event_signature}

  defp verify_signed_event_validity(event) when is_map(event) do
    {:ok, expire_at, _} =
      event["expire_at"] |> DateTime.from_iso8601()

    event_valid? = DateTime.compare(DateTime.utc_now(), expire_at) == :lt

    if event_valid? do
      {:ok, event}
    else
      {:error, :event_expired}
    end
  end

  defp verify_signed_event_validity(_), do: {:error, :event_expired}

  defp verify_event_validity(
         %CloudEvents.CloudEvent{
           attributes: %{
             "expire_at" => %CloudEvents.CloudEventAttributeValue{
               attr: {:ce_timestamp, %{seconds: expire_at_ts}}
             }
           }
         } = event
       ) do
    expire_at = DateTime.from_unix!(expire_at_ts)
    event_valid? = DateTime.compare(DateTime.utc_now(), expire_at) == :lt

    if event_valid? do
      {:ok, event}
    else
      {:error, :event_expired}
    end
  end

  defp verify_event_validity(_), do: {:error, :event_expired}

  defp decode_json_trento_event(type, decoded_map)
       when is_map(decoded_map) do
    try do
      module_name = Macro.camelize(type)
      module = Module.safe_concat([module_name])

      Protobuf.JSON.from_decoded(decoded_map, module)
    rescue
      ArgumentError ->
        {:error, :unknown_event}
    end
  end

  defp decode_trento_event(type, %CloudEvents.CloudEvent{
         data: {:proto_data, %Google.Protobuf.Any{value: data}}
       }) do
    try do
      module_name = Macro.camelize(type)
      module = Module.safe_concat([module_name])

      {:ok, module.decode(data)}
    rescue
      ArgumentError -> {:error, :unknown_event}
    end
  end

  defp decode_trento_event(_, _), do: {:error, :unknown_event}

  defp get_type(mod) do
    mod
    |> Atom.to_string()
    |> String.replace("Elixir.", "")
  end
end
