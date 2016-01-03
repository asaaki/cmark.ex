use Mix.Config

if Mix.env == :docs do
  config :ex_doc, :markdown_processor, ExDoc.Markdown.Cmark
end
