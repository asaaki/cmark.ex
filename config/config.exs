use Mix.Config

if Mix.env in ~w(dev docs ci)a do
  config :ex_doc, :markdown_processor, ExDoc.Markdown.Cmark
end
