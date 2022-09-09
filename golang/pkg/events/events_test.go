package events_test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/trento-project/contracts/pkg/events"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/anypb"
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

	data, err := anypb.New(&event)

	assert.NoError(t, err)
	ce := events.CloudEvent{
		Id:          "id",
		Source:      "wandalorian",
		SpecVersion: "1.0",
		Type:        string(event.ProtoReflect().Descriptor().FullName()),
		Data: &events.CloudEvent_ProtoData{
			ProtoData: data,
		},
	}

	rawCe, err := proto.Marshal(&ce)
	assert.NoError(t, err)
	encodedEvent, err := events.ToEvent(&event, "wandalorian", "id")
	assert.NoError(t, err)

	assert.EqualValues(t, rawCe, encodedEvent)
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
