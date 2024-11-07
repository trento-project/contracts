defmodule Trento.Operations.V1.OperationStarted do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field :operation_id, 1, type: :string, json_name: "operationId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :operation_type, 3, type: :string, json_name: "operationType"
  field :targets, 4, repeated: true, type: Trento.Operations.V1.OperationTarget
end