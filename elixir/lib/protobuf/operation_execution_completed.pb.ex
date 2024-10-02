defmodule Trento.Operations.V1.ErrorPhase do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :PLAN, 0
  field :COMMIT, 1
  field :VERIFY, 2
  field :ROLLBACK, 3
end

defmodule Trento.Operations.V1.OperationReportError do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :message, 1, type: :string

  field :error_phase, 2,
    type: Trento.Operations.V1.ErrorPhase,
    json_name: "errorPhase",
    enum: true
end

defmodule Trento.Operations.V1.OperationReportResponse.DiffEntry do
  @moduledoc false

  use Protobuf, map: true, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Trento.Operations.V1.OperationReportResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  field :result, 1, type: Trento.Operations.V1.OperationResult, enum: true

  field :diff, 2,
    repeated: true,
    type: Trento.Operations.V1.OperationReportResponse.DiffEntry,
    map: true
end

defmodule Trento.Operations.V1.OperationExecutionReport do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.13.0", syntax: :proto3

  oneof :operation_result, 0

  field :operation_id, 1, type: :string, json_name: "operationId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :step_number, 3, type: :int32, json_name: "stepNumber"
  field :agent_id, 4, type: :string, json_name: "agentId"
  field :response, 5, type: Trento.Operations.V1.OperationReportResponse, oneof: 0

  field :error_value, 6,
    type: Trento.Operations.V1.OperationReportError,
    json_name: "errorValue",
    oneof: 0
end