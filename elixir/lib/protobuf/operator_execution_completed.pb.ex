defmodule Trento.Operations.V1.OperatorPhase do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "Trento.Operations.V1.OperatorPhase",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :PLAN, 0
  field :COMMIT, 1
  field :VERIFY, 2
  field :ROLLBACK, 3
end

defmodule Trento.Operations.V1.OperatorDiff do
  @moduledoc false

  use Protobuf,
    full_name: "Trento.Operations.V1.OperatorDiff",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :before, 1, type: Google.Protobuf.Value
  field :after, 2, type: Google.Protobuf.Value
end

defmodule Trento.Operations.V1.OperatorResponse do
  @moduledoc false

  use Protobuf,
    full_name: "Trento.Operations.V1.OperatorResponse",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :phase, 1, type: Trento.Operations.V1.OperatorPhase, enum: true
  field :diff, 2, type: Trento.Operations.V1.OperatorDiff
end

defmodule Trento.Operations.V1.OperatorError do
  @moduledoc false

  use Protobuf,
    full_name: "Trento.Operations.V1.OperatorError",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  field :phase, 1, type: Trento.Operations.V1.OperatorPhase, enum: true
  field :message, 2, type: :string
end

defmodule Trento.Operations.V1.OperatorExecutionCompleted do
  @moduledoc false

  use Protobuf,
    full_name: "Trento.Operations.V1.OperatorExecutionCompleted",
    protoc_gen_elixir_version: "0.16.0",
    syntax: :proto3

  oneof :result, 0

  field :operation_id, 1, type: :string, json_name: "operationId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :step_number, 3, type: :int32, json_name: "stepNumber"
  field :agent_id, 4, type: :string, json_name: "agentId"
  field :value, 5, type: Trento.Operations.V1.OperatorResponse, oneof: 0
  field :error, 6, type: Trento.Operations.V1.OperatorError, oneof: 0
end
