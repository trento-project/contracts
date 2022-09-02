.PHONY: all clean elixir-generate
SCHEMAS = ../schema

all: elixir-generate make-schemas

elixir-generate: $(SCHEMAS)/*.json
	mix deps.get
	mix contracts.generate
	mix format

make-schemas:
	cp $(SCHEMAS)/*.json ./priv/schemas/

clean:
	rm -f ./lib/*.ex
