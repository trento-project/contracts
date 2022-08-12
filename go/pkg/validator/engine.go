package validator

import (
	"embed"
)

//go:embed schema/*.json
var schemaFS embed.FS

func GetSchema(path string) (string, error) {
	b, err := schemaFS.ReadFile(path)
	if err != nil {
		return "", err
	}

	return string(b), nil
}
