defmodule Trento.Operations.V1.OperationRequested.ArgumentsEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: Google.Protobuf.Value
end

defmodule Trento.Operations.V1.OperationRequested do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :operation_id, 1, type: :string, json_name: "operationId"
  field :operation_type, 2, type: :string, json_name: "operationType"
  field :agent_ids, 3, repeated: true, type: :string, json_name: "agentIds"

  field :arguments, 4,
    repeated: true,
    type: Trento.Operations.V1.OperationRequested.ArgumentsEntry,
    map: true
end