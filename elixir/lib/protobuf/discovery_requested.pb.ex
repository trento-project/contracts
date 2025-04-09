defmodule Trento.Discoveries.V1.DiscoveryRequested do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field :discovery_type, 1, type: :string, json_name: "discoveryType"
  field :targets, 2, repeated: true, type: :string
end
