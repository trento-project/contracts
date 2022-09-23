package events_test

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/trento-project/contracts/go/pkg/events"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/anypb"
	timestamppb "google.golang.org/protobuf/types/known/timestamppb"
)

func TestToEvent(t *testing.T) {
	event := events.FactsGatheringRequested{
		ExecutionId: "exe",
		GroupId:     "group_1",
		Targets: []*events.FactsGatheringRequestedTarget{
			{
				AgentId: "agent_1",
				FactRequests: []*events.FactRequest{
					{
						CheckId:  "check_1",
						Name:     "test fact",
						Gatherer: "factone",
						Argument: "arg",
					},
				},
			},
		},
	}

	id := "id"
	source := "wandalorian"
	time := time.Now()

	data, err := anypb.New(&event)

	attr := events.CloudEventAttributeValue{
		Attr: &events.CloudEventAttributeValue_CeTimestamp{
			CeTimestamp: timestamppb.New(time),
		},
	}

	assert.NoError(t, err)
	ce := events.CloudEvent{
		Id:          id,
		Source:      source,
		SpecVersion: "1.0",
		Type:        string(event.ProtoReflect().Descriptor().FullName()),
		Data: &events.CloudEvent_ProtoData{
			ProtoData: data,
		},
		Attributes: map[string]*events.CloudEventAttributeValue{
			"time": &attr,
		},
	}

	rawCe, err := proto.Marshal(&ce)
	assert.NoError(t, err)

	encodedEvent, err := events.ToEvent(&event, events.WithID(id), events.WithSource(source), events.WithTime(time))
	assert.NoError(t, err)

	assert.EqualValues(t, rawCe, encodedEvent)
}

func TestToEventWithDefaults(t *testing.T) {
	event := events.FactsGatheringRequested{
		ExecutionId: "exe",
		GroupId:     "group_1",
		Targets: []*events.FactsGatheringRequestedTarget{
			{
				AgentId: "agent_1",
				FactRequests: []*events.FactRequest{
					{
						CheckId:  "check_1",
						Name:     "test fact",
						Gatherer: "factone",
						Argument: "arg",
					},
				},
			},
		},
	}

	_, err := events.ToEvent(&event)
	assert.NoError(t, err)
}

func TestFromEvent(t *testing.T) {
	event := events.FactsGatheringRequested{
		ExecutionId: "exe",
		GroupId:     "group_1",
		Targets: []*events.FactsGatheringRequestedTarget{
			{
				AgentId: "agent_1",
				FactRequests: []*events.FactRequest{
					{
						CheckId:  "check_1",
						Name:     "test fact",
						Gatherer: "factone",
						Argument: "arg",
					},
				},
			},
		},
	}

	data, err := anypb.New(&event)

	assert.NoError(t, err)
	ce := events.CloudEvent{
		Id:          "id",
		Source:      "wandalorian",
		SpecVersion: "1.0",
		Type:        "FactsGatheringRequested",
		Data: &events.CloudEvent_ProtoData{
			ProtoData: data,
		},
	}

	rawCe, err := proto.Marshal(&ce)
	assert.NoError(t, err)

	// decode test

	var decodedEvent events.FactsGatheringRequested

	err = events.FromEvent(rawCe, &decodedEvent)
	assert.NoError(t, err)

	assert.EqualValues(t, event.GetExecutionId(), decodedEvent.GetExecutionId())
	assert.EqualValues(t, event.GetGroupId(), decodedEvent.GetGroupId())
	assert.EqualValues(t, event.Targets[0].String(), event.Targets[0].String())
}
