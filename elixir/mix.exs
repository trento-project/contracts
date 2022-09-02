defmodule TrentoContracts.MixProject do
  use Mix.Project

  def project do
    [
      app: :trento_contracts,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ecto, "~> 3.8"},
      {:jason, "~> 1.3"},
      {:ex_json_schema, "~> 0.9.1"},
      {:elixir_uuid, "~> 1.2"},
      # Cloud events require a minor version of typed struct, json schema the the 0.3.0, we choose 0.3.0
      {:typed_struct, "~> 0.3", override: true},
      {:proper_case, "~> 1.3"},
      {:polymorphic_embed, "~> 3.0"},
      {:cloudevents, "~> 0.4.0"}
    ]
  end
end
