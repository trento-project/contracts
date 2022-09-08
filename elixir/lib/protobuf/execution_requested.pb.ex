defmodule Trento.Checks.V1.Target do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :agent_id, 1, type: :string, json_name: "agentId"
  field :checks, 2, repeated: true, type: :string
end

defmodule Trento.Checks.V1.ExecutionRequested do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :execution_id, 1, type: :string, json_name: "executionId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :targets, 3, repeated: true, type: Trento.Checks.V1.Target
end