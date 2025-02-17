defmodule CloudEvents.CloudEvent.AttributesEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: CloudEvents.CloudEventAttributeValue
end

defmodule CloudEvents.CloudEvent do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  oneof :data, 0

  field :id, 1, type: :string
  field :source, 2, type: :string
  field :spec_version, 3, type: :string, json_name: "specVersion"
  field :type, 4, type: :string
  field :attributes, 5, repeated: true, type: CloudEvents.CloudEvent.AttributesEntry, map: true
  field :binary_data, 6, type: :bytes, json_name: "binaryData", oneof: 0
  field :text_data, 7, type: :string, json_name: "textData", oneof: 0
  field :proto_data, 8, type: Google.Protobuf.Any, json_name: "protoData", oneof: 0
end

defmodule CloudEvents.CloudEventAttributeValue do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.0", syntax: :proto3

  oneof :attr, 0

  field :ce_boolean, 1, type: :bool, json_name: "ceBoolean", oneof: 0
  field :ce_integer, 2, type: :int32, json_name: "ceInteger", oneof: 0
  field :ce_string, 3, type: :string, json_name: "ceString", oneof: 0
  field :ce_bytes, 4, type: :bytes, json_name: "ceBytes", oneof: 0
  field :ce_uri, 5, type: :string, json_name: "ceUri", oneof: 0
  field :ce_uri_ref, 6, type: :string, json_name: "ceUriRef", oneof: 0
  field :ce_timestamp, 7, type: Google.Protobuf.Timestamp, json_name: "ceTimestamp", oneof: 0
end
