defmodule Trento.Operations.V1.OperatorExecutionRequestedTarget.ArgumentsEntry do
  @moduledoc false

  use Protobuf,
    full_name: "Trento.Operations.V1.OperatorExecutionRequestedTarget.ArgumentsEntry",
    map: true,
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: Google.Protobuf.Value
end

defmodule Trento.Operations.V1.OperatorExecutionRequestedTarget do
  @moduledoc false

  use Protobuf,
    full_name: "Trento.Operations.V1.OperatorExecutionRequestedTarget",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :agent_id, 1, type: :string, json_name: "agentId"

  field :arguments, 2,
    repeated: true,
    type: Trento.Operations.V1.OperatorExecutionRequestedTarget.ArgumentsEntry,
    map: true
end

defmodule Trento.Operations.V1.OperatorExecutionRequested do
  @moduledoc false

  use Protobuf,
    full_name: "Trento.Operations.V1.OperatorExecutionRequested",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :operation_id, 1, type: :string, json_name: "operationId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :step_number, 3, type: :int32, json_name: "stepNumber"
  field :operator, 4, type: :string
  field :targets, 5, repeated: true, type: Trento.Operations.V1.OperatorExecutionRequestedTarget
end
