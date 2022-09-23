.PHONY: all go-generate

GO_PATH=$(shell go env GOPATH)

all: go-generate elixir-generate

go-generate: # Generate golang protobuf stubs
	protoc --experimental_allow_proto3_optional \
	--plugin $(GO_PATH)/bin/protoc-gen-go \
	--go_out go/pkg/events/ protobuf/*.proto

elixir-generate: # Generate elixir protobuf stubs
	protoc --elixir_out=./elixir/lib protobuf/*.proto