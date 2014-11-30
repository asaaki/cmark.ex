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

defmodule Cmark.Mixfile do
  use Mix.Project
  @version File.read!("VERSION") |> String.strip

  def project do
    [
      app:          :cmark,
      version:      @version,
      elixir:       "~> 1.0",
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
        "c_src/*.*make",
        "c_src/CMakeLists.txt",
        "c_src/data",
        "c_src/LICENSE",
        "c_src/Makefile",
        "c_src/nmake.bat",
        "c_src/README.md",
        "c_src/src",
        "lib",
        "LICENSE",
        "Makefile",
        "mix.exs",
        "README.md",
        "src",
        "VERSION"
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
