defmodule Trento.Checks.V1.CheckCustomizationApplied do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.15.0", syntax: :proto3

  field :check_id, 1, type: :string, json_name: "checkId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :target_type, 3, type: :string, json_name: "targetType"

  field :custom_values, 4,
    repeated: true,
    type: Trento.Checks.V1.CheckCustomValue,
    json_name: "customValues"
end
