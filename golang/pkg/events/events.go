package events

import (
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/anypb"
)

func ToEvent(event proto.Message, source string, id string) ([]byte, error) {
	data, err := anypb.New(event)
	if err != nil {
		return nil, err
	}

	ce := CloudEvent{
		Id:          id,
		Source:      source,
		SpecVersion: "1.0",
		Type:        eventTypeFromProto(event),
		Data: &CloudEvent_ProtoData{
			ProtoData: data,
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

// ContentType returns the content type of used contracts
func ContentType() string {
	return "application/x-protobuf"
}