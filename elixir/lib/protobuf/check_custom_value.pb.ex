defmodule Trento.Checks.V1.CheckCustomValue do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  oneof :value, 0

  field :name, 1, type: :string
  field :string_value, 2, type: :string, json_name: "stringValue", oneof: 0
  field :int_value, 3, type: :int32, json_name: "intValue", oneof: 0
  field :bool_value, 4, type: :bool, json_name: "boolValue", oneof: 0
end
