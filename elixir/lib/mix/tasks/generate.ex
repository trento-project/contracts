defmodule Mix.Tasks.Contracts.Generate do
  use Mix.Task

  def run(_) do
    schemas_paths = Path.wildcard("../schema/*.schema.json")

    schemas_paths
    |> Enum.map(fn path -> {path, File.read!(path)} end)
    |> Enum.map(fn {path, content} -> {path, Jason.decode!(content)} end)
    |> Enum.map(fn {path, json_schema} ->
      destination = "lib/#{ProperCase.snake_case(json_schema["title"])}.ex"
      required = get_required(json_schema)
      module_name = path |> Path.basename(".schema.json") |> get_module_name()

      file_content =
        quote do
          defmodule unquote(Module.concat([module_name])) do
            use Ecto.Schema
            import Ecto.Changeset

            @primary_key false
            @required_fields unquote(required)

            embedded_schema do
              unquote(Enum.map(json_schema["properties"], &get_field/1))
            end

            unquote(trento_contract_functions())
          end
        end
        |> Macro.to_string()

      {destination, file_content}
    end)
    |> Enum.each(fn {destination, content} -> File.write!(destination, content) end)
  end

  def get_field({k, %{"type" => "object", "properties" => properties} = item}) do
    required = get_required(item)

    quote do
      field unquote(String.to_atom(k)), unquote(Module.concat([Macro.camelize(k)])) do
        @required_fields unquote(required)

        unquote(trento_contract_functions())

        embedded_schema do
          unquote(Enum.map(properties, &get_field/1))
        end
      end
    end
  end

  def get_field(
        {k,
         %{
           "type" => "array",
           "items" => %{"type" => "object", "properties" => properties} = items
         }}
      ) do
    quote do
      embeds_many unquote(String.to_atom(k)), unquote(Module.concat([Macro.camelize(k)])),
        primary_key: false do
        unquote(Enum.map(properties, &get_field/1))

        unquote(trento_contract_functions())
      end
    end
  end

  def get_field({k, %{"type" => "string"}}) do
    quote do
      field(unquote(String.to_atom(k)), :string)
    end
  end

  def get_field({k, %{"type" => "integer"}}) do
    quote do
      field(unquote(String.to_atom(k)), :integer)
    end
  end

  def get_field({k, v}) do
    quote do
    end
  end

  def get_required(%{"required" => required}), do: Enum.map(required, &String.to_atom/1)
  def get_required(_), do: []

  def get_module_name("trento." <> name) do
    module_name =
      name
      |> String.split(".")
      |> Enum.map(&Macro.camelize/1)
      |> Enum.join(".")

    "Trento.Events.#{Macro.camelize(module_name)}"
  end

  def trento_contract_functions() do
    quote do
      @doc """
      Returns an ok tuple if the params are valid, otherwise returns `{:error, errors}`.
      Accepts a map or a list of maps.
      """
      def new(structs) when is_list(structs) do
        structs
        |> Enum.map(fn item -> __MODULE__.new(item) end)
        |> Enum.group_by(
          fn {is_valid, _} -> is_valid end,
          fn {_, decoding_value} -> decoding_value end
        )
        |> decoding_results()
      end

      def new(params) do
        case changeset(struct(__MODULE__), params) do
          %{valid?: true} = changes ->
            {:ok, apply_changes(changes)}

          changes ->
            {:error,
             Ecto.Changeset.traverse_errors(
               changes,
               fn {msg, _} -> msg end
             )}
        end
      end

      @doc """
      Returns new struct(s) if the params are valid, otherwise raises a `RuntimeError`.
      """
      def new!(params) do
        case new(params) do
          {:ok, value} -> value
          {:error, reason} -> raise RuntimeError, message: inspect(reason)
        end
      end

      @dialyzer {:no_match, changeset: 2}
      # we need to ignore the no_match warning of the ` {_, Ecto.Embedded, _}` case
      # since some spec is broken in the Ecto codebase

      @doc """
      Casts the fields by using Ecto reflection,
      validates the required ones and returns a changeset.
      """
      def changeset(struct, params) do
        changeset =
          struct
          |> cast(params, fields())
          |> validate_required_fields(@required_fields)

        Enum.reduce(embedded_fields(), changeset, fn field, changeset ->
          cast_and_validate_required_embed(changeset, field, @required_fields)
        end)
      end

      def validate_required_fields(changeset, nil), do: changeset

      def validate_required_fields(changeset, :all),
        do:
          Ecto.Changeset.validate_required(
            changeset,
            fields()
          )

      def validate_required_fields(changeset, required_fields),
        do:
          Ecto.Changeset.validate_required(
            changeset,
            Enum.filter(fields(), fn field ->
              field in required_fields
            end)
          )

      def cast_and_validate_required_embed(changeset, field, nil),
        do: cast_embed(changeset, field)

      def cast_and_validate_required_embed(changeset, field, :all),
        do: cast_embed(changeset, field, required: true)

      def cast_and_validate_required_embed(changeset, field, required_fields),
        do: cast_embed(changeset, field, required: field in required_fields)

      def decoding_results(%{error: decoding_errors}), do: {:error, decoding_errors}
      def decoding_results(%{ok: decoding_results}), do: {:ok, decoding_results}
      def decoding_results(_), do: {:ok, []}

      def fields, do: __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)

      def embedded_fields, do: __MODULE__.__schema__(:embeds)

      defoverridable changeset: 2
    end
  end
end
