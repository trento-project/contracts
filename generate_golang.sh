#!/bin/bash

protoc --experimental_allow_proto3_optional --plugin $(go env GOPATH)/bin/protoc-gen-go --proto_path=protobuf --go_out golang/pkg/events/ protobuf/*.proto