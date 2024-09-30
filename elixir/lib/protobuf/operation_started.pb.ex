defmodule Trento.Operations.V1.OperationStarted do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :operation_id, 1, type: :string, json_name: "operationId"
  field :agent_ids, 2, repeated: true, type: :string, json_name: "agentIds"
  field :operation_type, 3, type: :string, json_name: "operationType"
end