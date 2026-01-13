defmodule Trento.Checks.V1.CheckCustomizationReset do
  @moduledoc false

  use Protobuf,
    full_name: "Trento.Checks.V1.CheckCustomizationReset",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :check_id, 1, type: :string, json_name: "checkId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :target_type, 3, type: :string, json_name: "targetType"
end
