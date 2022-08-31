.PHONY: all clean elixir-generate
SCHEMAS = ../schema

all: elixir-generate

elixir-generate: $(SCHEMAS)/*.json
	mix deps.get
	mix contracts.generate

clean:
	rm -f ./lib/*.ex
