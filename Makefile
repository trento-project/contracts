.PHONY: all go-generate

all: go-generate elixir-generate

go-generate: # Generate golang protobuf stubs
	protoc --experimental_allow_proto3_optional \
	--go_out go/pkg/events/ protobuf/*.proto

elixir-generate: # Generate elixir protobuf stubs
	protoc --elixir_out=./elixir/lib protobuf/*.proto