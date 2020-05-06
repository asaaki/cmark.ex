defmodule Cmark.Mixfile do
  use Mix.Project

  @version "0.7.0"

  def project do
    [
      app:           :cmark,
      version:       @version,
      elixir:        "~> 1.8",
      compilers:     [:cmark, :elixir, :app],
      deps:          deps(),
      package:       package(),
      description:   description(),
      name:          "cmark",
      source_url:    "https://github.com/asaaki/cmark.ex",
      homepage_url:  "http://hexdocs.pm/cmark",
      docs:          &docs/0,
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
      maintainers:  ["Christoph Grabo"],
      licenses:     ["MIT"],
      links: %{
        "GitHub" => "https://github.com/asaaki/cmark.ex",
        "Issues" => "https://github.com/asaaki/cmark.ex/issues",
        "Docs"   => "http://hexdocs.pm/cmark/#{@version}/"
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
      main:       "readme",
      source_ref: "v#{@version}",
      source_url: "https://github.com/asaaki/cmark.ex"
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.4", only: [:lint, :ci]},
      {:ex_doc, "~> 0.21", only: [:dev, :docs, :ci]},
      {:excoveralls, "~> 0.6", only: :ci},
      {:inch_ex, "~> 2.0", only: [:docs, :ci]},
      {:jason, "~> 1.2", only: [:dev, :test, :docs, :lint, :ci], override: true},
      {:dialyxir, "~> 1.0", only: [:dev]},
    ]
  end
end

defmodule Mix.Tasks.Compile.Cmark do
  use Mix.Task
  @shortdoc "Compiles cmark library"
  def run(_) do
    if Mix.env != :test, do: File.rm_rf("priv")
    File.mkdir("priv")

    make_cmd = System.get_env("MAKE") || case :os.type() do
      {:unix, :freebsd} -> "gmake"
      {:unix, :openbsd} -> "gmake"
      {:unix, :netbsd} -> "gmake"
      {:unix, :dragonfly} -> "gmake"
      _ -> "make"
    end
    {result, error_code} = System.cmd(make_cmd, [], stderr_to_stdout: true)
    IO.binwrite(result)

    if error_code != 0 do
      raise Mix.Error, message: """
        Could not run `#{make_cmd}`.
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
