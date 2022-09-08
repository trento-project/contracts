defmodule Trento.Checks.V1.FactDefinition do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :check_id, 1, type: :string, json_name: "checkId"
  field :name, 2, type: :string
  field :gatherer, 3, type: :string
  field :argument, 4, type: :string
end

defmodule Trento.Checks.V1.AgentFact do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :agent_id, 1, type: :string, json_name: "agentId"
  field :facts, 2, repeated: true, type: Trento.Checks.V1.FactDefinition
end

defmodule Trento.Checks.V1.FactsGatheringRequested do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :execution_id, 1, type: :string, json_name: "executionId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :targets, 3, repeated: true, type: :string
  field :facts, 4, repeated: true, type: Trento.Checks.V1.AgentFact
end