defmodule Trento.Checks.V1.Target.AttributesEntry do
  @moduledoc false

  use Protobuf,
    full_name: "Trento.Checks.V1.Target.AttributesEntry",
    map: true,
    protoc_gen_elixir_version: "0.16.1",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: Google.Protobuf.Value
end

defmodule Trento.Checks.V1.Target do
  @moduledoc false

  use Protobuf,
    full_name: "Trento.Checks.V1.Target",
    protoc_gen_elixir_version: "0.16.1",
    syntax: :proto3

  field :agent_id, 1, type: :string, json_name: "agentId"
  field :checks, 2, repeated: true, type: :string
  field :attributes, 3, repeated: true, type: Trento.Checks.V1.Target.AttributesEntry, map: true
end
