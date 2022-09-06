.PHONY: all clean elixir-generate make-schemas
SCHEMAS = ../schema

all: make-schemas elixir-generate

elixir-generate: $(SCHEMAS)/*.json
	mix deps.get
	mix contracts.generate
	mix format

make-schemas:
	cp $(SCHEMAS)/*.json ./priv/schemas/

clean:
	rm -f ./lib/*.ex
