defmodule Cmark do
  @moduledoc """
    Compiles Markdown formatted text into HTML
  """

  @doc """
    Compiles one or more (list) Markdown documents to HTML and returns result

    ## Examples

    iex> Cmark.to_html "test"
    "<p>test</p>\n"

    iex> Cmark.to_html ["# also works", "* with list", "`of documents`"]
    ["<h1>also works</h1>\n", "<ul>\n<li>with list</li>\n</ul>\n", "<p><code>of documents</code></p>\n"]
  """
  def to_html(input) when is_list(input) do
    parse_doc_list input
  end
  def to_html(input) when is_bitstring(input) do
    parse_doc(input)
  end

  @doc """
    Compiles one or more (list) Markdown documents to HTML and calls function with result

    ## Examples

    iex> Cmark.to_html "test", fn (html) -> IO.write("HTML: #{html}") end
    HTML: <p>test</p>
    :ok

    iex> Cmark.to_html ["list", "test"], fn (htmls) -> IO.write("HTML: #{inspect htmls}\n") end
    HTML: ["<p>list</p>\n", "<p>test</p>\n"]
    :ok
  """
  def to_html(input, callback) when is_list(input) do
    parse_doc_list input, callback
  end
  def to_html(input, callback) when is_bitstring(input) do
    parse_doc input, callback
  end

  @doc """
    Compiles a list of Markdown documents and calls function for each item

    ## Examples

    iex> Cmark.to_html_each ["list", "test"], fn (html) -> IO.write("HTML: #{html}") end
    HTML: <p>list</p>
    HTML: <p>test</p>
    [:ok, :ok]
  """
  def to_html_each(input, callback) when is_list(input) do
    parse_doc_list_each input, callback
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
