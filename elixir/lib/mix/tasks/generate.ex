defmodule Mix.Tasks.Contracts.Generate do
  use Mix.Task

  def run(_) do
    schemas_paths = Path.wildcard("./priv/schemas/*.schema.json")

    schemas_paths
    |> Enum.map(fn path -> {path, File.read!(path)} end)
    |> Enum.map(fn {path, content} -> {path, Jason.decode!(content)} end)
    |> Enum.map(fn {path, json_schema} ->
      destination = "lib/#{ProperCase.snake_case(json_schema["title"])}.ex"
      required = get_required(json_schema)
      module_name = path |> Path.basename(".schema.json") |> get_module_name()

      %{"version" => version, "source" => source, "type" => event_type} =
        path |> Path.basename(".schema.json") |> get_contract_info

      file_content =
        quote do
          defmodule unquote(Module.concat([module_name])) do
            use Ecto.Schema
            import Ecto.Changeset
            import PolymorphicEmbed

            alias Trento.Events.JsonSchema
            alias Cloudevents.Format.V_1_0.Event, as: CloudEvent

            @version unquote(version)
            @source unquote(source)
            @event_type unquote(event_type)

            @moduledoc false
            @primary_key false
            @required_fields unquote(required)

            @derive Jason.Encoder
            embedded_schema do
              unquote(Enum.map(json_schema["properties"], &get_field/1))
            end

            unquote(trento_cloudevent_conversion_functions())
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
      embeds_one unquote(String.to_atom(k)), unquote(Module.concat([Macro.camelize(k)])) do
        @derive Jason.Encoder
        @required_fields unquote(required)

        unquote(Enum.map(properties, &get_field/1))
        unquote(trento_contract_functions())
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
    required = get_required(items)

    quote do
      embeds_many unquote(String.to_atom(k)), unquote(Module.concat([Macro.camelize(k)])),
        primary_key: false do
        @derive Jason.Encoder
        @required_fields unquote(required)

        import PolymorphicEmbed

        unquote(Enum.map(properties, &get_field/1))

        unquote(trento_contract_functions())
      end
    end
  end

  def get_field({k, %{"type" => types}}) when is_list(types) do
    union_type_module_name = Macro.camelize(k)
    actual_types = Enum.filter(types, fn type -> type != "null" end)

    quote do
      defmodule unquote(Module.concat([union_type_module_name])) do
        use Ecto.Type
        @moduledoc false
        def type, do: unquote(String.to_atom(k))

        unquote(
          Enum.map(actual_types, fn type ->
            quote do
              def cast(value) when unquote(Module.concat([get_guard(type)]))(value) do
                {:ok, value}
              end
            end
          end)
        )

        def cast(_), do: :error

        unquote(
          Enum.map(actual_types, fn type ->
            quote do
              def dump(value) when unquote(Module.concat([get_guard(type)]))(value) do
                value
              end
            end
          end)
        )

        unquote(
          Enum.map(actual_types, fn type ->
            quote do
              def load(value) when unquote(Module.concat([get_guard(type)]))(value) do
                {:ok, value}
              end
            end
          end)
        )
      end

      field(unquote(String.to_atom(k)), unquote(Module.concat([union_type_module_name])))
    end
  end

  def get_field({k, %{"type" => "array", "items" => %{"oneOf" => types}}}) when is_list(types) do
    case only_primitives?(types) do
      true ->
        list_of_primitive_types = Enum.map(types, fn %{"type" => type} -> type end)
        get_field({k, %{"type" => list_of_primitive_types}})

      false ->
        generated_types =
          Enum.map(types, fn type ->
            type_name =
              case type do
                %{"title" => title, "type" => "object", "properties" => _properties} ->
                  title |> ProperCase.snake_case() |> String.to_atom()

                _ ->
                  nil
              end

            module_name =
              case type do
                %{"title" => title, "type" => "object", "properties" => _properties} ->
                  title

                _ ->
                  nil
              end

            properties =
              case type do
                %{"title" => _title, "type" => "object", "properties" => properties} ->
                  properties |> Map.keys() |> Enum.map(&String.to_atom/1)

                _ ->
                  nil
              end

            type_code =
              case type do
                %{"title" => title, "properties" => properties} ->
                  required = get_required(type)

                  quote do
                    defmodule unquote(Module.concat([title])) do
                      use Ecto.Schema
                      @primary_key false
                      @derive Jason.Encoder
                      @moduledoc false
                      @required_fields unquote(required)
                      embedded_schema do
                        unquote(Enum.map(properties, &get_field/1))
                      end

                      unquote(trento_contract_functions())
                    end
                  end

                _ ->
                  quote do
                  end
              end

            {type_name, module_name, type_code, properties}
          end)

        quote do
          unquote(Enum.map(generated_types, fn {_, _, type_code, _} -> type_code end))

          polymorphic_embeds_many(
            unquote(String.to_atom(k)),
            types:
              unquote(
                generated_types
                |> Enum.filter(fn {type_name, _, _, _} -> not is_nil(type_name) end)
                |> Enum.map(fn {type_name, module_name, _type_code, properties} ->
                  quote do
                    {unquote(type_name),
                     [
                       module: unquote(Module.concat([module_name])),
                       identify_by_fields: unquote(properties)
                     ]}
                  end
                end)
              ),
            on_type_not_found: :raise,
            on_replace: :delete
          )
        end
    end
  end

  def get_field({k, %{"oneOf" => types}}) when is_list(types) do
    case only_primitives?(types) do
      true ->
        list_of_primitive_types = Enum.map(types, fn %{"type" => type} -> type end)
        get_field({k, %{"type" => list_of_primitive_types}})

      false ->
        generated_types =
          Enum.map(types, fn type ->
            type_name =
              case type do
                %{"title" => title, "type" => "object", "properties" => _properties} ->
                  title |> ProperCase.snake_case() |> String.to_atom()

                _ ->
                  nil
              end

            module_name =
              case type do
                %{"title" => title, "type" => "object", "properties" => _properties} ->
                  title

                _ ->
                  nil
              end

            properties =
              case type do
                %{"title" => _title, "type" => "object", "properties" => properties} ->
                  properties |> Map.keys() |> Enum.map(&String.to_atom/1)

                _ ->
                  nil
              end

            type_code =
              case type do
                %{"title" => title, "properties" => properties} ->
                  required = get_required(type)

                  quote do
                    defmodule unquote(Module.concat([title])) do
                      use Ecto.Schema
                      @primary_key false
                      @derive Jason.Encoder
                      @moduledoc false
                      @required_fields unquote(required)
                      embedded_schema do
                        unquote(Enum.map(properties, &get_field/1))
                      end

                      unquote(trento_contract_functions())
                    end
                  end

                _ ->
                  quote do
                  end
              end

            {type_name, module_name, type_code, properties}
          end)

        quote do
          unquote(Enum.map(generated_types, fn {_, _, type_code, _} -> type_code end))

          polymorphic_embeds_one(
            unquote(String.to_atom(k)),
            types:
              unquote(
                generated_types
                |> Enum.filter(fn {type_name, _, _, _} -> not is_nil(type_name) end)
                |> Enum.map(fn {type_name, module_name, _type_code, properties} ->
                  quote do
                    {unquote(type_name),
                     [
                       module: unquote(Module.concat([module_name])),
                       identify_by_fields: unquote(properties)
                     ]}
                  end
                end)
              ),
            on_type_not_found: :raise,
            on_replace: :delete
          )
        end
    end
  end

  def get_field(
        {k,
         %{
           "type" => "object",
           "propertyNames" => _property_names,
           "patternProperties" => _pattern_properties
         }}
      ) do
    quote do
      field(unquote(String.to_atom(k)), :map)
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

  def get_field({k, %{"type" => "boolean"}}) do
    quote do
      field(unquote(String.to_atom(k)), :boolean)
    end
  end

  def get_field({_k, _v}) do
    quote do
    end
  end

  def get_required(%{"required" => required}), do: Enum.map(required, &String.to_atom/1)
  def get_required(_), do: []

  def get_module_name("trento." <> name) do
    module_name =
      name
      |> String.split(".")
      |> Enum.map_join(".", &Macro.camelize/1)

    "Trento.Events.#{Macro.camelize(module_name)}"
  end

  def get_contract_info(contract_path) do
    [_, _project, version, source | _] =
      contract_path
      |> String.split(".")

    %{"version" => version, "source" => "trento/" <> source, "type" => contract_path}
  end

  def get_guard("string"), do: "Kernel.is_bitstring"
  def get_guard("number"), do: "Kernel.is_number"
  def get_guard("boolean"), do: "Kernel.is_boolean"

  def only_primitives?(types) do
    types_list = types |> Enum.map(fn %{"type" => type} -> type end)
    "object" not in types_list
  end

  @doc """
    Generates the cloud events conversion functions for the contract
  """
  def trento_cloudevent_conversion_functions() do
    quote do
      @doc """
        Serialize and return a module struct from a cloud event json
      """
      @spec serialize_from_cloud_event(json :: binary()) :: {:ok, __MODULE__} | {:error, any}
      def serialize_from_cloud_event(json_cloud_event) do
        with {:ok, event} <- Cloudevents.from_json(json_cloud_event) do
          create_contract_from_cloud_event(event)
        end
      end

      @doc """
        Serialize and return a cloud event json from a contract struct
      """
      @spec serialize_to_cloud_event(contract :: __MODULE__) :: {:ok, binary()} | {:error, any}
      def serialize_to_cloud_event(contract) do
        with :ok <- validate_with_schema(contract),
             {:ok, event} <-
               CloudEvent.from_map(%{
                 "specversion" => "1.0",
                 "id" => UUID.uuid4(),
                 "type" => @event_type,
                 "source" => @source,
                 "data" => contract
               }) do
          event
        end
      end

      defp validate_with_schema(data) do
        JsonSchema.validate(@event_type, data)
      end

      defp create_contract_from_cloud_event(%CloudEvent{data: data, type: @event_type}) do
        with :ok <- validate_with_schema(data) do
          __MODULE__.new(data)
        end
      end

      defp create_contract_from_cloud_event(%CloudEvent{type: event_type}) do
        {:error, "invalid event type, provided #{event_type}"}
      end
    end
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

        embedded_cast_changeset =
          Enum.reduce(embedded_fields(), changeset, fn field, changeset ->
            cast_and_validate_required_embed(changeset, field, @required_fields)
          end)

        Enum.reduce(polymorphic_fields(), embedded_cast_changeset, fn field, changeset ->
          cast_polymorphic_embed(changeset, field)
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

      def fields() do
        non_embedded_fields = __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds)
        non_embedded_fields -- polymorphic_fields()
      end

      def embedded_fields, do: __MODULE__.__schema__(:embeds)

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
    end
  end
end
