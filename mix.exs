defmodule SimpleEnum.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/ImNotAVirus/simple_enum"

  def project do
    [
      app: :simple_enum,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :test,
      deps: deps(),
      package: package(),
      description: description(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        docs: :docs,
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
      {:ex_doc, "~> 0.26", only: [:dev, :docs], runtime: false},
      {:excoveralls, "~> 0.14", only: :test}
    ]
  end

  defp description do
    """
    A simple library that implements Enumerations in Elixir
    """
  end

  defp package do
    [
      maintainers: ["DarkyZ aka NotAVirus"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib CHANGELOG.md LICENSE.md mix.exs README.md .formatter.exs)
    ]
  end

  defp docs() do
    [
      main: "overview",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/simple_enum",
      source_url: @source_url,
      extras: extras(),
      groups_for_extras: groups_for_extras()
    ]
  end

  defp extras do
    [
      "guides/integer_based_enum.md",
      "guides/string_based_enum.md",
      "guides/enum_types.md",
      "guides/fast_vs_slow_access.md",
      "guides/introspection.md",
      "CHANGELOG.md",
      "LICENSE.md",
      "README.md": [filename: "overview", title: "Overview"]
    ]
  end

  defp groups_for_extras do
    [
      Guides: ~r/guides\/[^\/]+\.md/,
      Others: ~r/(CHANGELOG|LICENSE)\.md/
    ]
  end
end
