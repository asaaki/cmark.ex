defmodule Mix.Tasks.Compile.Cmark do
  use Mix.Task
  @shortdoc "Compiles cmark library"
  def run(_) do
    if Mix.env != :test, do: File.rm_rf("priv")
    File.mkdir("priv")

    {result, error_code} = System.cmd("make", [], stderr_to_stdout: true)
    IO.binwrite(result)

    if error_code != 0 do
      raise Mix.Error, message: """
        Could not run `make`.
        Please check if `make` and either `clang` or `gcc` are installed
      """
    end

    Mix.Project.build_structure
    :ok
  end
end

defmodule Mix.Tasks.Spec do
  use Mix.Task
  @shortdoc "Runs spec test"
  def run(_) do
    Mix.shell.cmd("make spec")
  end
end

defmodule Cmark.Mixfile do
  use Mix.Project

  @version "0.6.0"

  def project do
    [
      app:           :cmark,
      version:       @version,
      elixir:        "~> 1.0",
      compilers:     [:cmark, :elixir, :app],
      deps:          deps,
      package:       package,
      description:   "Elixir NIF for cmark (C), a parser library following the CommonMark spec, a compatible implementation of Markdown.",
      name:          "cmark",
      source_url:    "https://github.com/asaaki/cmark.ex",
      homepage_url:  "http://hexdocs.pm/cmark",
      docs:          &docs/0,
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application, do: []

  defp package do
    [
      maintainers:  ["Christoph Grabo"],
      licenses:     ["MIT"],
      links: %{
        "GitHub" => "https://github.com/asaaki/cmark.ex",
        "Issues" => "https://github.com/asaaki/cmark.ex/issues",
        "Docs"   => "http://hexdocs.pm/cmark/"
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
      extras:     ["README.md"],
      main:       "extra-readme",
      source_ref: "v#{@version}",
      source_url: "https://github.com/asaaki/cmark.ex"
    ]
  end

  defp deps do
    [
      {:excoveralls, "~> 0.4", only: :test},
      {:poison, "~> 1.5", only: [:test, :docs], override: true},
      {:ex_doc, "~> 0.11", only: :docs},
      {:earmark, "~> 0.2", only: :docs},
      {:inch_ex, "~> 0.4", only: :docs}
    ]
  end
end
