.PHONY: all clean elixir-generate
SCHEMAS = ../schema

all: elixir-generate

elixir-generate: $(SCHEMAS)/*.json
	mix deps.get
	mix contracts.generate
	mix format

clean:
	rm -f ./lib/*.ex
