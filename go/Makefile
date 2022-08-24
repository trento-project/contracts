.PHONY: all clean go-generate make-schemas
SCHEMAS = ../schema

all: go-generate make-schemas

go-generate: $(SCHEMAS)/*.json
	for file in $^; do \
		schema_name=$$(echo $${file} | cut -d'.' -f 7 | sed -r 's/([A-Z])/_\L\1/g' | sed 's/^_//' ); \
		go run cmd/trento-contracts-generator/main.go -fileName $${schema_name} $${file}; \
	done

add-schema:
	cat $(SCHEMAS)/schema.json.example | envsubst > $(SCHEMAS)/trento.$(project).v$(version).$(source).$(factname).schema.json

make-schemas:
	cp $(SCHEMAS)/*.json ./pkg/validator/schemas/

clean:
	rm -f ./pkg/validator/schemas/*.json
	rm -f ./pkg/gen/entities/*.go
