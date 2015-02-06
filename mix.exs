defmodule Mix.Tasks.Compile.Cmark do
  use Mix.Task
  @shortdoc "Compiles cmark library"
  def run(_) do
    if Mix.shell.cmd("make") != 0 do
      raise Mix.Error, message: """
        Could not run `make`.
        Please check if `clang`/`gcc` and `cmake` are installed.
      """
    end
  end
end

defmodule Mix.Tasks.Spec do
  use Mix.Task
  @shortdoc "Runs spec test"
  def run(_) do
    Mix.shell.cmd("make spec")
  end
end

defmodule Cmark.Mixfile.VersionHelper do
  def get_version do
    ver = :os.cmd('git describe --always --tags') |> List.to_string |> String.strip(?\n)
    case ver |> String.split("-") do
      [<< "v", tag :: binary >>] ->
        tag
      [<< "v", tag :: binary >>, commits_since_tag, commit] ->
        "#{tag}-#{commits_since_tag}+#{commit}"
    end
  end
end

defmodule Mix.Tasks.Version do
  use Mix.Task
  alias Cmark.Mixfile.VersionHelper

  @shortdoc "Returns current version"
  def run(_) do
    IO.puts "Cmark version: #{VersionHelper.get_version}"
  end
end

defmodule Cmark.Mixfile do
  use Mix.Project
  alias Cmark.Mixfile.VersionHelper

  def project do
    [
      app:           :cmark,
      version:       VersionHelper.get_version,
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
      contributors: ["Christoph Grabo"],
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
    {ref, 0} = System.cmd("git", ["rev-parse", "--verify", "--quiet", "HEAD"])
    [
      source_ref: ref,
      readme:     "README.md",
      main:       "README"
    ]
  end

  defp deps do
    [
      { :excoveralls, "~> 0.3", only: [:dev, :test] },
      { :poison,      "~> 1.3", only: [:dev, :test] },
      { :ex_doc,      "~> 0.7", only: :docs },
      { :earmark,     "~> 0.1", only: :docs },
      { :inch_ex,     "~> 0.2", only: :docs }
    ]
  end
end
