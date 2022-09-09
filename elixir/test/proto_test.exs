defmodule ProtoTest do
  use ExUnit.Case

  alias CloudEvents.CloudEvent

  test "should decode to the right struct" do
    %Test.Event{id: event_id} = event = Test.Event.new(id: UUID.uuid4())

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
      type: "test.Event"
    }

    encoded_cloudevent = CloudEvent.encode(cloudevent)

    assert %Test.Event{id: ^event_id} = Proto.from_event(encoded_cloudevent)
  end

  test "should encode to the right struct" do
    event = Test.Event.new(id: UUID.uuid4())
    cloudevent_id = UUID.uuid4()

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
      type: "Test.Event"
    }

    encoded_cloudevent = CloudEvent.encode(cloudevent)

    assert encoded_cloudevent == Proto.to_event(event, id: cloudevent_id, source: "wandalorian")
  end
end
