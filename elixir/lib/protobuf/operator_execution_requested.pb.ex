defmodule Trento.Operations.V1.OperatorExecutionRequestedTarget.ArgumentsEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: Google.Protobuf.Value
end

defmodule Trento.Operations.V1.OperatorExecutionRequestedTarget do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field :agent_id, 1, type: :string, json_name: "agentId"
  field :operator, 2, type: :string

  field :arguments, 3,
    repeated: true,
    type: Trento.Operations.V1.OperatorExecutionRequestedTarget.ArgumentsEntry,
    map: true
end

defmodule Trento.Operations.V1.OperatorExecutionRequested do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field :operation_id, 1, type: :string, json_name: "operationId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :step_number, 3, type: :int32, json_name: "stepNumber"
  field :targets, 4, repeated: true, type: Trento.Operations.V1.OperatorExecutionRequestedTarget
end
