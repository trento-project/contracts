package core

import (
	"encoding/json"

	cloudevents "github.com/cloudevents/sdk-go/v2"
	"github.com/pkg/errors"
)

type TrentoEvent interface {
	Type() string
	Source() string
	Json() ([]byte, error)
	Valid() error
}

func GetContractTypeFromJson(rawJson []byte) (string, error) {
	event := cloudevents.NewEvent()

	err := json.Unmarshal(rawJson, &event)
	if err != nil {
		return "", errors.Wrap(err, "could not serialize the json into a cloud event")
	}

	return event.Type(), nil
}
