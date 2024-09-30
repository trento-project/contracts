defmodule Trento.Operations.V1.OperationResult do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :COMPLETED, 0
  field :ROLLED_BACK, 1
  field :FAILED, 2
end

defmodule Trento.Operations.V1.OperationCompleted do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :operation_id, 1, type: :string, json_name: "operationId"
  field :result, 2, type: Trento.Operations.V1.OperationResult, enum: true
  field :operation_type, 3, type: :string, json_name: "operationType"
end