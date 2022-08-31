defmodule Trento.Events.Checks.V1.Wanda.ExecutionCompleted do
  use Ecto.Schema
  import Ecto.Changeset
  import PolymorphicEmbed
  @moduledoc false
  @primary_key false
  @required_fields [:execution_id, :group_id, :result, :check_results]
  @derive Jason.Encoder
  embedded_schema do
    [
      embeds_many(:check_results, CheckResults, primary_key: false) do
        @derive Jason.Encoder
        @required_fields [:agents_check_results, :check_id, :expectation_results, :result]
        import PolymorphicEmbed

        [
          embeds_many(:agents_check_results, AgentsCheckResults, primary_key: false) do
            @derive Jason.Encoder
            @required_fields [:agent_id, :expectation_evaluations, :facts]
            import PolymorphicEmbed

            [
              field(:agent_id, :string),
              (
                [
                  defmodule ExpectationEvaluation do
                    use Ecto.Schema
                    @primary_key false
                    @derive Jason.Encoder
                    @moduledoc false
                    @required_fields [:name, :return_value, :type]
                    embedded_schema do
                      [
                        field(:name, :string),
                        (
                          defmodule ReturnValue do
                            use Ecto.Type
                            @moduledoc false
                            def type do
                              :return_value
                            end

                            [
                              def cast(value) when Elixir.Kernel.is_number(value) do
                                {:ok, value}
                              end,
                              def cast(value) when Elixir.Kernel.is_boolean(value) do
                                {:ok, value}
                              end,
                              def cast(value) when Elixir.Kernel.is_bitstring(value) do
                                {:ok, value}
                              end
                            ]

                            def cast(_) do
                              :error
                            end

                            [
                              def dump(value) when Elixir.Kernel.is_number(value) do
                                value
                              end,
                              def dump(value) when Elixir.Kernel.is_boolean(value) do
                                value
                              end,
                              def dump(value) when Elixir.Kernel.is_bitstring(value) do
                                value
                              end
                            ]

                            [
                              def load(value) when Elixir.Kernel.is_number(value) do
                                {:ok, value}
                              end,
                              def load(value) when Elixir.Kernel.is_boolean(value) do
                                {:ok, value}
                              end,
                              def load(value) when Elixir.Kernel.is_bitstring(value) do
                                {:ok, value}
                              end
                            ]
                          end

                          field(:return_value, ReturnValue)
                        ),
                        field(:type, :string)
                      ]
                    end

                    (
                      @doc "Returns an ok tuple if the params are valid, otherwise returns `{:error, errors}`.\nAccepts a map or a list of maps.\n"
                      def new(structs) when is_list(structs) do
                        structs
                        |> Enum.map(fn item -> __MODULE__.new(item) end)
                        |> Enum.group_by(fn {is_valid, _} -> is_valid end, fn {_, decoding_value} ->
                          decoding_value
                        end)
                        |> decoding_results()
                      end

                      def new(params) do
                        case changeset(struct(__MODULE__), params) do
                          %{valid?: true} = changes ->
                            {:ok, apply_changes(changes)}

                          changes ->
                            {:error,
                             Ecto.Changeset.traverse_errors(changes, fn {msg, _} -> msg end)}
                        end
                      end

                      @doc "Returns new struct(s) if the params are valid, otherwise raises a `RuntimeError`.\n"
                      def new!(params) do
                        case new(params) do
                          {:ok, value} -> value
                          {:error, reason} -> raise RuntimeError, message: inspect(reason)
                        end
                      end

                      @dialyzer {:no_match, changeset: 2}
                      @doc "Casts the fields by using Ecto reflection,\nvalidates the required ones and returns a changeset.\n"
                      def changeset(struct, params) do
                        changeset =
                          struct
                          |> cast(params, fields())
                          |> validate_required_fields(@required_fields)

                        embedded_cast_changeset =
                          Enum.reduce(embedded_fields(), changeset, fn field, changeset ->
                            cast_and_validate_required_embed(changeset, field, @required_fields)
                          end)

                        Enum.reduce(polymorphic_fields(), embedded_cast_changeset, fn field,
                                                                                      changeset ->
                          cast_polymorphic_embed(changeset, field)
                        end)
                      end

                      def validate_required_fields(changeset, nil) do
                        changeset
                      end

                      def validate_required_fields(changeset, :all) do
                        Ecto.Changeset.validate_required(changeset, fields())
                      end

                      def validate_required_fields(changeset, required_fields) do
                        Ecto.Changeset.validate_required(
                          changeset,
                          Enum.filter(fields(), fn field -> field in required_fields end)
                        )
                      end

                      def cast_and_validate_required_embed(changeset, field, nil) do
                        cast_embed(changeset, field)
                      end

                      def cast_and_validate_required_embed(changeset, field, :all) do
                        cast_embed(changeset, field, required: true)
                      end

                      def cast_and_validate_required_embed(changeset, field, required_fields) do
                        cast_embed(changeset, field, required: field in required_fields)
                      end

                      def decoding_results(%{error: decoding_errors}) do
                        {:error, decoding_errors}
                      end

                      def decoding_results(%{ok: decoding_results}) do
                        {:ok, decoding_results}
                      end

                      def decoding_results(_) do
                        {:ok, []}
                      end

                      def fields() do
                        non_embedded_fields =
                          __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)

                        non_embedded_fields -- polymorphic_fields()
                      end

                      def embedded_fields do
                        __MODULE__.__schema__(:embeds)
                      end

                      def polymorphic_fields() do
                        __MODULE__.__schema__(:fields)
                        |> Enum.filter(fn field ->
                          try do
                            [_ | _] =
                              __MODULE__.__schema__(:type, field)
                              |> case do
                                {:parameterized, PolymorphicEmbed, options} ->
                                  Map.put(options, :array?, false)

                                {:array, {:parameterized, PolymorphicEmbed, options}} ->
                                  Map.put(options, :array?, true)

                                {_, {:parameterized, PolymorphicEmbed, options}} ->
                                  Map.put(options, :array?, false)

                                nil ->
                                  raise ArgumentError, "#{field} is not a polymorphic embed"
                              end
                              |> Map.get(:types_metadata)
                              |> Enum.map(fn %{type: type} -> type end)
                          rescue
                            _ -> false
                          end
                        end)
                      end

                      defoverridable changeset: 2
                    )
                  end,
                  defmodule ExpectationEvaluationError do
                    use Ecto.Schema
                    @primary_key false
                    @derive Jason.Encoder
                    @moduledoc false
                    @required_fields [:name, :message, :type]
                    embedded_schema do
                      [field(:message, :string), field(:name, :string), field(:type, :string)]
                    end

                    (
                      @doc "Returns an ok tuple if the params are valid, otherwise returns `{:error, errors}`.\nAccepts a map or a list of maps.\n"
                      def new(structs) when is_list(structs) do
                        structs
                        |> Enum.map(fn item -> __MODULE__.new(item) end)
                        |> Enum.group_by(fn {is_valid, _} -> is_valid end, fn {_, decoding_value} ->
                          decoding_value
                        end)
                        |> decoding_results()
                      end

                      def new(params) do
                        case changeset(struct(__MODULE__), params) do
                          %{valid?: true} = changes ->
                            {:ok, apply_changes(changes)}

                          changes ->
                            {:error,
                             Ecto.Changeset.traverse_errors(changes, fn {msg, _} -> msg end)}
                        end
                      end

                      @doc "Returns new struct(s) if the params are valid, otherwise raises a `RuntimeError`.\n"
                      def new!(params) do
                        case new(params) do
                          {:ok, value} -> value
                          {:error, reason} -> raise RuntimeError, message: inspect(reason)
                        end
                      end

                      @dialyzer {:no_match, changeset: 2}
                      @doc "Casts the fields by using Ecto reflection,\nvalidates the required ones and returns a changeset.\n"
                      def changeset(struct, params) do
                        changeset =
                          struct
                          |> cast(params, fields())
                          |> validate_required_fields(@required_fields)

                        embedded_cast_changeset =
                          Enum.reduce(embedded_fields(), changeset, fn field, changeset ->
                            cast_and_validate_required_embed(changeset, field, @required_fields)
                          end)

                        Enum.reduce(polymorphic_fields(), embedded_cast_changeset, fn field,
                                                                                      changeset ->
                          cast_polymorphic_embed(changeset, field)
                        end)
                      end

                      def validate_required_fields(changeset, nil) do
                        changeset
                      end

                      def validate_required_fields(changeset, :all) do
                        Ecto.Changeset.validate_required(changeset, fields())
                      end

                      def validate_required_fields(changeset, required_fields) do
                        Ecto.Changeset.validate_required(
                          changeset,
                          Enum.filter(fields(), fn field -> field in required_fields end)
                        )
                      end

                      def cast_and_validate_required_embed(changeset, field, nil) do
                        cast_embed(changeset, field)
                      end

                      def cast_and_validate_required_embed(changeset, field, :all) do
                        cast_embed(changeset, field, required: true)
                      end

                      def cast_and_validate_required_embed(changeset, field, required_fields) do
                        cast_embed(changeset, field, required: field in required_fields)
                      end

                      def decoding_results(%{error: decoding_errors}) do
                        {:error, decoding_errors}
                      end

                      def decoding_results(%{ok: decoding_results}) do
                        {:ok, decoding_results}
                      end

                      def decoding_results(_) do
                        {:ok, []}
                      end

                      def fields() do
                        non_embedded_fields =
                          __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)

                        non_embedded_fields -- polymorphic_fields()
                      end

                      def embedded_fields do
                        __MODULE__.__schema__(:embeds)
                      end

                      def polymorphic_fields() do
                        __MODULE__.__schema__(:fields)
                        |> Enum.filter(fn field ->
                          try do
                            [_ | _] =
                              __MODULE__.__schema__(:type, field)
                              |> case do
                                {:parameterized, PolymorphicEmbed, options} ->
                                  Map.put(options, :array?, false)

                                {:array, {:parameterized, PolymorphicEmbed, options}} ->
                                  Map.put(options, :array?, true)

                                {_, {:parameterized, PolymorphicEmbed, options}} ->
                                  Map.put(options, :array?, false)

                                nil ->
                                  raise ArgumentError, "#{field} is not a polymorphic embed"
                              end
                              |> Map.get(:types_metadata)
                              |> Enum.map(fn %{type: type} -> type end)
                          rescue
                            _ -> false
                          end
                        end)
                      end

                      defoverridable changeset: 2
                    )
                  end
                ]

                polymorphic_embeds_many(:expectation_evaluations,
                  types: [
                    expectation_evaluation: [
                      module: ExpectationEvaluation,
                      identify_by_fields: [:name, :return_value, :type]
                    ],
                    expectation_evaluation_error: [
                      module: ExpectationEvaluationError,
                      identify_by_fields: [:message, :name, :type]
                    ]
                  ],
                  on_type_not_found: :raise,
                  on_replace: :delete
                )
              ),
              nil
            ]

            (
              @doc "Returns an ok tuple if the params are valid, otherwise returns `{:error, errors}`.\nAccepts a map or a list of maps.\n"
              def new(structs) when is_list(structs) do
                structs
                |> Enum.map(fn item -> __MODULE__.new(item) end)
                |> Enum.group_by(fn {is_valid, _} -> is_valid end, fn {_, decoding_value} ->
                  decoding_value
                end)
                |> decoding_results()
              end

              def new(params) do
                case changeset(struct(__MODULE__), params) do
                  %{valid?: true} = changes ->
                    {:ok, apply_changes(changes)}

                  changes ->
                    {:error, Ecto.Changeset.traverse_errors(changes, fn {msg, _} -> msg end)}
                end
              end

              @doc "Returns new struct(s) if the params are valid, otherwise raises a `RuntimeError`.\n"
              def new!(params) do
                case new(params) do
                  {:ok, value} -> value
                  {:error, reason} -> raise RuntimeError, message: inspect(reason)
                end
              end

              @dialyzer {:no_match, changeset: 2}
              @doc "Casts the fields by using Ecto reflection,\nvalidates the required ones and returns a changeset.\n"
              def changeset(struct, params) do
                changeset =
                  struct |> cast(params, fields()) |> validate_required_fields(@required_fields)

                embedded_cast_changeset =
                  Enum.reduce(embedded_fields(), changeset, fn field, changeset ->
                    cast_and_validate_required_embed(changeset, field, @required_fields)
                  end)

                Enum.reduce(polymorphic_fields(), embedded_cast_changeset, fn field, changeset ->
                  cast_polymorphic_embed(changeset, field)
                end)
              end

              def validate_required_fields(changeset, nil) do
                changeset
              end

              def validate_required_fields(changeset, :all) do
                Ecto.Changeset.validate_required(changeset, fields())
              end

              def validate_required_fields(changeset, required_fields) do
                Ecto.Changeset.validate_required(
                  changeset,
                  Enum.filter(fields(), fn field -> field in required_fields end)
                )
              end

              def cast_and_validate_required_embed(changeset, field, nil) do
                cast_embed(changeset, field)
              end

              def cast_and_validate_required_embed(changeset, field, :all) do
                cast_embed(changeset, field, required: true)
              end

              def cast_and_validate_required_embed(changeset, field, required_fields) do
                cast_embed(changeset, field, required: field in required_fields)
              end

              def decoding_results(%{error: decoding_errors}) do
                {:error, decoding_errors}
              end

              def decoding_results(%{ok: decoding_results}) do
                {:ok, decoding_results}
              end

              def decoding_results(_) do
                {:ok, []}
              end

              def fields() do
                non_embedded_fields =
                  __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)

                non_embedded_fields -- polymorphic_fields()
              end

              def embedded_fields do
                __MODULE__.__schema__(:embeds)
              end

              def polymorphic_fields() do
                __MODULE__.__schema__(:fields)
                |> Enum.filter(fn field ->
                  try do
                    [_ | _] =
                      __MODULE__.__schema__(:type, field)
                      |> case do
                        {:parameterized, PolymorphicEmbed, options} ->
                          Map.put(options, :array?, false)

                        {:array, {:parameterized, PolymorphicEmbed, options}} ->
                          Map.put(options, :array?, true)

                        {_, {:parameterized, PolymorphicEmbed, options}} ->
                          Map.put(options, :array?, false)

                        nil ->
                          raise ArgumentError, "#{field} is not a polymorphic embed"
                      end
                      |> Map.get(:types_metadata)
                      |> Enum.map(fn %{type: type} -> type end)
                  rescue
                    _ -> false
                  end
                end)
              end

              defoverridable changeset: 2
            )
          end,
          field(:check_id, :string),
          embeds_many(:expectation_results, ExpectationResults, primary_key: false) do
            @derive Jason.Encoder
            @required_fields [:name, :result, :type]
            import PolymorphicEmbed
            [field(:name, :string), field(:result, :boolean), field(:type, :string)]

            (
              @doc "Returns an ok tuple if the params are valid, otherwise returns `{:error, errors}`.\nAccepts a map or a list of maps.\n"
              def new(structs) when is_list(structs) do
                structs
                |> Enum.map(fn item -> __MODULE__.new(item) end)
                |> Enum.group_by(fn {is_valid, _} -> is_valid end, fn {_, decoding_value} ->
                  decoding_value
                end)
                |> decoding_results()
              end

              def new(params) do
                case changeset(struct(__MODULE__), params) do
                  %{valid?: true} = changes ->
                    {:ok, apply_changes(changes)}

                  changes ->
                    {:error, Ecto.Changeset.traverse_errors(changes, fn {msg, _} -> msg end)}
                end
              end

              @doc "Returns new struct(s) if the params are valid, otherwise raises a `RuntimeError`.\n"
              def new!(params) do
                case new(params) do
                  {:ok, value} -> value
                  {:error, reason} -> raise RuntimeError, message: inspect(reason)
                end
              end

              @dialyzer {:no_match, changeset: 2}
              @doc "Casts the fields by using Ecto reflection,\nvalidates the required ones and returns a changeset.\n"
              def changeset(struct, params) do
                changeset =
                  struct |> cast(params, fields()) |> validate_required_fields(@required_fields)

                embedded_cast_changeset =
                  Enum.reduce(embedded_fields(), changeset, fn field, changeset ->
                    cast_and_validate_required_embed(changeset, field, @required_fields)
                  end)

                Enum.reduce(polymorphic_fields(), embedded_cast_changeset, fn field, changeset ->
                  cast_polymorphic_embed(changeset, field)
                end)
              end

              def validate_required_fields(changeset, nil) do
                changeset
              end

              def validate_required_fields(changeset, :all) do
                Ecto.Changeset.validate_required(changeset, fields())
              end

              def validate_required_fields(changeset, required_fields) do
                Ecto.Changeset.validate_required(
                  changeset,
                  Enum.filter(fields(), fn field -> field in required_fields end)
                )
              end

              def cast_and_validate_required_embed(changeset, field, nil) do
                cast_embed(changeset, field)
              end

              def cast_and_validate_required_embed(changeset, field, :all) do
                cast_embed(changeset, field, required: true)
              end

              def cast_and_validate_required_embed(changeset, field, required_fields) do
                cast_embed(changeset, field, required: field in required_fields)
              end

              def decoding_results(%{error: decoding_errors}) do
                {:error, decoding_errors}
              end

              def decoding_results(%{ok: decoding_results}) do
                {:ok, decoding_results}
              end

              def decoding_results(_) do
                {:ok, []}
              end

              def fields() do
                non_embedded_fields =
                  __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)

                non_embedded_fields -- polymorphic_fields()
              end

              def embedded_fields do
                __MODULE__.__schema__(:embeds)
              end

              def polymorphic_fields() do
                __MODULE__.__schema__(:fields)
                |> Enum.filter(fn field ->
                  try do
                    [_ | _] =
                      __MODULE__.__schema__(:type, field)
                      |> case do
                        {:parameterized, PolymorphicEmbed, options} ->
                          Map.put(options, :array?, false)

                        {:array, {:parameterized, PolymorphicEmbed, options}} ->
                          Map.put(options, :array?, true)

                        {_, {:parameterized, PolymorphicEmbed, options}} ->
                          Map.put(options, :array?, false)

                        nil ->
                          raise ArgumentError, "#{field} is not a polymorphic embed"
                      end
                      |> Map.get(:types_metadata)
                      |> Enum.map(fn %{type: type} -> type end)
                  rescue
                    _ -> false
                  end
                end)
              end

              defoverridable changeset: 2
            )
          end,
          field(:result, :string)
        ]

        (
          @doc "Returns an ok tuple if the params are valid, otherwise returns `{:error, errors}`.\nAccepts a map or a list of maps.\n"
          def new(structs) when is_list(structs) do
            structs
            |> Enum.map(fn item -> __MODULE__.new(item) end)
            |> Enum.group_by(fn {is_valid, _} -> is_valid end, fn {_, decoding_value} ->
              decoding_value
            end)
            |> decoding_results()
          end

          def new(params) do
            case changeset(struct(__MODULE__), params) do
              %{valid?: true} = changes -> {:ok, apply_changes(changes)}
              changes -> {:error, Ecto.Changeset.traverse_errors(changes, fn {msg, _} -> msg end)}
            end
          end

          @doc "Returns new struct(s) if the params are valid, otherwise raises a `RuntimeError`.\n"
          def new!(params) do
            case new(params) do
              {:ok, value} -> value
              {:error, reason} -> raise RuntimeError, message: inspect(reason)
            end
          end

          @dialyzer {:no_match, changeset: 2}
          @doc "Casts the fields by using Ecto reflection,\nvalidates the required ones and returns a changeset.\n"
          def changeset(struct, params) do
            changeset =
              struct |> cast(params, fields()) |> validate_required_fields(@required_fields)

            embedded_cast_changeset =
              Enum.reduce(embedded_fields(), changeset, fn field, changeset ->
                cast_and_validate_required_embed(changeset, field, @required_fields)
              end)

            Enum.reduce(polymorphic_fields(), embedded_cast_changeset, fn field, changeset ->
              cast_polymorphic_embed(changeset, field)
            end)
          end

          def validate_required_fields(changeset, nil) do
            changeset
          end

          def validate_required_fields(changeset, :all) do
            Ecto.Changeset.validate_required(changeset, fields())
          end

          def validate_required_fields(changeset, required_fields) do
            Ecto.Changeset.validate_required(
              changeset,
              Enum.filter(fields(), fn field -> field in required_fields end)
            )
          end

          def cast_and_validate_required_embed(changeset, field, nil) do
            cast_embed(changeset, field)
          end

          def cast_and_validate_required_embed(changeset, field, :all) do
            cast_embed(changeset, field, required: true)
          end

          def cast_and_validate_required_embed(changeset, field, required_fields) do
            cast_embed(changeset, field, required: field in required_fields)
          end

          def decoding_results(%{error: decoding_errors}) do
            {:error, decoding_errors}
          end

          def decoding_results(%{ok: decoding_results}) do
            {:ok, decoding_results}
          end

          def decoding_results(_) do
            {:ok, []}
          end

          def fields() do
            non_embedded_fields = __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
            non_embedded_fields -- polymorphic_fields()
          end

          def embedded_fields do
            __MODULE__.__schema__(:embeds)
          end

          def polymorphic_fields() do
            __MODULE__.__schema__(:fields)
            |> Enum.filter(fn field ->
              try do
                [_ | _] =
                  __MODULE__.__schema__(:type, field)
                  |> case do
                    {:parameterized, PolymorphicEmbed, options} ->
                      Map.put(options, :array?, false)

                    {:array, {:parameterized, PolymorphicEmbed, options}} ->
                      Map.put(options, :array?, true)

                    {_, {:parameterized, PolymorphicEmbed, options}} ->
                      Map.put(options, :array?, false)

                    nil ->
                      raise ArgumentError, "#{field} is not a polymorphic embed"
                  end
                  |> Map.get(:types_metadata)
                  |> Enum.map(fn %{type: type} -> type end)
              rescue
                _ -> false
              end
            end)
          end

          defoverridable changeset: 2
        )
      end,
      field(:execution_id, :string),
      field(:group_id, :string),
      field(:result, :string)
    ]
  end

  (
    @doc "Returns an ok tuple if the params are valid, otherwise returns `{:error, errors}`.\nAccepts a map or a list of maps.\n"
    def new(structs) when is_list(structs) do
      structs
      |> Enum.map(fn item -> __MODULE__.new(item) end)
      |> Enum.group_by(fn {is_valid, _} -> is_valid end, fn {_, decoding_value} ->
        decoding_value
      end)
      |> decoding_results()
    end

    def new(params) do
      case changeset(struct(__MODULE__), params) do
        %{valid?: true} = changes -> {:ok, apply_changes(changes)}
        changes -> {:error, Ecto.Changeset.traverse_errors(changes, fn {msg, _} -> msg end)}
      end
    end

    @doc "Returns new struct(s) if the params are valid, otherwise raises a `RuntimeError`.\n"
    def new!(params) do
      case new(params) do
        {:ok, value} -> value
        {:error, reason} -> raise RuntimeError, message: inspect(reason)
      end
    end

    @dialyzer {:no_match, changeset: 2}
    @doc "Casts the fields by using Ecto reflection,\nvalidates the required ones and returns a changeset.\n"
    def changeset(struct, params) do
      changeset = struct |> cast(params, fields()) |> validate_required_fields(@required_fields)

      embedded_cast_changeset =
        Enum.reduce(embedded_fields(), changeset, fn field, changeset ->
          cast_and_validate_required_embed(changeset, field, @required_fields)
        end)

      Enum.reduce(polymorphic_fields(), embedded_cast_changeset, fn field, changeset ->
        cast_polymorphic_embed(changeset, field)
      end)
    end

    def validate_required_fields(changeset, nil) do
      changeset
    end

    def validate_required_fields(changeset, :all) do
      Ecto.Changeset.validate_required(changeset, fields())
    end

    def validate_required_fields(changeset, required_fields) do
      Ecto.Changeset.validate_required(
        changeset,
        Enum.filter(fields(), fn field -> field in required_fields end)
      )
    end

    def cast_and_validate_required_embed(changeset, field, nil) do
      cast_embed(changeset, field)
    end

    def cast_and_validate_required_embed(changeset, field, :all) do
      cast_embed(changeset, field, required: true)
    end

    def cast_and_validate_required_embed(changeset, field, required_fields) do
      cast_embed(changeset, field, required: field in required_fields)
    end

    def decoding_results(%{error: decoding_errors}) do
      {:error, decoding_errors}
    end

    def decoding_results(%{ok: decoding_results}) do
      {:ok, decoding_results}
    end

    def decoding_results(_) do
      {:ok, []}
    end

    def fields() do
      non_embedded_fields = __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
      non_embedded_fields -- polymorphic_fields()
    end

    def embedded_fields do
      __MODULE__.__schema__(:embeds)
    end

    def polymorphic_fields() do
      __MODULE__.__schema__(:fields)
      |> Enum.filter(fn field ->
        try do
          [_ | _] =
            __MODULE__.__schema__(:type, field)
            |> case do
              {:parameterized, PolymorphicEmbed, options} ->
                Map.put(options, :array?, false)

              {:array, {:parameterized, PolymorphicEmbed, options}} ->
                Map.put(options, :array?, true)

              {_, {:parameterized, PolymorphicEmbed, options}} ->
                Map.put(options, :array?, false)

              nil ->
                raise ArgumentError, "#{field} is not a polymorphic embed"
            end
            |> Map.get(:types_metadata)
            |> Enum.map(fn %{type: type} -> type end)
        rescue
          _ -> false
        end
      end)
    end

    defoverridable changeset: 2
  )
end