defmodule ProtoTest do
  use ExUnit.Case

  alias Cloudevents.CloudEvent

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

    assert %Test.Event{id: ^event_id} = Proto.decode(encoded_cloudevent)
  end
end
