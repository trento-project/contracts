defmodule Trento.ContractsTest do
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

    assert {:ok, %Test.Event{id: ^event_id}} = Trento.Contracts.from_event(encoded_cloudevent)
  end

  test "should encode to the right struct" do
    event = Test.Event.new(id: UUID.uuid4())
    cloudevent_id = UUID.uuid4()
    time = DateTime.utc_now()
    time_attr = Google.Protobuf.Timestamp.new!(seconds: time |> DateTime.to_unix())

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
        "time" => CloudEvents.CloudEventAttributeValue.new!(attr: {:ce_timestamp, time_attr})
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
    event = [id: UUID.uuid4()] |> Test.Event.new() |> Test.Event.encode()

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
