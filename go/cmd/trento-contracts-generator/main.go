package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"path/filepath"

	"github.com/CDimonaco/generate"
)

var (
	pkg      = flag.String("package", "entities", "package name of generated code")
	path     = flag.String("path", "pkg/entities", "the path of the generated code")
	fileName = flag.String("fileName", "", "the go output file name")
)

type schemaEnvelope struct {
	Title string `json:"title"`
}

const importCodeTemplate = `

import (
	"encoding/json"
	"errors"

	"github.com/cdimonaco/contracts/go/pkg/validator"
	"github.com/xeipuuv/gojsonschema"
	"go.uber.org/multierr"
)
`
const validationCodeTemplate = `
// Validation code 

func New%sFromJson(rawJson []byte) (*%s, error) {
	var event %s
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

func (e *%s) Valid() error {
	schema, err := validator.GetSchema(%s)
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

`

func main() {
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage of %s:\n", "trento-contracts-generator")
		flag.PrintDefaults()
		fmt.Fprintln(os.Stderr, "  path")
		fmt.Fprintln(os.Stderr, "\tThe input JSON Schema file")
	}

	flag.Parse()

	inputFiles := flag.Args()
	if len(inputFiles) == 0 {
		fmt.Printf("no json schema files provided \n")
		flag.Usage()
		os.Exit(1)
	}

	if len(inputFiles) != 1 {
		fmt.Fprintf(os.Stderr, "error: you should provide only one json schema at once \n")
		os.Exit(1)
	}

	if *fileName == "" {
		fmt.Fprintf(os.Stderr, "error: please specify a go output file name with -fileName flag \n")
		flag.Usage()
		os.Exit(1)
	}

	inputSchema := inputFiles[0]
	var envelope schemaEnvelope

	schemaContent, err := os.ReadFile(inputSchema)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: could not open the provided json schema file \n")
		os.Exit(1)
	}

	err = json.Unmarshal(schemaContent, &envelope)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: could not unmarshal the provided json schema file \n")
		os.Exit(1)
	}

	if envelope.Title == "" {
		fmt.Fprintf(os.Stderr, "error: you should provide a title to the json schema! \n")
		os.Exit(1)
	}

	schemas, err := generate.ReadInputFiles([]string{inputSchema}, true)
	if err != nil {
		fmt.Fprint(os.Stderr, err.Error())
		os.Exit(1)
	}

	g := generate.New(schemas...)

	err = g.CreateTypes()
	if err != nil {
		fmt.Fprintln(os.Stderr, "Failure generating structs: ", err)
		os.Exit(1)
	}

	outputPath := fmt.Sprintf("%s/%s", *path, *fileName)

	fmt.Printf("\n generating go output file %s \n", outputPath)

	var w = bytes.NewBufferString("")

	generate.Output(w, g, *pkg, true, importCodeTemplate)

	_, file := filepath.Split(inputSchema)

	w.WriteString(
		fmt.Sprintf(
			validationCodeTemplate,
			envelope.Title,
			envelope.Title,
			envelope.Title,
			envelope.Title,
			"\"schemas/"+file+"\"",
		),
	)

	err = os.WriteFile(outputPath, w.Bytes(), 0644)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error during writing of file %s : %s", outputPath, err)
		os.Exit(1)
	}
}
