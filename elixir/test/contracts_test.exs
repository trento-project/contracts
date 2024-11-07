defmodule Trento.ContractsTest do
  use ExUnit.Case

  alias CloudEvents.CloudEvent

  describe "message with signature" do
    setup do
      private_key = File.read!("test/support/fixtures/test.private.pem")
      public_key = File.read!("test/support/fixtures/test.public.pem")

      %{private_key: private_key, public_key: public_key}
    end

    test "should decode to the right struct", %{public_key: public_key, private_key: private_key} do
      event_id = UUID.uuid4()
      event = %Test.Event{id: event_id}

      time = DateTime.utc_now()
      time_ts = DateTime.to_unix(time)

      expire_at = DateTime.add(time, 60)
      expire_at_ts = DateTime.to_unix(expire_at)

      message_content = Test.Event.encode(event)

      signing_key =
        private_key
        |> :public_key.pem_decode()
        |> Enum.at(0)
        |> :public_key.pem_entry_decode()

      signature =
        :public_key.sign("#{message_content}#{time_ts}#{expire_at_ts}", :sha256, signing_key)

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
          "signature" => %CloudEvents.CloudEventAttributeValue{attr: {:ce_bytes, signature}}
        },
        id: UUID.uuid4(),
        source: "wandalorian",
        spec_version: "1.0",
        type: "test.Event"
      }

      encoded_cloudevent = CloudEvent.encode(cloudevent)

      assert {:ok, %Test.Event{id: ^event_id}} =
               Trento.Contracts.from_signed_event(encoded_cloudevent, public_key)
    end

    test "should encode to the right struct", %{private_key: private_key} do
      event_id = UUID.uuid4()
      event = %Test.Event{id: event_id}

      time = DateTime.utc_now()
      time_ts = DateTime.to_unix(time)

      expire_at = DateTime.add(time, 20)
      expire_at_ts = DateTime.to_unix(expire_at)

      message_content = Test.Event.encode(event)

      signing_key =
        private_key
        |> :public_key.pem_decode()
        |> Enum.at(0)
        |> :public_key.pem_entry_decode()

      signature =
        :public_key.sign("#{message_content}#{time_ts}#{expire_at_ts}", :sha256, signing_key)

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
          "signature" => %CloudEvents.CloudEventAttributeValue{attr: {:ce_bytes, signature}}
        },
        id: event_id,
        source: "wandalorian",
        spec_version: "1.0",
        type: "Test.Event"
      }

      encoded_cloudevent = CloudEvent.encode(cloudevent)

      assert encoded_cloudevent ==
               Trento.Contracts.to_signed_event(
                 event,
                 private_key,
                 id: event_id,
                 source: "wandalorian",
                 time: time
               )
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
      private_key: private_key,
      public_key: public_key
    } do
      time = DateTime.utc_now()
      time_ts = DateTime.to_unix(time)

      expire_at = DateTime.add(time, 60)
      expire_at_ts = DateTime.to_unix(expire_at)

      message_content = <<0, 0, 0, 0, 0, 0, 0, 0>>

      signing_key =
        private_key
        |> :public_key.pem_decode()
        |> Enum.at(0)
        |> :public_key.pem_entry_decode()

      signature =
        :public_key.sign("#{message_content}#{time_ts}#{expire_at_ts}", :sha256, signing_key)

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
          "signature" => %CloudEvents.CloudEventAttributeValue{attr: {:ce_bytes, signature}}
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
      private_key: private_key,
      public_key: public_key
    } do
      event_id = UUID.uuid4()
      event = %Test.Event{id: event_id}

      time = DateTime.utc_now()
      time_ts = DateTime.to_unix(time)

      expire_at = DateTime.add(time, -60)
      expire_at_ts = DateTime.to_unix(expire_at)

      message_content = Test.Event.encode(event)

      signing_key =
        private_key
        |> :public_key.pem_decode()
        |> Enum.at(0)
        |> :public_key.pem_entry_decode()

      signature =
        :public_key.sign("#{message_content}#{time_ts}#{expire_at_ts}", :sha256, signing_key)

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
          "signature" => %CloudEvents.CloudEventAttributeValue{attr: {:ce_bytes, signature}}
        },
        id: UUID.uuid4(),
        source: "wandalorian",
        spec_version: "1.0",
        type: "test.Event"
      }

      encoded_cloudevent = CloudEvent.encode(cloudevent)

      assert {:error, :event_expired} =
               Trento.Contracts.from_signed_event(encoded_cloudevent, public_key)
    end

    test "should return error if the event signature is not valid", %{
      public_key: public_key
    } do
      event_id = UUID.uuid4()
      event = %Test.Event{id: event_id}

      time = DateTime.utc_now()
      time_ts = DateTime.to_unix(time)

      expire_at = DateTime.add(time, -60)
      expire_at_ts = DateTime.to_unix(expire_at)

      message_content = Test.Event.encode(event)
      signature = "invalidsignature"

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
          "signature" => %CloudEvents.CloudEventAttributeValue{attr: {:ce_bytes, signature}}
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
