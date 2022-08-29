// Code generated by schema-generate. DO NOT EDIT.

package entities

import (
	"encoding/json"
	"time"

	"github.com/trento-project/contracts/go/pkg/validator"
	"github.com/xeipuuv/gojsonschema"
	"go.uber.org/multierr"

	cloudevents "github.com/cloudevents/sdk-go/v2"
	"github.com/google/uuid"
	"github.com/pkg/errors"
)

// FactsItems 
type FactsItems struct {
  Argument string `json:"argument,omitempty"`
  CheckId string `json:"check_id"`
  Gatherer string `json:"gatherer"`
  Name string `json:"name"`
}

// FactsRequestV1 
type FactsRequestV1 struct {
  ExecutionId string `json:"execution_id"`
  Facts []*FactsItems `json:"facts"`
}

func NewFactsRequestV1FromJson(rawJson []byte) (*FactsRequestV1, error) {
	var event FactsRequestV1
	err := json.Unmarshal(rawJson, &event)
	if err != nil {
		return nil, err
	}

	err = event.Valid()
	if err != nil {
		return nil, err
	}

	return &event, nil
}

func (e *FactsRequestV1) Valid() error {
	schema, err := validator.GetSchema("schemas/trento.checks.v1.wanda.FactsRequest.schema.json")
	if err != nil {
		return err
	}

	result, err := gojsonschema.Validate(gojsonschema.NewBytesLoader([]byte(schema)), gojsonschema.NewGoLoader(e))
	if err != nil {
		return err
	}

	var validationError error
	schemaErrors := result.Errors()
	for _, e := range schemaErrors {
		validationError = multierr.Append(validationError, errors.New(e.String()))
	}

	return validationError
}

func (e *FactsRequestV1) Source() string {
	return "trento/wanda"
}


func (e *FactsRequestV1) Type() string {
	return "trento.checks.v1.wanda.FactsRequest"
}


func (e *FactsRequestV1) SerializeCloudEvent() ([]byte, error) {
	err := e.Valid()
	if err != nil {
		return nil, errors.Wrap(err, "the entity is invalid")
	}

	event := cloudevents.NewEvent()
	event.SetID(uuid.New().String())
	event.SetSource(e.Source())
	event.SetTime(time.Now())
	event.SetType(e.Type())

	data, err := json.Marshal(e)
	if err != nil {
		return nil, errors.Wrapf(err, "could not serialize event %s", e.Type())
	}

	err = event.SetData(cloudevents.ApplicationJSON, data)
	if err != nil {
		return nil, errors.Wrapf(err, "could not set data for cloud event of type %s", e.Type())
	}
	evt, err := json.Marshal(event)
	if err != nil {
		return nil, errors.Wrapf(err, "could not serialize cloud event of type %s", e.Type())
	}

	return evt, nil
}

func NewFactsRequestV1FromJsonCloudEvent(rawJson []byte) (*FactsRequestV1, error) {
	var decoded FactsRequestV1

	event := cloudevents.NewEvent()

	err := json.Unmarshal(rawJson, &event)
	if err != nil {
		return nil, errors.Wrap(err, "could not serialize the json into a cloud event")
	}

	rawEvent := event.Data()

	err = json.Unmarshal(rawEvent, &decoded)
	if err != nil {
		return nil, errors.Wrap(err, "could not unmarshal the cloud event data into the proper event")
	}

	err = decoded.Valid()
	if err != nil {
		return nil, errors.Wrap(err, "the entity is invalid")
	}

	return &decoded, nil
}


