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
	now := time.Now()
	expiration := now.Add(2 * time.Minute)

	data, err := anypb.New(&event)

	timeAttr := events.CloudEventAttributeValue{
		Attr: &events.CloudEventAttributeValue_CeTimestamp{
			CeTimestamp: timestamppb.New(now),
		},
	}

	expireAttr := events.CloudEventAttributeValue{
		Attr: &events.CloudEventAttributeValue_CeTimestamp{
			CeTimestamp: timestamppb.New(expiration),
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
			"time":       &timeAttr,
			"expiration": &expireAttr,
		},
	}

	rawCe, err := proto.Marshal(&ce)
	assert.NoError(t, err)

	encodedEvent, err := events.ToEvent(
		&event,
		events.WithID(id),
		events.WithSource(source),
		events.WithTime(now),
		events.WithExpiration(expiration),
	)
	assert.NoError(t, err)

	// Unmarshal both to compare contents instead of raw bytes to avoid timestamp precision issues
	var expectedCe events.CloudEvent
	err = proto.Unmarshal(rawCe, &expectedCe)
	assert.NoError(t, err)

	var actualCe events.CloudEvent
	err = proto.Unmarshal(encodedEvent, &actualCe)
	assert.NoError(t, err)

	assert.Equal(t, expectedCe.Id, actualCe.Id)
	assert.Equal(t, expectedCe.Source, actualCe.Source)
	assert.Equal(t, expectedCe.SpecVersion, actualCe.SpecVersion)
	assert.Equal(t, expectedCe.Type, actualCe.Type)
	assert.True(t, proto.Equal(expectedCe.GetProtoData(), actualCe.GetProtoData()))
	assert.Equal(t, expectedCe.GetAttributes()["time"].GetCeTimestamp().AsTime().Unix(), actualCe.GetAttributes()["time"].GetCeTimestamp().AsTime().Unix())
	assert.Equal(t, expectedCe.GetAttributes()["expiration"].GetCeTimestamp().AsTime().Unix(), actualCe.GetAttributes()["expiration"].GetCeTimestamp().AsTime().Unix())
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

	rawEvent, err := events.ToEvent(&event)
	assert.NoError(t, err)

	var expectedCe events.CloudEvent
	err = proto.Unmarshal(rawEvent, &expectedCe)
	assert.NoError(t, err)

	expectedExpiration := expectedCe.GetAttributes()["expiration"].GetCeTimestamp().AsTime()
	expectedTime := expectedCe.GetAttributes()["time"].GetCeTimestamp().AsTime()
	expectedSource := expectedCe.Source
	expectedID := expectedCe.Id

	assert.NotNil(t, expectedExpiration)
	assert.NotNil(t, expectedTime)
	assert.Equal(t, "https://github.com/trento-project", expectedSource)
	assert.NotEmpty(t, expectedID)
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

	now := time.Now()

	ce := events.CloudEvent{
		Id:          "id",
		Source:      "wandalorian",
		SpecVersion: "1.0",
		Type:        "FactsGatheringRequested",
		Data: &events.CloudEvent_ProtoData{
			ProtoData: data,
		},
		Attributes: map[string]*events.CloudEventAttributeValue{
			"time": {
				Attr: &events.CloudEventAttributeValue_CeTimestamp{
					CeTimestamp: timestamppb.New(now),
				},
			},
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

func TestFromEventExpiredEventError(t *testing.T) {
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

	eventCreated := time.Now().Add(-2 * time.Minute)
	expiration := eventCreated.Add(20 * time.Second)

	assert.NoError(t, err)
	ce := events.CloudEvent{
		Id:          "id",
		Source:      "wandalorian",
		SpecVersion: "1.0",
		Type:        "FactsGatheringRequested",
		Data: &events.CloudEvent_ProtoData{
			ProtoData: data,
		},
		Attributes: map[string]*events.CloudEventAttributeValue{
			"time": {
				Attr: &events.CloudEventAttributeValue_CeTimestamp{
					CeTimestamp: timestamppb.New(eventCreated),
				},
			},
			"expiration": {
				Attr: &events.CloudEventAttributeValue_CeTimestamp{
					CeTimestamp: timestamppb.New(expiration),
				},
			},
		},
	}

	var decodedEvent events.FactsGatheringRequested

	rawEvent, err := proto.Marshal(&ce)
	assert.NoError(t, err)
	err = events.FromEvent(rawEvent, &decodedEvent, events.WithExpirationCheck())
	assert.ErrorIs(t, err, events.ErrEventExpired)
}

func TestFromEventNoExpirationSetError(t *testing.T) {
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

	eventCreated := time.Now().Add(-2 * time.Minute)

	assert.NoError(t, err)
	ce := events.CloudEvent{
		Id:          "id",
		Source:      "wandalorian",
		SpecVersion: "1.0",
		Type:        "FactsGatheringRequested",
		Data: &events.CloudEvent_ProtoData{
			ProtoData: data,
		},
		Attributes: map[string]*events.CloudEventAttributeValue{
			"time": {
				Attr: &events.CloudEventAttributeValue_CeTimestamp{
					CeTimestamp: timestamppb.New(eventCreated),
				},
			},
		},
	}

	var decodedEvent events.FactsGatheringRequested

	rawEvent, err := proto.Marshal(&ce)
	assert.NoError(t, err)
	err = events.FromEvent(rawEvent, &decodedEvent, events.WithExpirationCheck())
	assert.ErrorIs(t, err, events.ErrExpirationNotFound)
}

func TestFromEventExpirationMalformedError(t *testing.T) {
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

	eventCreated := time.Now().Add(-2 * time.Minute)

	assert.NoError(t, err)
	ce := events.CloudEvent{
		Id:          "id",
		Source:      "wandalorian",
		SpecVersion: "1.0",
		Type:        "FactsGatheringRequested",
		Data: &events.CloudEvent_ProtoData{
			ProtoData: data,
		},
		Attributes: map[string]*events.CloudEventAttributeValue{
			"time": {
				Attr: &events.CloudEventAttributeValue_CeTimestamp{
					CeTimestamp: timestamppb.New(eventCreated),
				},
			},
			"expiration": {
				Attr: nil,
			},
		},
	}

	var decodedEvent events.FactsGatheringRequested

	rawEvent, err := proto.Marshal(&ce)
	assert.NoError(t, err)
	err = events.FromEvent(rawEvent, &decodedEvent, events.WithExpirationCheck())
	assert.ErrorIs(t, err, events.ErrExpirationAttributeMalformed)
}
