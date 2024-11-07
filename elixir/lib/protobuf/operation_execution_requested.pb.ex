defmodule Trento.Operations.V1.OperationExecutionRequestedTarget.ArgumentsEntry do
  @moduledoc false

  use Protobuf, map: true, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field :key, 1, type: :string
  field :value, 2, type: Google.Protobuf.Value
end

defmodule Trento.Operations.V1.OperationExecutionRequestedTarget do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field :agent_id, 1, type: :string, json_name: "agentId"
  field :name, 2, type: :string
  field :operator, 3, type: :string

  field :arguments, 4,
    repeated: true,
    type: Trento.Operations.V1.OperationExecutionRequestedTarget.ArgumentsEntry,
    map: true
end

defmodule Trento.Operations.V1.OperationExecutionRequested do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field :operation_id, 1, type: :string, json_name: "operationId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :step_number, 3, type: :int32, json_name: "stepNumber"
  field :targets, 4, repeated: true, type: Trento.Operations.V1.OperationExecutionRequestedTarget
end