defmodule Mix.Tasks.Compile.Stmd do
  @shortdoc "Compiles stmd library"
  def run(_) do
    if Mix.shell.cmd("make priv/stmd.so") != 0 do
      raise Mix.Error, message: "Could not run `make priv/stmd.so`. Do you have make and gcc installed?"
    end
  end
end

defmodule Stmd.Mixfile do
  use Mix.Project

  def project do
    [
      app:          :stmd,
      version:      "0.0.1",
      elixir:       "~> 1.0.1",
      compilers:    [:stmd, :elixir, :app],
      deps:         deps(Mix.env),
      package:      package,
      description:  "Elixir NIF for stmd (C implementation), a CommonMark parser",
      name:         "stmd",
      source_url:   "https://github.com/asaaki/stmd.ex",
      homepage_url: "http://hexdocs.pm/stmd",
      docs:         [readme: true, main: "README"]
    ]
  end

  def application, do: []

  defp package do
    [
      contributors: ["Christoph Grabo"],
      licenses:     ["MIT"],
      links: %{
        "GitHub" => "https://github.com/asaaki/stmd.ex",
        "Issues" => "https://github.com/asaaki/stmd.ex/issues",
        "Docs"   => "http://hexdocs.pm/stmd/"
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
      { :ex_doc,  "~> 0.6" }
    ]
  end
  defp deps(_), do: []
end
