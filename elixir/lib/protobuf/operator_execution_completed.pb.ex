defmodule Trento.Operations.V1.OperationPhase do
  @moduledoc false

  use Protobuf, enum: true, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field :PLAN, 0
  field :COMMIT, 1
  field :VERIFY, 2
  field :ROLLBACK, 3
end

defmodule Trento.Operations.V1.Diff do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field :before, 1, type: Google.Protobuf.Value
  field :after, 2, type: Google.Protobuf.Value
end

defmodule Trento.Operations.V1.OperationResponse do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field :phase, 1, type: Trento.Operations.V1.OperationPhase, enum: true
  field :diff, 2, type: Trento.Operations.V1.Diff
end

defmodule Trento.Operations.V1.OperationResponseError do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field :phase, 1, type: Trento.Operations.V1.OperationPhase, enum: true
  field :message, 2, type: :string
end

defmodule Trento.Operations.V1.OperatorExecutionCompleted do
  @moduledoc false

  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  oneof :result, 0

  field :operation_id, 1, type: :string, json_name: "operationId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :step_number, 3, type: :int32, json_name: "stepNumber"
  field :agent_id, 4, type: :string, json_name: "agentId"
  field :value, 5, type: Trento.Operations.V1.OperationResponse, oneof: 0
  field :error, 6, type: Trento.Operations.V1.OperationResponseError, oneof: 0
end
