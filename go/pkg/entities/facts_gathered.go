// Code generated by schema-generate. DO NOT EDIT.

package entities


import (
	"encoding/json"
	"errors"

	"github.com/cdimonaco/contracts/go/pkg/validator"
	"github.com/xeipuuv/gojsonschema"
	"go.uber.org/multierr"
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

// Validation code 

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
	schema, err := validator.GetSchema("schemas/trento.checks.v1.FactsGathered.schema.json")
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

