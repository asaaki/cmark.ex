defmodule Mix.Tasks.Compile.Cmark do
  use Mix.Task
  @shortdoc "Compiles cmark library"
  def run(_) do
    if Mix.shell.cmd("make") != 0 do
      raise Mix.Error, message: """
        Could not run `make`.
        Please check if `make`, `cmake` and `re2c` are installed.
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

defmodule Cmark.Mixfile do
  use Mix.Project

  def project do
    [
      app:          :cmark,
      version:      "0.3.0-dev1",
      elixir:       "~> 1.0.1",
      compilers:    [:cmark, :elixir, :app],
      deps:         deps,
      package:      package,
      description:  "Elixir NIF for libcmark, a parser library following the CommonMark spec",
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
        "c_src/CMakeLists.txt",
        "c_src/Makefile",
        "c_src/*.*make",
        "c_src/nmake.bat",
        "c_src/api_test",
        "c_src/data",
        "c_src/src",
        "c_src/*.{txt,py}",
        "c_src/README.md",
        "c_src/LICENSE",
        "Makefile",
        "mix.exs",
        "README.md",
        "LICENSE"
      ]
    ]
  end

  defp deps do
    [
      { :ex_doc,  "~> 0.6", only: :docs },
      { :earmark, "~> 0.1", only: :docs },
      { :poison,  "~> 1.2", only: :test }
    ]
  end
end
