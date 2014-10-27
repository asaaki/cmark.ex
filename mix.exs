defmodule Mix.Tasks.Compile.Cmark do
  use Mix.Task
  @shortdoc "Compiles cmark library"
  def run(_) do
    if Mix.shell.cmd("make priv/cmark.so") != 0 do
      raise Mix.Error, message: "Could not run `make priv/cmark.so`. Do you have make and gcc installed?"
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

defmodule Cmark.Mixfile do
  use Mix.Project

  def project do
    [
      app:          :cmark,
      version:      "0.1.1",
      elixir:       "~> 1.0.1",
      compilers:    [:cmark, :elixir, :app],
      deps:         deps(Mix.env),
      package:      package,
      description:  "Elixir NIF for CommonMark, a parser following the CommonMark spec",
      name:         "cmark",
      source_url:   "https://github.com/asaaki/cmark.ex",
      homepage_url: "http://hexdocs.pm/cmark",
      docs:         [readme: true, main: "README"]
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
        "lib",
        "src",
        "Makefile",
        "mix.exs",
        "README.md",
        "LICENSE"
      ]
    ]
  end

  defp deps(:dev) do
    [
      { :ex_doc,  "~> 0.6" },
      { :earmark, "~> 0.1" }
    ]
  end
  defp deps(_), do: []
end
