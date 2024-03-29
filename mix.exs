defmodule Telegraf.MixProject do
  use Mix.Project

  @name "Telegraf"
  @version "0.1.1"
  @description "Send metrics to telegraf"
  @repo_url "https://github.com/Finbits/telegraf-elixir"

  def project do
    [
      app: :telegraf,
      version: @version,
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      name: @name,
      description: @description,
      deps: deps(),
      docs: docs(),
      package: package(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:nimble_pool, "~> 1.0"},
      {:nimble_options, "~> 1.0.1"},

      # dev/test
      {:credo_naming, "~> 2.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.14", only: :test},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: @name,
      source_ref: "v#{@version}",
      source_url: @repo_url,
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"],
      extras: ["CHANGELOG.md"]
    ]
  end

  defp package do
    %{
      licenses: ["Apache-2.0"],
      maintainers: ["Finbits"],
      links: %{"GitHub" => @repo_url}
    }
  end
end
