defmodule Trento.Checks.V1.Target do
  @moduledoc false

  use Protobuf,
    full_name: "Trento.Checks.V1.Target",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :agent_id, 1, type: :string, json_name: "agentId"
  field :checks, 2, repeated: true, type: :string
end
