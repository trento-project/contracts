defmodule Trento.Operations.V1.OperationExecutionRequestedTarget.ArgumentsEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: Google.Protobuf.Value
end

defmodule Trento.Operations.V1.OperationExecutionRequestedTarget do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

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

  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :operation_id, 1, type: :string, json_name: "operationId"
  field :targets, 2, repeated: true, type: Trento.Operations.V1.OperationExecutionRequestedTarget
end