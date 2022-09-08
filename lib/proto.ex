defmodule Proto do
  @moduledoc """
  Documentation for `Proto`.
  """

  @doc """


  """
  def decode(value) do
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
end
