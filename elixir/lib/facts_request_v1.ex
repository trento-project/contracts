defmodule Trento.Events.Checks.V1.FactsRequest do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false
  @required_fields [:execution_id, :facts]
  @derive Jason.Encoder
  embedded_schema do
    [
      field(:execution_id, :string),
      embeds_many(:facts, Facts, primary_key: false) do
        @derive Jason.Encoder
        @required_fields [:check_id, :name, :gatherer]
        [
          field(:argument, :string),
          field(:check_id, :string),
          field(:gatherer, :string),
          field(:name, :string)
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

            Enum.reduce(embedded_fields(), changeset, fn field, changeset ->
              cast_and_validate_required_embed(changeset, field, @required_fields)
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

          def fields do
            __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
          end

          def embedded_fields do
            __MODULE__.__schema__(:embeds)
          end

          defoverridable changeset: 2
        )
      end
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

      Enum.reduce(embedded_fields(), changeset, fn field, changeset ->
        cast_and_validate_required_embed(changeset, field, @required_fields)
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

    def fields do
      __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
    end

    def embedded_fields do
      __MODULE__.__schema__(:embeds)
    end

    defoverridable changeset: 2
  )
end
