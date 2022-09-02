defmodule Trento.Events.JsonSchema do
  @moduledoc """
   Utility module for Json schema interaction.
  """

  @schema_path Path.join(File.cwd!(), "priv/schemas/")

  for schema_file <- File.ls!(@schema_path) do
    @external_resource schema_file

    schema =
      @schema_path
      |> Path.join(schema_file)
      |> File.read!()
      |> Jason.decode!()
      |> ExJsonSchema.Schema.resolve()

    @doc """
      Validates the passed data against a json schema file
    """
    def validate(unquote(Path.basename(schema_file, ".schema.json")), data),
      do: ExJsonSchema.Validator.validate(unquote(Macro.escape(schema)), data)
  end

  def validate(schema, data) do
    IO.inspect(schema)
    IO.inspect(data)
    {:error, :schema_not_found}
  end
end
