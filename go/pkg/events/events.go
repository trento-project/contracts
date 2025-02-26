package events

import (
	"errors"
	"time"

	"github.com/google/uuid"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/anypb"
	timestamppb "google.golang.org/protobuf/types/known/timestamppb"
)

const defaultExpirationWindow = 5 * time.Minute

var ErrExpirationNotFound = errors.New("cannot decode cloudevent, expiration attribute not found")
var ErrExpirationAttributeMalformed = errors.New("cannot decode cloudevent, expiration attribute malformed")
var ErrEventExpired = errors.New("cannot decode cloudevent, event expired")

type cloudEventOptions struct {
	id             string
	source         string
	time           time.Time
	expirationTime time.Time
}

type Option = func(fields *cloudEventOptions)

func WithID(id string) Option {
	return func(fields *cloudEventOptions) {
		fields.id = id
	}
}

func WithSource(source string) Option {
	return func(fields *cloudEventOptions) {
		fields.source = source
	}
}

func WithTime(time time.Time) Option {
	return func(fields *cloudEventOptions) {
		fields.time = time
	}
}

func WithExpiration(expirationTime time.Time) Option {
	return func(fields *cloudEventOptions) {
		fields.expirationTime = expirationTime
	}
}

func ToEvent(event proto.Message, opts ...Option) ([]byte, error) {
	now := time.Now()
	options := &cloudEventOptions{
		id:             uuid.NewString(),
		source:         "https://github.com/trento-project",
		time:           now,
		expirationTime: now.Add(defaultExpirationWindow),
	}

	for _, opt := range opts {
		opt(options)
	}

	data, err := anypb.New(event)
	if err != nil {
		return nil, err
	}

	timeAttr := CloudEventAttributeValue{
		Attr: &CloudEventAttributeValue_CeTimestamp{
			CeTimestamp: timestamppb.New(options.time),
		},
	}

	expirationAttr := CloudEventAttributeValue{
		Attr: &CloudEventAttributeValue_CeTimestamp{
			CeTimestamp: timestamppb.New(options.expirationTime),
		},
	}

	ce := CloudEvent{
		Id:          options.id,
		Source:      options.source,
		SpecVersion: "1.0",
		Type:        eventTypeFromProto(event),
		Data: &CloudEvent_ProtoData{
			ProtoData: data,
		},
		Attributes: map[string]*CloudEventAttributeValue{
			"time":       &timeAttr,
			"expiration": &expirationAttr,
		},
	}

	rawCe, err := proto.Marshal(&ce)
	if err != nil {
		return nil, err
	}

	return rawCe, nil
}

func FromEvent(src []byte, to proto.Message) error {
	var decodedCe CloudEvent
	err := proto.Unmarshal(src, &decodedCe)
	if err != nil {
		return err
	}

	err = anypb.UnmarshalTo(decodedCe.GetProtoData(), to, proto.UnmarshalOptions{})
	if err != nil {
		return err
	}

	// Check event expiration
	expirationAttr, found := decodedCe.GetAttributes()["expiration"]
	if !found {
		return ErrExpirationNotFound
	}

	expirationTS := expirationAttr.GetCeTimestamp()
	if expirationTS == nil {
		return ErrExpirationAttributeMalformed
	}

	eventExpiration := expirationTS.AsTime()
	if eventExpiration.Before(time.Now()) {
		return ErrEventExpired
	}

	return nil
}

func eventTypeFromProto(message proto.Message) string {
	return string(message.ProtoReflect().Descriptor().FullName())
}

func EventType(src []byte) (string, error) {
	var decodedCe CloudEvent
	err := proto.Unmarshal(src, &decodedCe)
	if err != nil {
		return "", err
	}

	any, err := anypb.UnmarshalNew(decodedCe.GetProtoData(), proto.UnmarshalOptions{})
	if err != nil {
		return "", err
	}

	name := any.ProtoReflect().Type().Descriptor().FullName()
	return string(name), nil
}

// ContentType returns the content type of used contracts
func ContentType() string {
	return "application/x-protobuf"
}
