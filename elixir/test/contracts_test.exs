defmodule Trento.ContractsTest do
  use ExUnit.Case

  alias CloudEvents.CloudEvent

  setup_all do
    private_key = File.read!("test/support/fixtures/test.private.pem")
    public_key = File.read!("test/support/fixtures/test.public.pem")
    event_id = UUID.uuid4()
    event = %Test.Event{id: event_id}

    time = DateTime.utc_now()
    time_ts = DateTime.to_unix(time)
    wire_time_ts = DateTime.to_iso8601(time)

    expire_at = DateTime.add(time, 20)
    expire_at_ts = DateTime.to_unix(expire_at)
    wire_expire_at_ts = DateTime.to_iso8601(expire_at)

    {:ok, json_encodable_map} = Protobuf.JSON.to_encodable(event)

    ts = %{"time" => wire_time_ts, "expire_at" => wire_expire_at_ts}
    json_encodable_map_with_ts = Map.merge(json_encodable_map, ts)
    canonical_message_content = Jcs.encode(json_encodable_map_with_ts)

    jwk = JOSE.JWK.from_pem(private_key)

    jws = %{"alg" => "RS512"}
    signature = JOSE.JWS.sign(jwk, canonical_message_content, jws)
    {_alg, compacted_signature} = JOSE.JWS.compact(signature)

    message_content = %{}

    payload_with_signature =
      Map.merge(json_encodable_map_with_ts, %{"signature" => compacted_signature})
      |> Jason.encode!()

    cloudevent = %CloudEvent{
      data:
        {:proto_data,
         %Google.Protobuf.Any{
           __unknown_fields__: [],
           type_url: "Test.Event",
           value: message_content
         }},
      attributes: %{
        "expire_at" => %CloudEvents.CloudEventAttributeValue{
          attr: {:ce_timestamp, %{seconds: expire_at_ts}}
        },
        "time" => %CloudEvents.CloudEventAttributeValue{
          attr: {:ce_timestamp, %{seconds: time_ts}}
        },
        "signature" => %CloudEvents.CloudEventAttributeValue{
          attr: {:ce_bytes, payload_with_signature}
        }
      },
      id: event_id,
      source: "wandalorian",
      spec_version: "1.0",
      type: "Test.Event"
    }

    %{
      private_key: private_key,
      public_key: public_key,
      cloudevent: cloudevent,
      payload_with_signature: payload_with_signature,
      event_id: event_id,
      event: event,
      time: time,
      time_ts: time_ts,
      expire_at_ts: expire_at_ts,
      message_content: message_content
    }
  end

  describe "message with signature" do
    test "should decode to the right struct", %{
      event_id: event_id,
      public_key: public_key,
      cloudevent: cloudevent
    } do
      encoded_cloudevent = CloudEvent.encode(cloudevent)

      assert {:ok, %Test.Event{id: ^event_id}} =
               Trento.Contracts.from_signed_event(encoded_cloudevent, public_key)
    end

    test "should encode to the right struct", %{
      event_id: event_id,
      event: event,
      time: time,
      cloudevent: cloudevent,
      private_key: private_key,
      public_key: public_key
    } do

      signed_event =
        Trento.Contracts.to_signed_event(
          event,
          private_key,
          id: event_id,
          source: "wandalorian",
          time: time
        )

      {:ok, verified_event} =
        Trento.Contracts.from_signed_event(signed_event, public_key)

      assert verified_event == event
    end

    test "should return error if the event is not wrapped in a CloudEvent", %{
      public_key: public_key
    } do
      event = Test.Event.encode(%Test.Event{id: UUID.uuid4()})

      assert {:error, :invalid_envelope} = Trento.Contracts.from_signed_event(event, public_key)
    end

    test "should return error if the could not be decoded", %{
      public_key: public_key
    } do
      event = <<0, 0>>

      assert {:error, :decoding_error} = Trento.Contracts.from_signed_event(event, public_key)
    end

    test "should return error if the event type is unknown", %{
      public_key: public_key,
      message_content: message_content,
      expire_at_ts: expire_at_ts,
      time_ts: time_ts,
      payload_with_signature: payload_with_signature
    } do
      cloudevent = %CloudEvent{
        data:
          {:proto_data,
           %Google.Protobuf.Any{
             __unknown_fields__: [],
             type_url: "unknown.Event",
             value: message_content
           }},
        attributes: %{
          "expire_at" => %CloudEvents.CloudEventAttributeValue{
            attr: {:ce_timestamp, %{seconds: expire_at_ts}}
          },
          "time" => %CloudEvents.CloudEventAttributeValue{
            attr: {:ce_timestamp, %{seconds: time_ts}}
          },
          "signature" => %CloudEvents.CloudEventAttributeValue{
            attr: {:ce_bytes, payload_with_signature}
          }
        },
        id: UUID.uuid4(),
        source: "wandalorian",
        spec_version: "1.0",
        type: "unknown.Event"
      }

      encoded_cloudevent = CloudEvent.encode(cloudevent)

      assert {:error, :unknown_event} =
               Trento.Contracts.from_signed_event(encoded_cloudevent, public_key)
    end

    test "should return error if the event is expired", %{
      public_key: public_key,
      private_key: private_key,
      message_content: message_content,
      time: time,
      time_ts: time_ts,
      event: event
    } do
      wire_time_ts = DateTime.to_iso8601(time)
      expire_at = DateTime.add(time, -60)
      expire_at_ts = DateTime.to_unix(expire_at)
      wire_expire_at_ts = DateTime.to_iso8601(expire_at)
      {:ok, json_encodable_map} = Protobuf.JSON.to_encodable(event)

      ts = %{"time" => wire_time_ts, "expire_at" => wire_expire_at_ts}
      json_encodable_map_with_ts = Map.merge(json_encodable_map, ts)
      canonical_message_content = Jcs.encode(json_encodable_map_with_ts)

      jwk = JOSE.JWK.from_pem(private_key)

      jws = %{"alg" => "RS512"}
      signature = JOSE.JWS.sign(jwk, canonical_message_content, jws)
      {_alg, compacted_signature} = JOSE.JWS.compact(signature)

      payload_with_signature =
        Map.merge(json_encodable_map_with_ts, %{"signature" => compacted_signature})
        |> Jason.encode!()

      cloudevent = %CloudEvent{
        data:
          {:proto_data,
           %Google.Protobuf.Any{
             __unknown_fields__: [],
             type_url: "Test.Event",
             value: message_content
           }},
        attributes: %{
          "expire_at" => %CloudEvents.CloudEventAttributeValue{
            attr: {:ce_timestamp, %{seconds: expire_at_ts}}
          },
          "time" => %CloudEvents.CloudEventAttributeValue{
            attr: {:ce_timestamp, %{seconds: time_ts}}
          },
          "signature" => %CloudEvents.CloudEventAttributeValue{
            attr: {:ce_bytes, payload_with_signature}
          }
        },
        id: UUID.uuid4(),
        source: "wandalorian",
        spec_version: "1.0",
        type: "Test.Event"
      }

      encoded_cloudevent = CloudEvent.encode(cloudevent)

      assert {:error, :event_expired} =
               Trento.Contracts.from_signed_event(encoded_cloudevent, public_key)
    end

    test "should return error if the event signature is not valid", %{
      public_key: public_key,
      message_content: message_content,
      expire_at_ts: expire_at_ts,
      time_ts: time_ts,
      payload_with_signature: payload_with_signature
    } do
      payload_with_signature_decoded = Jason.decode!(payload_with_signature)

      signature =
        "invalidsignature"

      updated_payload_with_invalid_sig =
        %{
          payload_with_signature_decoded
          | "signature" => signature
        }
        |> Jason.encode!()

      cloudevent = %CloudEvent{
        data:
          {:proto_data,
           %Google.Protobuf.Any{
             __unknown_fields__: [],
             type_url: "test.Event",
             value: message_content
           }},
        attributes: %{
          "expire_at" => %CloudEvents.CloudEventAttributeValue{
            attr: {:ce_timestamp, %{seconds: expire_at_ts}}
          },
          "time" => %CloudEvents.CloudEventAttributeValue{
            attr: {:ce_timestamp, %{seconds: time_ts}}
          },
          "signature" => %CloudEvents.CloudEventAttributeValue{
            attr: {:ce_bytes, updated_payload_with_invalid_sig}
          }
        },
        id: UUID.uuid4(),
        source: "wandalorian",
        spec_version: "1.0",
        type: "test.Event"
      }

      encoded_cloudevent = CloudEvent.encode(cloudevent)

      assert {:error, :invalid_event_signature} =
               Trento.Contracts.from_signed_event(encoded_cloudevent, public_key)
    end
  end

  describe "message without signature" do
    test "should decode to the right struct" do
      event_id = UUID.uuid4()
      event = %Test.Event{id: event_id}
      time = DateTime.utc_now()

      cloudevent = %CloudEvent{
        data:
          {:proto_data,
           %Google.Protobuf.Any{
             __unknown_fields__: [],
             type_url: "test.Event",
             value: Test.Event.encode(event)
           }},
        attributes: %{
          "expire_at" => %CloudEvents.CloudEventAttributeValue{
            attr: {:ce_timestamp, %{seconds: DateTime.add(time, 60) |> DateTime.to_unix()}}
          }
        },
        id: UUID.uuid4(),
        source: "wandalorian",
        spec_version: "1.0",
        type: "test.Event"
      }

      encoded_cloudevent = CloudEvent.encode(cloudevent)

      assert {:ok, %Test.Event{id: ^event_id}} = Trento.Contracts.from_event(encoded_cloudevent)
    end

    test "should encode to the right struct" do
      event = %Test.Event{id: UUID.uuid4()}
      cloudevent_id = UUID.uuid4()
      time = DateTime.utc_now()
      time_attr = %Google.Protobuf.Timestamp{seconds: time |> DateTime.to_unix()}

      cloudevent = %CloudEvent{
        data:
          {:proto_data,
           %Google.Protobuf.Any{
             __unknown_fields__: [],
             type_url: "Test.Event",
             value: Test.Event.encode(event)
           }},
        id: cloudevent_id,
        source: "wandalorian",
        spec_version: "1.0",
        type: "Test.Event",
        attributes: %{
          "time" => %CloudEvents.CloudEventAttributeValue{attr: {:ce_timestamp, time_attr}},
          "expire_at" => %CloudEvents.CloudEventAttributeValue{
            attr: {:ce_timestamp, %{seconds: DateTime.add(time, 20) |> DateTime.to_unix()}}
          }
        }
      }

      encoded_cloudevent = CloudEvent.encode(cloudevent)

      assert encoded_cloudevent ==
               Trento.Contracts.to_event(event,
                 id: cloudevent_id,
                 source: "wandalorian",
                 time: time
               )
    end

    test "should return error if the event is not wrapped in a CloudEvent" do
      event = Test.Event.encode(%Test.Event{id: UUID.uuid4()})

      assert {:error, :invalid_envelope} = Trento.Contracts.from_event(event)
    end

    test "should return error if the could not be decoded" do
      event = <<0, 0>>

      assert {:error, :decoding_error} = Trento.Contracts.from_event(event)
    end

    test "should return error if the event type is unknown" do
      time = DateTime.utc_now()
      time_attr = %Google.Protobuf.Timestamp{seconds: time |> DateTime.to_unix()}

      cloudevent = %CloudEvent{
        data:
          {:proto_data,
           %Google.Protobuf.Any{
             __unknown_fields__: [],
             type_url: "Unknown.Event",
             value: <<0, 0, 0, 0, 0, 0, 0, 0>>
           }},
        attributes: %{
          "time" => %CloudEvents.CloudEventAttributeValue{attr: {:ce_timestamp, time_attr}},
          "expire_at" => %CloudEvents.CloudEventAttributeValue{
            attr: {:ce_timestamp, %{seconds: DateTime.add(time, 20) |> DateTime.to_unix()}}
          }
        },
        id: UUID.uuid4(),
        source: "wandalorian",
        spec_version: "1.0",
        type: "Unknown.Event"
      }

      assert {:error, :unknown_event} =
               cloudevent |> CloudEvent.encode() |> Trento.Contracts.from_event()
    end

    test "should return error if the event is expired" do
      event_id = UUID.uuid4()
      event = %Test.Event{id: event_id}
      time = DateTime.utc_now()

      cloudevent = %CloudEvent{
        data:
          {:proto_data,
           %Google.Protobuf.Any{
             __unknown_fields__: [],
             type_url: "test.Event",
             value: Test.Event.encode(event)
           }},
        attributes: %{
          "expire_at" => %CloudEvents.CloudEventAttributeValue{
            attr: {:ce_timestamp, %{seconds: DateTime.add(time, -10) |> DateTime.to_unix()}}
          }
        },
        id: UUID.uuid4(),
        source: "wandalorian",
        spec_version: "1.0",
        type: "test.Event"
      }

      encoded_cloudevent = CloudEvent.encode(cloudevent)

      assert {:error, :event_expired} = Trento.Contracts.from_event(encoded_cloudevent)
    end
  end
end
