defmodule Trento.Operations.V1.OperationResult do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :UPDATED, 0
  field :NOT_UPDATED, 1
  field :ROLLED_BACK, 2
  field :FAILED, 3
  field :ABORTED, 4
  field :ALREADY_RUNNING, 5
end

defmodule Trento.Operations.V1.OperationCompleted do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :operation_id, 1, type: :string, json_name: "operationId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :operation_type, 3, type: :string, json_name: "operationType"
  field :result, 4, type: Trento.Operations.V1.OperationResult, enum: true
end
