defmodule Trento.Checks.V1.TargetType do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.12.0", syntax: :proto3

  field :TARGET_TYPE_UNSPECIFIED, 0
  field :CLUSTER, 1
  field :HOST, 2
end