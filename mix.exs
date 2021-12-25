defmodule SimpleEnum.MixProject do
  use Mix.Project

  @version "0.1.0"
  @github_url "https://github.com/ImNotAVirus/simple_enum"

  def project do
    [
      app: :simple_enum,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :test,
      deps: deps(),

      # Package
      package: package(),
      description: "A simple library that implements Enums in Elixir",

      # Docs
      name: "SimpleEnum",
      source_url: @github_url,
      docs: [main: "SimpleEnum", source_ref: "v#{@version}"],

      # Code Coverage
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.26", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: :test}
    ]
  end

  defp package do
    [
      maintainers: ["DarkyZ aka NotAVirus"],
      licenses: ["MIT"],
      links: %{"GitHub" => @github_url},
      files: ~w(lib CHANGELOG.md LICENSE.md mix.exs README.md .formatter.exs)
    ]
  end
end
