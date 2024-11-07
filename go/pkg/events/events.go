package events

import (
	"crypto"
	"crypto/rsa"
	"crypto/sha256"
	"fmt"
	"time"

	"github.com/google/uuid"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/anypb"
	timestamppb "google.golang.org/protobuf/types/known/timestamppb"
)

type cloudEventOptions struct {
	id     string
	source string
	time   time.Time
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

func ToEvent(event proto.Message, opts ...Option) ([]byte, error) {
	options := &cloudEventOptions{
		id:     uuid.NewString(),
		source: "https://github.com/trento-project",
		time:   time.Now(),
	}
	for _, opt := range opts {
		opt(options)
	}

	data, err := anypb.New(event)
	if err != nil {
		return nil, err
	}

	attr := CloudEventAttributeValue{
		Attr: &CloudEventAttributeValue_CeTimestamp{
			CeTimestamp: timestamppb.New(options.time),
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
			"time": &attr,
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

func VerifySignature(src []byte, publicKey any) error {
	var decodedCe CloudEvent
	err := proto.Unmarshal(src, &decodedCe)
	if err != nil {
		return err
	}

	signatureAttr, found := decodedCe.GetAttributes()["signature"]
	if !found {
		return fmt.Errorf("signature not found")
	}

	signature := signatureAttr.GetCeBytes()

	timeAttr, found := decodedCe.GetAttributes()["time"]
	if !found {
		return fmt.Errorf("time not found")
	}

	time := fmt.Sprint(timeAttr.GetCeTimestamp().GetSeconds())
	data := decodedCe.GetProtoData().GetValue()

	hash := sha256.New()
	_, err = hash.Write(append(data, time...))
	if err != nil {
		return err
	}

	hashedEvent := hash.Sum(nil)

	return rsa.VerifyPKCS1v15(publicKey.(*rsa.PublicKey), crypto.SHA256, hashedEvent, signature)
}

// ContentType returns the content type of used contracts
func ContentType() string {
	return "application/x-protobuf"
}
