defmodule Trento.Operations.V1.OperationTarget.ArgumentsEntry do
  @moduledoc false

  use Protobuf, map: true, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field :key, 1, type: :string
  field :value, 2, type: Google.Protobuf.Value
end

defmodule Trento.Operations.V1.OperationTarget do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field :agent_id, 1, type: :string, json_name: "agentId"

  field :arguments, 2,
    repeated: true,
    type: Trento.Operations.V1.OperationTarget.ArgumentsEntry,
    map: true
end