# @deprecated; replace with `import Config`
# once 1.9 is the last supported Elixir version
use Mix.Config

if Mix.env in ~w(dev docs ci)a do
  config :ex_doc, :markdown_processor, ExDoc.Markdown.Cmark
end
