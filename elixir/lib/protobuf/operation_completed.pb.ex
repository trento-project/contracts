defmodule Trento.Operations.V1.OperationResult do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "Trento.Operations.V1.OperationResult",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :UPDATED, 0
  field :NOT_UPDATED, 1
  field :ROLLED_BACK, 2
  field :FAILED, 3
  field :ABORTED, 4
  field :REQUEST_FAILED, 6
end

defmodule Trento.Operations.V1.OperationRequestFailedError do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "Trento.Operations.V1.OperationRequestFailedError",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :ARGUMENTS_MISSING, 0
  field :TARGETS_MISSING, 1
  field :ALREADY_RUNNING, 2
  field :UNKNOWN, 3
end

defmodule Trento.Operations.V1.OperationErrorDetails.TargetErrorsEntry do
  @moduledoc false

  use Protobuf,
    full_name: "Trento.Operations.V1.OperationErrorDetails.TargetErrorsEntry",
    map: true,
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Trento.Operations.V1.OperationErrorDetails do
  @moduledoc false

  use Protobuf,
    full_name: "Trento.Operations.V1.OperationErrorDetails",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :step, 1, type: :string

  field :target_errors, 2,
    repeated: true,
    type: Trento.Operations.V1.OperationErrorDetails.TargetErrorsEntry,
    json_name: "targetErrors",
    map: true
end

defmodule Trento.Operations.V1.OperationRequestFailedDetails do
  @moduledoc false

  use Protobuf,
    full_name: "Trento.Operations.V1.OperationRequestFailedDetails",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :error, 1, type: Trento.Operations.V1.OperationRequestFailedError, enum: true
end

defmodule Trento.Operations.V1.OperationCompleted do
  @moduledoc false

  use Protobuf,
    full_name: "Trento.Operations.V1.OperationCompleted",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  oneof :details, 0

  field :operation_id, 1, type: :string, json_name: "operationId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :operation_type, 3, type: :string, json_name: "operationType"
  field :result, 4, type: Trento.Operations.V1.OperationResult, enum: true

  field :error_details, 5,
    type: Trento.Operations.V1.OperationErrorDetails,
    json_name: "errorDetails",
    oneof: 0

  field :request_failed_details, 6,
    type: Trento.Operations.V1.OperationRequestFailedDetails,
    json_name: "requestFailedDetails",
    oneof: 0
end
