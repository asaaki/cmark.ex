defmodule Cmark.Mixfile do
  use Mix.Project

  @version "0.8.0"

  def project do
    [
      app: :cmark,
      version: @version,
      elixir: "~> 1.8",
      compilers: [:elixir_make, :elixir, :app],
      deps: deps(),
      package: package(),
      description: description(),
      name: "cmark",
      source_url: "https://github.com/asaaki/cmark.ex",
      homepage_url: "http://hexdocs.pm/cmark",
      docs: &docs/0,
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application, do: []

  defp description do
    """
    Elixir NIF for cmark (C), a parser library following the CommonMark spec,
    a compatible implementation of Markdown.
    """
  end

  defp package do
    [
      maintainers: ["Christoph Grabo"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/asaaki/cmark.ex",
        "Issues" => "https://github.com/asaaki/cmark.ex/issues"
      },
      files: [
        "c_src/*.h",
        "c_src/*.c",
        "c_src/*.inc",
        "c_src/COPYING",
        "lib",
        "LICENSE",
        "Makefile",
        "mix.exs",
        "README.md",
        "src"
      ]
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: "https://github.com/asaaki/cmark.ex"
    ]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.6"},
      {:credo, "~> 1.4", only: [:lint, :ci]},
      {:ex_doc, "~> 0.21", only: [:dev, :docs, :ci]},
      {:excoveralls, "~> 0.6", only: :ci},
      {:inch_ex, "~> 2.0", only: [:docs, :ci]},
      {:jason, "~> 1.2", only: [:dev, :test, :docs, :lint, :ci], override: true},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end
end
