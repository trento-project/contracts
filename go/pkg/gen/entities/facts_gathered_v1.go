// Code generated by schema-generate. DO NOT EDIT.

package entities

import (
	"encoding/json"
	"time"

	"github.com/cdimonaco/contracts/go/pkg/validator"
	"github.com/xeipuuv/gojsonschema"
	"go.uber.org/multierr"

	cloudevents "github.com/cloudevents/sdk-go/v2"
	"github.com/google/uuid"
	"github.com/pkg/errors"
)

// Error 
type Error struct {
  Message string `json:"message"`
  Type string `json:"type"`
}

// FactsGatheredItems 
type FactsGatheredItems struct {
  CheckId string `json:"check_id"`
  Error *Error `json:"error,omitempty"`
  Name string `json:"name"`
  Value interface{} `json:"value"`
}

// FactsGatheredV1 
type FactsGatheredV1 struct {
  AgentId string `json:"agent_id"`
  ExecutionId string `json:"execution_id"`
  FactsGathered []*FactsGatheredItems `json:"facts_gathered"`
}

func NewFactsGatheredV1FromJson(rawJson []byte) (*FactsGatheredV1, error) {
	var event FactsGatheredV1
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

func (e *FactsGatheredV1) Valid() error {
	schema, err := validator.GetSchema("schemas/trento.checks.v1.agent.FactsGathered.schema.json")
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

func (e *FactsGatheredV1) Source() string {
	return "trento/agent"
}


func (e *FactsGatheredV1) Type() string {
	return "trento.checks.v1.agent.FactsGathered"
}


func (e *FactsGatheredV1) SerializeCloudEvent() ([]byte, error) {
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

	evt, err := json.Marshal(event)
	if err != nil {
		return nil, errors.Wrapf(err, "could not serialize cloud event of type %s", e.Type())
	}

	return evt, nil
}

func NewFactsGatheredV1FromJsonCloudEvent(rawJson []byte) (*FactsGatheredV1, error) {
	var decoded FactsGatheredV1

	event := cloudevents.NewEvent()

	err := json.Unmarshal(rawJson, &decoded)
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


