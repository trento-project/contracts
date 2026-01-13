defmodule Trento.Operations.V1.OperationStarted do
  @moduledoc false

  use Protobuf,
    full_name: "Trento.Operations.V1.OperationStarted",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :operation_id, 1, type: :string, json_name: "operationId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :operation_type, 3, type: :string, json_name: "operationType"
  field :targets, 4, repeated: true, type: Trento.Operations.V1.OperationTarget
end
