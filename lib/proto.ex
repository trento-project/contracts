defmodule Proto do
  @moduledoc """
  Documentation for `Proto`.
  """

  @doc """
  """
  def to_event(%mod{} = struct, opts \\ []) do
    id = Keyword.get(opts, :id, UUID.uuid4())
    source = Keyword.get(opts, :source, "trento")
    data = Protobuf.Encoder.encode(struct)

    cloud_event =
      Cloudevents.CloudEvent.new!(
        data: {:proto_data, Google.Protobuf.Any.new!(value: data, type_url: get_type(mod))},
        spec_version: "1.0",
        type: get_type(mod),
        id: id,
        source: source
      )

    Cloudevents.CloudEvent.encode(cloud_event)
  end

  @doc """
  """
  def from_event(value) do
    %{type: type, data: {:proto_data, %Google.Protobuf.Any{value: data}}} =
      Cloudevents.CloudEvent.decode(value)

    decode(type, data)
  end

  defp decode(type, data) do
    module_name = Macro.camelize(type)

    try do
      module = Module.safe_concat([module_name])
      module.decode(data)
    rescue
      ArgumentError -> {:error, :not_found}
    end
  end

  defp get_type(mod) do
    mod
    |> Atom.to_string()
    |> String.replace("Elixir.", "")
  end
end
