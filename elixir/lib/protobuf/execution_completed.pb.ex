defmodule Trento.Checks.V1.ExpectationType do
  @moduledoc false
  use Protobuf, enum: true, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :EXPECT, 0
  field :EXPECT_SAME, 1
end

defmodule Trento.Checks.V1.ExpectationError do
  @moduledoc false
  use Protobuf, enum: true, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :FACT_MISSING_ERROR, 0
  field :ILLEGAL_EXPRESSION_ERROR, 1
end

defmodule Trento.Checks.V1.Result do
  @moduledoc false
  use Protobuf, enum: true, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :PASSING, 0
  field :WARNING, 1
  field :CRITICAL, 2
end

defmodule Trento.Checks.V1.ExpectationEvaluationError do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :name, 1, type: :string
  field :message, 2, type: :string
  field :type, 3, type: Trento.Checks.V1.ExpectationError, enum: true
end

defmodule Trento.Checks.V1.ExpectationEvaluation do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  oneof :return_value, 0

  field :name, 1, type: :string
  field :numeric_value, 2, type: :float, json_name: "numericValue", oneof: 0
  field :boolean_value, 3, type: :bool, json_name: "booleanValue", oneof: 0
  field :string_value, 4, type: :string, json_name: "stringValue", oneof: 0
  field :type, 5, type: Trento.Checks.V1.ExpectationType, enum: true
end

defmodule Trento.Checks.V1.ExpectationEvaluations do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  oneof :evaluations, 0

  field :evaluation_value, 1,
    type: Trento.Checks.V1.ExpectationEvaluation,
    json_name: "evaluationValue",
    oneof: 0

  field :evaluation_error, 2,
    type: Trento.Checks.V1.ExpectationEvaluationError,
    json_name: "evaluationError",
    oneof: 0
end

defmodule Trento.Checks.V1.AgentCheckResult do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :agent_id, 1, type: :string, json_name: "agentId"
  field :evaluations, 2, repeated: true, type: Trento.Checks.V1.ExpectationEvaluations
  field :facts, 3, repeated: true, type: Trento.Checks.V1.Fact
end

defmodule Trento.Checks.V1.ExpectationResult do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :name, 1, type: :string
  field :result, 2, type: :bool
  field :type, 3, type: Trento.Checks.V1.ExpectationType, enum: true
end

defmodule Trento.Checks.V1.CheckResult do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :check_id, 1, type: :string, json_name: "checkId"

  field :agents_check_results, 2,
    repeated: true,
    type: Trento.Checks.V1.AgentCheckResult,
    json_name: "agentsCheckResults"

  field :expectation_results, 3,
    repeated: true,
    type: Trento.Checks.V1.ExpectationResult,
    json_name: "expectationResults"

  field :result, 4, type: Trento.Checks.V1.Result, enum: true
end

defmodule Trento.Checks.V1.ExecutionCompleted do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.11.0", syntax: :proto3

  field :execution_id, 1, type: :string, json_name: "executionId"
  field :group_id, 2, type: :string, json_name: "groupId"
  field :result, 3, type: Trento.Checks.V1.Result, enum: true

  field :check_results, 4,
    repeated: true,
    type: Trento.Checks.V1.CheckResult,
    json_name: "checkResults"
end