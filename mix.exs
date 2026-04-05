defmodule SimpleEnum.MixProject do
  use Mix.Project

  @version "1.0.0"
  @source_url "https://github.com/ImNotAVirus/simple_enum"

  def project() do
    [
      app: :simple_enum,
      version: @version,
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :test,
      deps: deps(),
      aliases: aliases(),
      package: package(),
      description: description(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def cli() do
    [
      preferred_envs: [
        docs: :docs,
        ci: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application() do
    []
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps() do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.40", only: [:dev, :docs], runtime: false},
      {:excoveralls, "~> 0.18", only: :test, runtime: false}
    ]
  end

  defp aliases() do
    [
      ci: ["format --check-formatted", "credo --strict", "test"]
    ]
  end

  defp description() do
    """
    A simple library that implements Enumerations in Elixir
    """
  end

  defp package() do
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

  defp extras() do
    [
      "guides/integer_based_enum.md",
      "guides/string_based_enum.md",
      "guides/enum_types.md",
      "guides/helpers.md",
      "guides/fast_vs_slow_access.md",
      "CHANGELOG.md",
      "LICENSE.md",
      "README.md": [filename: "overview", title: "Overview"]
    ]
  end

  defp groups_for_extras() do
    [
      Guides: ~r/guides\/[^\/]+\.md/,
      Others: ~r/(CHANGELOG|LICENSE)\.md/
    ]
  end
end
