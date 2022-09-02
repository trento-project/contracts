defmodule Trento.Events.Checks.V1.Agent.FactsGathered do
  use Ecto.Schema
  import Ecto.Changeset
  import PolymorphicEmbed
  alias Cloudevents.Format.V_1_0.Event, as: CloudEvent
  @version "v1"
  @source "trento/agent"
  @event_type "trento.checks.v1.agent.FactsGathered"
  @moduledoc false
  @primary_key false
  @required_fields [:execution_id, :agent_id, :facts_gathered]
  @derive Jason.Encoder
  embedded_schema do
    [
      field(:agent_id, :string),
      field(:execution_id, :string),
      embeds_many(:facts_gathered, FactsGathered, primary_key: false) do
        @derive Jason.Encoder
        @required_fields [:check_id, :name, :value]
        import PolymorphicEmbed

        [
          field(:check_id, :string),
          embeds_one(:error, Error) do
            @derive Jason.Encoder
            @required_fields [:message, :type]
            [field(:message, :string), field(:type, :string)]

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
          field(:name, :string),
          (
            defmodule Value do
              use Ecto.Type
              @moduledoc false
              def type do
                :value
              end

              [
                def cast(value) when Elixir.Kernel.is_number(value) do
                  {:ok, value}
                end,
                def cast(value) when Elixir.Kernel.is_bitstring(value) do
                  {:ok, value}
                end,
                def cast(value) when Elixir.Kernel.is_boolean(value) do
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
                def dump(value) when Elixir.Kernel.is_bitstring(value) do
                  value
                end,
                def dump(value) when Elixir.Kernel.is_boolean(value) do
                  value
                end
              ]

              [
                def load(value) when Elixir.Kernel.is_number(value) do
                  {:ok, value}
                end,
                def load(value) when Elixir.Kernel.is_bitstring(value) do
                  {:ok, value}
                end,
                def load(value) when Elixir.Kernel.is_boolean(value) do
                  {:ok, value}
                end
              ]
            end

            field(:value, Value)
          )
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
      end
    ]
  end

  (
    @doc "  Serialize and return a module struct from a cloud event json\n"
    def serialize_from_cloud_event(json_cloud_event) do
      case Cloudevents.from_json(json_cloud_event) do
        {:ok, %CloudEvent{data: data, type: @event_type}} ->
          __MODULE__.new(data)

        {:ok, %CloudEvent{type: event_type}} ->
          {:error, "invalid event type, provided #{event_type}"}

        error ->
          error
      end
    end

    @doc "  Serialize and return a cloud event json from a contract struct\n"
    def serialize_to_cloud_event(contract) do
      case CloudEvent.from_map(%{
             "specversion" => "1.0",
             "id" => UUID.uuid4(),
             "type" => @event_type,
             "source" => @source,
             "data" => contract
           }) do
        {:ok, event} -> Cloudevents.to_json(event)
        error -> error
      end
    end
  )

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
