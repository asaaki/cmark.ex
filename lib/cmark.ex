defmodule Cmark do
  @moduledoc """
  Compiles Markdown formatted text into HTML

  Provides:

  * `to_html/1`
  * `to_html/2`
  * `to_html_each/2`

  """

  @doc """
  Compiles one or more (list) Markdown documents to HTML and returns result

  ## Examples

      iex> "test" |> Cmark.to_html
      "<p>test</p>\\n"

      iex> ["# also works", "* with list", "`of documents`"] |> Cmark.to_html
      ["<h1>also works</h1>\\n",
      "<ul>\\n<li>with list</li>\\n</ul>\\n",
      "<p><code>of documents</code></p>\\n"]

  """
  def to_html(data) when is_list(data),      do: parse_doc_list(data)
  def to_html(data) when is_bitstring(data), do: parse_doc(data)

  @doc """
  Compiles one or more (list) Markdown documents to HTML and calls function with result

  ## Examples

      iex> callback = fn (html) -> "HTML is \#{html}" |> String.strip end
      iex> "test" |> Cmark.to_html(callback)
      "HTML is <p>test</p>"

      iex> callback = fn (htmls) ->
      iex>   Enum.map(htmls, &String.strip/1) |> Enum.join("<hr>")
      iex> end
      iex> ["list", "test"] |> Cmark.to_html(callback)
      "<p>list</p><hr><p>test</p>"

  """
  def to_html(data, callback) when is_list(data),      do: parse_doc_list(data, callback)
  def to_html(data, callback) when is_bitstring(data), do: parse_doc(data, callback)

  @doc """
  Compiles a list of Markdown documents and calls function for each item

  ## Examples

      iex> callback = fn (html) -> "HTML is \#{html |> String.strip}" end
      iex> ["list", "test"] |> Cmark.to_html_each(callback)
      ["HTML is <p>list</p>", "HTML is <p>test</p>"]

  """
  def to_html_each(data, callback) when is_list(data) do
    parse_doc_list_each(data, callback)
  end

  defp parse_doc_list(documents) do
    documents
    |> Enum.map(&Task.async(fn -> parse_doc(&1) end))
    |> Enum.map(&Task.await(&1))
  end

  defp parse_doc_list(documents, callback) do
    callback.(parse_doc_list(documents))
  end

  defp parse_doc_list_each(documents, callback) do
    documents
    |> Enum.map(&Task.async(fn -> parse_doc(&1, callback) end))
    |> Enum.map(&Task.await(&1))
  end

  defp parse_doc(document) do
    Cmark.Nif.to_html(document)
  end

  defp parse_doc(document, callback) do
    callback.(Cmark.Nif.to_html(document))
  end
end
