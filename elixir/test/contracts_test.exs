defmodule Trento.ContractsTest do
  @moduledoc false
  use ExUnit.Case

  alias CloudEvents.CloudEvent

  describe "event decoding" do
    test "should decode to the right struct when no errors are detected in the event payload" do
      event_id = UUID.uuid4()
      event = %Test.Event{id: event_id}
      time = DateTime.utc_now()
      expiration = DateTime.add(time, 2, :minute)
      time_attr = %Google.Protobuf.Timestamp{seconds: time |> DateTime.to_unix()}
      expiration_attr = %Google.Protobuf.Timestamp{seconds: expiration |> DateTime.to_unix()}

      cloudevent = %CloudEvent{
        data:
          {:proto_data,
           %Google.Protobuf.Any{
             __unknown_fields__: [],
             type_url: "test.Event",
             value: Test.Event.encode(event)
           }},
        id: UUID.uuid4(),
        source: "wandalorian",
        spec_version: "1.0",
        type: "test.Event",
        attributes: %{
          "time" => %CloudEvents.CloudEventAttributeValue{attr: {:ce_timestamp, time_attr}},
          "expiration" => %CloudEvents.CloudEventAttributeValue{
            attr: {:ce_timestamp, expiration_attr}
          }
        }
      }

      encoded_cloudevent = CloudEvent.encode(cloudevent)

      assert {:ok, %Test.Event{id: ^event_id}} = Trento.Contracts.from_event(encoded_cloudevent)
    end

    test "should return an error when the event is expired" do
      event_id = UUID.uuid4()
      event = %Test.Event{id: event_id}
      time = DateTime.add(DateTime.utc_now(), -2, :minute)
      expiration = DateTime.add(time, 1, :minute)
      time_attr = %Google.Protobuf.Timestamp{seconds: time |> DateTime.to_unix()}
      expiration_attr = %Google.Protobuf.Timestamp{seconds: expiration |> DateTime.to_unix()}

      cloudevent = %CloudEvent{
        data:
          {:proto_data,
           %Google.Protobuf.Any{
             __unknown_fields__: [],
             type_url: "test.Event",
             value: Test.Event.encode(event)
           }},
        id: UUID.uuid4(),
        source: "wandalorian",
        spec_version: "1.0",
        type: "test.Event",
        attributes: %{
          "time" => %CloudEvents.CloudEventAttributeValue{attr: {:ce_timestamp, time_attr}},
          "expiration" => %CloudEvents.CloudEventAttributeValue{
            attr: {:ce_timestamp, expiration_attr}
          }
        }
      }

      encoded_cloudevent = CloudEvent.encode(cloudevent)
      assert {:error, :event_expired} = Trento.Contracts.from_event(encoded_cloudevent)
    end

    test "should return an error when the event does not have the expiration attribute" do
      event_id = UUID.uuid4()
      event = %Test.Event{id: event_id}
      time = DateTime.add(DateTime.utc_now(), -2, :minute)
      time_attr = %Google.Protobuf.Timestamp{seconds: time |> DateTime.to_unix()}

      cloudevent = %CloudEvent{
        data:
          {:proto_data,
           %Google.Protobuf.Any{
             __unknown_fields__: [],
             type_url: "test.Event",
             value: Test.Event.encode(event)
           }},
        id: UUID.uuid4(),
        source: "wandalorian",
        spec_version: "1.0",
        type: "test.Event",
        attributes: %{
          "time" => %CloudEvents.CloudEventAttributeValue{attr: {:ce_timestamp, time_attr}}
        }
      }

      encoded_cloudevent = CloudEvent.encode(cloudevent)

      assert {:error, :expiration_attribute_not_found} =
               Trento.Contracts.from_event(encoded_cloudevent)
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
      cloudevent = %CloudEvent{
        data:
          {:proto_data,
           %Google.Protobuf.Any{
             __unknown_fields__: [],
             type_url: "Unknown.Event",
             value: <<0, 0, 0, 0, 0, 0, 0, 0>>
           }},
        id: UUID.uuid4(),
        source: "wandalorian",
        spec_version: "1.0",
        type: "Unknown.Event"
      }

      assert {:error, :unknown_event} =
               cloudevent |> CloudEvent.encode() |> Trento.Contracts.from_event()
    end
  end

  describe "event encoding" do
    test "should encode to the right struct when all the options are provided" do
      event = %Test.Event{id: UUID.uuid4()}
      cloudevent_id = UUID.uuid4()
      time = DateTime.utc_now()
      expiration = DateTime.add(time, 3, :minute)
      time_attr = %Google.Protobuf.Timestamp{seconds: time |> DateTime.to_unix()}
      expiration_attr = %Google.Protobuf.Timestamp{seconds: expiration |> DateTime.to_unix()}

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
          "expiration" => %CloudEvents.CloudEventAttributeValue{
            attr: {:ce_timestamp, expiration_attr}
          }
        }
      }

      encoded_cloudevent = CloudEvent.encode(cloudevent)

      assert encoded_cloudevent ==
               Trento.Contracts.to_event(event,
                 id: cloudevent_id,
                 source: "wandalorian",
                 time: time,
                 expiration: expiration
               )
    end

    test "should encode to the right struct with the defaults, when no options are provided" do
      event = %Test.Event{id: UUID.uuid4()}
      id = UUID.uuid4()

      %{
        id: cloudevent_id,
        source: cloudevent_source,
        attributes: %{
          "expiration" => %CloudEvents.CloudEventAttributeValue{
            attr: {:ce_timestamp, %Google.Protobuf.Timestamp{seconds: expiration_ts}}
          },
          "time" => %CloudEvents.CloudEventAttributeValue{
            attr: {:ce_timestamp, %Google.Protobuf.Timestamp{seconds: time_ts}}
          }
        }
      } =
        CloudEvent.decode(
          Trento.Contracts.to_event(event,
            id: id
          )
        )

      assert id == cloudevent_id
      assert cloudevent_source == "https://github.com/trento-project"
      refute time_ts == nil
      refute expiration_ts == nil

      cloudevent_time = DateTime.from_unix!(time_ts)
      cloudevent_expiration = DateTime.from_unix!(expiration_ts)

      assert cloudevent_expiration == DateTime.add(cloudevent_time, 5, :minute)
    end
  end
end
