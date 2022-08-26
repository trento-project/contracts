package generator

import (
	"bytes"
	"text/template"
)

const ImportTemplate = `
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
`

type GenerationTemplateInput struct {
	EntityName  string
	SchemaPath  string
	EventSource string
	EventType   string
}

const entityGenerationTemplate = `
func New{{ .EntityName }}FromJson(rawJson []byte) (*{{ .EntityName }}, error) {
	var event {{ .EntityName }}
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

func (e *{{ .EntityName }}) Valid() error {
	schema, err := validator.GetSchema("schemas/{{ .SchemaPath }}")
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

func (e *{{ .EntityName }}) Source() string {
	return "trento/{{ .EventSource }}"
}


func (e *{{ .EntityName }}) Type() string {
	return "{{ .EventType }}"
}


func (e *{{ .EntityName }}) SerializeCloudEvent() ([]byte, error) {
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

func New{{ .EntityName }}FromJsonCloudEvent(rawJson []byte) (*{{ .EntityName }}, error) {
	var decoded {{ .EntityName }}

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


`

func GenerateEntity(payload GenerationTemplateInput) (string, error) {
	var buffer bytes.Buffer
	t := template.Must(template.New("entity-generation").Parse(entityGenerationTemplate))

	err := t.Execute(&buffer, payload)
	if err != nil {
		return "", err
	}

	return buffer.String(), nil
}
