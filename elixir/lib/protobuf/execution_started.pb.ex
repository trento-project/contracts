defmodule Trento.Checks.V1.ExecutionStarted do
  @moduledoc false

  use Protobuf,
    full_name: "Trento.Checks.V1.ExecutionStarted",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :execution_id, 1, type: :string, json_name: "executionId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :targets, 3, repeated: true, type: Trento.Checks.V1.Target
  field :target_type, 4, type: :string, json_name: "targetType"
end
