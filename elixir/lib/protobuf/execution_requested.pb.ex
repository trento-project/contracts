defmodule Trento.Checks.V1.ExecutionRequested.EnvEntry do
  @moduledoc false

  use Protobuf, map: true, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field :key, 1, type: :string
  field :value, 2, type: Google.Protobuf.Value
end

defmodule Trento.Checks.V1.ExecutionRequested do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.13.0"

  field :execution_id, 1, type: :string, json_name: "executionId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :targets, 3, repeated: true, type: Trento.Checks.V1.Target
  field :env, 4, repeated: true, type: Trento.Checks.V1.ExecutionRequested.EnvEntry, map: true
  field :target_type, 5, type: :string, json_name: "targetType"
end