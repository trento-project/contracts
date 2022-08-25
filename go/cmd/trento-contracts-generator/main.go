package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/CDimonaco/generate"
	"github.com/cdimonaco/contracts/go/internal/generator"
)

var (
	pkg      = flag.String("package", "entities", "package name of generated code")
	path     = flag.String("path", "pkg/gen/entities", "the path of the generated code")
	fileName = flag.String("fileName", "", "the go output file name")
)

type schemaEnvelope struct {
	Title string `json:"title"`
}

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

	var w = bytes.NewBufferString("")

	generate.Output(w, g, *pkg, true, generator.ImportTemplate)

	_, file := filepath.Split(inputSchema)

	fileParts := strings.Split(file, ".")

	// take the version part of the file, following the naming convention in readme
	// `trento.[project].[version].[source].[SchemaName].schema.json`

	version := fileParts[2]
	source := fileParts[3]
	eventType := strings.Join(fileParts[:len(fileParts)-2], ".")

	composedFileName := fmt.Sprintf("%s_%s.go", *fileName, version)

	outputPath := fmt.Sprintf("%s/%s", *path, composedFileName)

	fmt.Printf(
		"\n generating go output file %s - version: %s - source: %s - evenType: %s \n",
		outputPath,
		version,
		source,
		eventType,
	)

	generatedCode, err := generator.GenerateEntity(generator.GenerationTemplateInput{
		EntityName:  envelope.Title,
		SchemaPath:  file,
		EventSource: source,
		EventType:   eventType,
	})

	if err != nil {
		panic(err)
	}

	w.WriteString(
		generatedCode,
	)

	err = os.WriteFile(outputPath, w.Bytes(), 0644)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error during writing of file %s : %s", outputPath, err)
		os.Exit(1)
	}
}
