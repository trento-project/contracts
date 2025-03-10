defmodule Trento.Checks.V1.CheckCustomizationReset do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field :check_id, 1, type: :string, json_name: "checkId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :target_type, 3, type: :string, json_name: "targetType"
end
