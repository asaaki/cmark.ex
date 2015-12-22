defmodule Cmark do
  @moduledoc """
  Compiles Markdown formatted text into HTML

  Provides:

  * `to_html/1`
  * `to_html/2`
  * `to_html/3`
  * `to_html_each/3`

  """

  @flags [
    sourcepos: 1,
    hardbreaks: 2,
    normalize: 4,
    smart: 8,
    validate_utf8: 16,
    safe: 32
  ]

  @doc """
  Compiles one or more (list) Markdown documents to HTML and returns result.

  ## Examples

      iex> "test" |> Cmark.to_html
      "<p>test</p>\\n"

      iex> ["# also works", "* with list", "`of documents`"] |> Cmark.to_html
      ["<h1>also works</h1>\\n",
      "<ul>\\n<li>with list</li>\\n</ul>\\n",
      "<p><code>of documents</code></p>\\n"]

  """
  def to_html(data) when is_list(data) do
    parse_doc_list(data, [])
  end

  def to_html(data) when is_bitstring(data) do
    parse_doc(data, [])
  end

  @doc """
  Compiles one or more (list) Markdown documents to HTML using provided options
  and returns result.

  Options are passed as a list of atoms.  Available options are:

  * `:sourcepos` - Include a `data-sourcepos` attribute on all block elements.
  * `:softbreak` - Render `softbreak` elements as hard line breaks.
  * `:normalize` - Normalize tree by consolidating adjacent text nodes.
  * `:smart` - Convert straight quotes to curly, --- to em dashes, -- to en dashes.
  * `:validate_utf8` - Validate UTF-8 in the input before parsing, replacing
     illegal sequences with the replacement character U+FFFD.
  * `:safe` - Suppress raw HTML and unsafe links (`javascript:`, `vbscript:`,
    `file:`, and `data:`, except for `image/png`, `image/gif`, `image/jpeg`, or
    `image/webp` mime types).  Raw HTML is replaced by a placeholder HTML
    comment. Unsafe links are replaced by empty strings.


  ## Examples

      iex> Cmark.to_html(~s(Use option to enable "smart" quotes.), [:smart])
      "<p>Use option to enable “smart” quotes.</p>\\n"

  """

  def to_html(data, options) when is_list(data) and is_list(options) do
    parse_doc_list(data, options)
  end

  def to_html(data, options) when is_bitstring(data) and is_list(options) do
    parse_doc(data, options)
  end

  @doc """
  Compiles one or more (list) Markdown documents to HTML and calls function with result.

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
  def to_html(data, callback) when is_list(data) and is_function(callback) do
    parse_doc_list(data, callback, [])
  end

  def to_html(data, callback) when is_bitstring(data) and is_function(callback) do
    parse_doc(data, callback, [])
  end

  @doc """
  Compiles one or more (list) Markdown documents to HTML using provided options
  and calls function with result.

  ## Examples

      iex> callback = fn (htmls) ->
      iex>   Enum.map(htmls, &String.strip/1) |> Enum.join("<hr>")
      iex> end
      iex> ["en-dash --", "ellipsis..."] |> Cmark.to_html(callback, [:smart])
      "<p>en-dash –</p><hr><p>ellipsis…</p>"

  """
  def to_html(data, callback, options) when is_list(data) and is_list(options) do
    parse_doc_list(data, callback, options)
  end

  def to_html(data, callback, options) when is_bitstring(data) and is_list(options) do
    parse_doc(data, callback, options)
  end

  @doc """
  Compiles a list of Markdown documents using provided options and calls
  function for each item.

  ## Examples

      iex> callback = fn (html) -> "HTML is \#{html |> String.strip}" end
      iex> ["list", "test"] |> Cmark.to_html_each(callback)
      ["HTML is <p>list</p>", "HTML is <p>test</p>"]

  """
  def to_html_each(data, callback, options \\ []) when is_list(data) do
    parse_doc_list_each(data, callback, options)
  end


  defp parse_doc_list(documents, callback, options) when is_function(callback) do
    callback.(parse_doc_list(documents, options))
  end

  defp parse_doc_list(documents, options) when is_list(options) do
    documents
    |> Enum.map(&Task.async(fn -> parse_doc(&1, options) end))
    |> Enum.map(&Task.await(&1))
  end


  defp parse_doc_list_each(documents, callback, options) do
    documents
    |> Enum.map(&Task.async(fn -> parse_doc(&1, callback, options) end))
    |> Enum.map(&Task.await(&1))
  end


  defp parse_doc(document, callback, options) do
    callback.(parse_doc(document, options))
  end

  defp parse_doc(document, options) do
    Cmark.Nif.to_html(document, parse_options(options))
  end


  defp parse_options(options) do
    Enum.reduce(options, 0, fn(flag, acc) -> @flags[flag] + acc end)
  end
end
