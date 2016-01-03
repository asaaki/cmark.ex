defmodule Cmark do
  @moduledoc """
  Compiles Markdown formatted text into HTML

  Provides:

  * `to_commonmark/1`
  * `to_commonmark/2`
  * `to_commonmark/3`
  * `to_commonmark_each/3`
  * `to_html/1`
  * `to_html/2`
  * `to_html/3`
  * `to_html_each/3`
  * `to_latex/1`
  * `to_latex/2`
  * `to_latex/3`
  * `to_latex_each/3`
  * `to_man/1`
  * `to_man/2`
  * `to_man/3`
  * `to_man_each/3`
  * `to_xml/1`
  * `to_xml/2`
  * `to_xml/3`
  * `to_xml_each/3`

  """

  # c_src/cmark.h -> CMARK_OPT_*
  @flags %{
    sourcepos: 2,        # (1 <<< 1)
    hardbreaks: 4,       # (1 <<< 2)
    safe: 16,            # (1 <<< 3)
    normalize: 256,      # (1 <<< 8)
    validate_utf8: 512,  # (1 <<< 9)
    smart: 1024,         # (1 <<< 10)
  }

  # FIXME: Defining the indexes in two palces (here and in C) is terrible.
  # Either pass a string to the C (ew) expose a C function that returns the
  # integer a format corresponds to (also ew)...?
  # Maybe just pass an atom to C.
  @formats [
    html: 1,
    xml: 2,
    man: 3,
    commonmark: 4,
    latex: 5
  ]

  @doc ~S"""
  Compiles one or more (list) Markdown documents to HTML and returns result.

  ## Examples

      iex> "test" |> Cmark.to_html
      "<p>test</p>\n"

      iex> ["# also works", "* with list", "`of documents`"] |> Cmark.to_html
      ["<h1>also works</h1>\n",
      "<ul>\n<li>with list</li>\n</ul>\n",
      "<p><code>of documents</code></p>\n"]


      iex> markdown = ~s(
      ...> # Lorem Ipsum Dolor Sit Amet
      ...>
      ...> Consectetur adipiscing elit. Integer pulvinar ipsum a ante ornare dignissim. Nulla vel lacus feugiat, volutpat risus eget, semper nisl.
      ...>
      ...> 1. Quisque varius nisi
      ...> 2. Quisque ac sem ac lacus
      ...>
      ...>)
      iex> Cmark.to_commonmark(markdown)
      "# Lorem Ipsum Dolor Sit Amet\n\nConsectetur adipiscing elit. Integer pulvinar ipsum a ante ornare dignissim. Nulla vel lacus feugiat, volutpat risus eget, semper nisl.\n\n1.  Quisque varius nisi\n2.  Quisque ac sem ac lacus\n"
      iex> Cmark.to_html(markdown)
      "<h1>Lorem Ipsum Dolor Sit Amet</h1>\n<p>Consectetur adipiscing elit. Integer pulvinar ipsum a ante ornare dignissim. Nulla vel lacus feugiat, volutpat risus eget, semper nisl.</p>\n<ol>\n<li>Quisque varius nisi</li>\n<li>Quisque ac sem ac lacus</li>\n</ol>\n"
      iex> Cmark.to_xml(markdown)
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">\n<document xmlns=\"http://commonmark.org/xml/1.0\">\n  <heading level=\"1\">\n    <text>Lorem Ipsum Dolor Sit Amet</text>\n  </heading>\n  <paragraph>\n    <text>Consectetur adipiscing elit. Integer pulvinar ipsum a ante ornare dignissim. Nulla vel lacus feugiat, volutpat risus eget, semper nisl.</text>\n  </paragraph>\n  <list type=\"ordered\" start=\"1\" delim=\"period\" tight=\"true\">\n    <item>\n      <paragraph>\n        <text>Quisque varius nisi</text>\n      </paragraph>\n    </item>\n    <item>\n      <paragraph>\n        <text>Quisque ac sem ac lacus</text>\n      </paragraph>\n    </item>\n  </list>\n</document>\n"
      iex> Cmark.to_latex(markdown)
      "\\section{Lorem Ipsum Dolor Sit Amet}\n\nConsectetur adipiscing elit. Integer pulvinar ipsum a ante ornare dignissim. Nulla vel lacus feugiat, volutpat risus eget, semper nisl.\n\n\\begin{enumerate}\n\\item Quisque varius nisi\n\n\\item Quisque ac sem ac lacus\n\n\\end{enumerate}\n"
      iex> Cmark.to_man(markdown)
      ".SH\nLorem Ipsum Dolor Sit Amet\n.PP\nConsectetur adipiscing elit. Integer pulvinar ipsum a ante ornare dignissim. Nulla vel lacus feugiat, volutpat risus eget, semper nisl.\n.IP \"1.\" 4\nQuisque varius nisi\n.IP \"2.\" 4\nQuisque ac sem ac lacus\n"

  """
  @formats |> Enum.map(fn {format, _} ->
    def unquote(:"to_#{format}")(data) when is_list(data) do
      parse_doc_list(data, [], unquote(format))
    end

    def unquote(:"to_#{format}")(data) when is_bitstring(data) do
      parse_doc(data, [], unquote(format))
    end
  end)


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

  @formats |> Enum.map(fn {format, _} ->
    def unquote(:"to_#{format}")(data, options) when is_list(data) and is_list(options) do
      parse_doc_list(data, options, unquote(format))
    end

    def unquote(:"to_#{format}")(data, options) when is_bitstring(data) and is_list(options) do
      parse_doc(data, options, unquote(format))
    end
  end)

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
  @formats |> Enum.map(fn {format, _} ->
    def unquote(:"to_#{format}")(data, callback) when is_list(data) and is_function(callback) do
      parse_doc_list(data, callback, [], unquote(format))
    end

    def unquote(:"to_#{format}")(data, callback) when is_bitstring(data) and is_function(callback) do
      parse_doc(data, callback, [], unquote(format))
    end
  end)


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
  @formats |> Enum.map(fn {format, _} ->
    def unquote(:"to_#{format}")(data, callback, options) when is_list(data) and is_list(options) do
      parse_doc_list(data, callback, options, unquote(format))
    end

    def unquote(:"to_#{format}")(data, callback, options) when is_bitstring(data) and is_list(options) do
      parse_doc(data, callback, options, unquote(format))
    end
  end)


  @doc """
  Compiles a list of Markdown documents using provided options and calls
  function for each item.

  ## Examples

      iex> callback = fn (html) -> "HTML is \#{html |> String.strip}" end
      iex> ["list", "test"] |> Cmark.to_html_each(callback)
      ["HTML is <p>list</p>", "HTML is <p>test</p>"]

  """
  @formats |> Enum.map(fn {format, _} ->
   def unquote(:"to_#{format}_each")(data, callback, options \\ []) when is_list(data) do
     parse_doc_list_each(data, callback, options, unquote(format))
   end
 end)


  defp parse_doc_list(documents, callback, options, format) when is_function(callback) do
    callback.(parse_doc_list(documents, options, format))
  end

  defp parse_doc_list(documents, options, format) when is_list(options) do
    documents
    |> Enum.map(&Task.async(fn -> parse_doc(&1, options, format) end))
    |> Enum.map(&Task.await(&1))
  end


  defp parse_doc_list_each(documents, callback, options, format) do
    documents
    |> Enum.map(&Task.async(fn -> parse_doc(&1, callback, options, format) end))
    |> Enum.map(&Task.await(&1))
  end


  defp parse_doc(document, callback, options, format) do
    callback.(parse_doc(document, options, format))
  end

  defp parse_doc(document, options, format) do
    Cmark.Nif.render(document, parse_options(options), parse_format(format))
  end


  defp parse_options(options) do
    Enum.reduce(options, 0, fn(flag, acc) -> (@flags[flag] || 0) + acc end)
  end

  defp parse_format(format) do
    @formats[format]
  end
end
