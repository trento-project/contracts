defmodule Trento.Checks.V1.Result do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.12.0", syntax: :proto3

  field :PASSING, 0
  field :WARNING, 1
  field :CRITICAL, 2
end

defmodule Trento.Checks.V1.ExecutionCompleted do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.12.0", syntax: :proto3

  field :execution_id, 1, type: :string, json_name: "executionId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :result, 3, type: Trento.Checks.V1.Result, enum: true

  field :resource_type, 4,
    type: Trento.Checks.V1.ResourceType,
    json_name: "resourceType",
    enum: true
end