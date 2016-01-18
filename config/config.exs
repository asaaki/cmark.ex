use Mix.Config

if Mix.env in ~w(docs ci)a do
  config :ex_doc, :markdown_processor, ExDoc.Markdown.Cmark
end

if Mix.env in ~w(lint ci)a do
  config :dogma,
    rule_set: Dogma.RuleSet.All,
    override: %{
      LineLength => [max_length: 120],
    }
end
