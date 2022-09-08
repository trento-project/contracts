#!/bin/bash

protoc --elixir_out=./elixir/lib protobuf/*.proto
