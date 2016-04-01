defmodule Cmark do
  alias Cmark.Parser

  @moduledoc """
  Compiles Markdown formatted text into HTML or one of the other supported target formats.

  Provides:

  HTML

  - `to_html/1`
  - `to_html/2`
  - `to_html/3`
  - `to_html_each/2`
  - `to_html_each/3`

  XML

  - `to_xml/1`
  - `to_xml/2`
  - `to_xml/3`
  - `to_xml_each/2`
  - `to_xml_each/3`

  Manpage

  - `to_man/1`
  - `to_man/2`
  - `to_man/3`
  - `to_man_each/2`
  - `to_man_each/3`

  CommonMark

  - `to_commonmark/1`
  - `to_commonmark/2`
  - `to_commonmark/3`
  - `to_commonmark_each/2`
  - `to_commonmark_each/3`

  LaTeX

  - `to_latex/1`
  - `to_latex/2`
  - `to_latex/3`
  - `to_latex_each/2`
  - `to_latex_each/3`

  """

  @typedoc "List of strings"
  @type string_list :: [String.t]

  @typedoc "Either a string or a list of strings"
  @type string_or_list :: String.t | string_list

  @typedoc "A callback function which can return anything"
  @type callback_fun :: (function -> any)

  @options_doc """
  Available options are:

  - `:sourcepos` - Include a `data-sourcepos` attribute on all block elements.
  - `:softbreak` - Render `softbreak` elements as hard line breaks.
  - `:normalize` - Normalize tree by consolidating adjacent text nodes.
  - `:smart` - Convert straight quotes to curly, --- to em dashes, -- to en dashes.
  - `:validate_utf8` - Validate UTF-8 in the input before parsing, replacing
     illegal sequences with the replacement character U+FFFD.
  - `:safe` - Suppress raw HTML and unsafe links (`javascript:`, `vbscript:`,
    `file:`, and `data:`, except for `image/png`, `image/gif`, `image/jpeg`, or
    `image/webp` mime types).  Raw HTML is replaced by a placeholder HTML
    comment. Unsafe links are replaced by empty strings.
  """

  @typedoc "A list of atoms describing the options to use
            (for details check documentation of any function using options)"
  @type options_list :: [atom]

  @typedoc "Either an options list or a callback function"
  @type options_or_callback :: options_list | callback_fun

  # HTML #

  @doc ~S"""
  Compiles one or more (list) Markdown documents to HTML and returns result.

  - `data` is either a string or a list

  ## Examples

      iex> "test" |> Cmark.to_html
      "<p>test</p>\n"

      iex> ["test 1", "test 2"] |> Cmark.to_html
      ["<p>test 1</p>\n", "<p>test 2</p>\n"]

  """
  @spec to_html(string_or_list) :: string_or_list
  def to_html(data),
    do: Parser.parse(:html, data)

  @doc ~S"""
  Compiles one or more (list) Markdown documents to HTML using provided options
  and returns result.

  - `data` is either a string or a list
  - `options_or_callback` is either an option list or a callback function

  """ <> @options_doc <> ~S"""

  ## Examples

      iex> Cmark.to_html(~s(Use option to enable "smart" quotes.), [:smart])
      "<p>Use option to enable “smart” quotes.</p>\n"

      iex> Cmark.to_html([~s(Something "smart"), ~s(em---dashed)], [:smart])
      ["<p>Something “smart”</p>\n", "<p>em—dashed</p>\n"]

  -----

  Compiles one or more (list) Markdown documents to HTML and calls function with result.

  ## Examples

      iex> callback = fn (result) -> "HTML is #{result}" |> String.strip end
      iex> Cmark.to_html("test", callback)
      "HTML is <p>test</p>"

      iex> callback = fn (results) ->
      iex>   Enum.map(results, &String.strip/1) |> Enum.join("<hr>")
      iex> end
      iex> Cmark.to_html(["list", "test"], callback)
      "<p>list</p><hr><p>test</p>"

  """
  @spec to_html(string_or_list, options_or_callback) :: string_or_list
  def to_html(data, options_or_callback),
    do: Parser.parse(:html, data, options_or_callback)

  @doc ~S"""
  Compiles one or more (list) Markdown documents to HTML using provided options
  and calls function with result.

  - `data` is either a string or a list
  - `callback` is a callback function
  - `options` is an option list

  """ <> @options_doc <> ~S"""

  ## Examples

      iex> callback = fn (result) -> {:ok, result} end
      iex> Cmark.to_html(~s(Something "smart" and ... ---you get it!), callback, [:smart])
      {:ok, "<p>Something “smart” and … —you get it!</p>\n"}

      iex> callback = fn (results) ->
      iex>   Enum.map(results, &String.strip/1) |> Enum.join("<hr>")
      iex> end
      iex> Cmark.to_html(["en-dash --", "ellipsis..."], callback, [:smart])
      "<p>en-dash –</p><hr><p>ellipsis…</p>"

  """
  @spec to_html(string_or_list, callback_fun, options_list) :: string_or_list
  def to_html(data, callback, options),
    do: Parser.parse(:html, data, callback, options)

  @doc ~S"""
  Compiles a list of Markdown documents to HTML and calls function for each item.

  - `data` is either a string or a list
  - `callback` is a callback function

  ## Examples

      iex> callback = fn (result) -> "HTML is #{result |> String.strip}" end
      iex> Cmark.to_html_each(["list", "test"], callback)
      ["HTML is <p>list</p>", "HTML is <p>test</p>"]

  """
  @spec to_html_each(string_or_list, callback_fun) :: list
  def to_html_each(data, callback),
    do: Parser.parse_each(:html, data, callback)

  @doc ~S"""
  Compiles a list of Markdown documents to HTML using provided options and calls
  function for each item.

  - `data` is either a string or a list
  - `callback` is a callback function
  - `options` is an option list

  """ <> @options_doc <> ~S"""

  ## Examples

      iex> callback = fn (result) -> "HTML is #{result |> String.strip}" end
      iex> Cmark.to_html_each(["list --", "test..."], callback, [:smart])
      ["HTML is <p>list –</p>", "HTML is <p>test…</p>"]

  """
  @spec to_html_each(string_or_list, callback_fun, options_list) :: list
  def to_html_each(data, callback, options),
    do: Parser.parse_each(:html, data, callback, options)

  # XML #

  @doc ~S"""
  Compiles one or more (list) Markdown documents to XML and returns result.

  - `data` is either a string or a list

  ## Examples

      iex> "test" |> Cmark.to_xml
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">
      <document xmlns=\"http://commonmark.org/xml/1.0\">\n  <paragraph>\n    <text>test</text>\n  </paragraph>
      </document>\n"

      iex> ["test 1", "test 2"] |> Cmark.to_xml
      ["<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">
      <document xmlns=\"http://commonmark.org/xml/1.0\">\n  <paragraph>\n    <text>test 1</text>\n  </paragraph>
      </document>\n",
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">
      <document xmlns=\"http://commonmark.org/xml/1.0\">\n  <paragraph>\n    <text>test 2</text>\n  </paragraph>
      </document>\n"]

  """
  @spec to_xml(string_or_list) :: string_or_list
  def to_xml(data),
    do: Parser.parse(:xml, data)

  @doc ~S"""
  Compiles one or more (list) Markdown documents to XML using provided options
  and returns result.

  - `data` is either a string or a list
  - `options_or_callback` is either an option list or a callback function

  """ <> @options_doc <> ~S"""

  ## Examples

      iex> Cmark.to_xml(~s(Use option to enable "smart" quotes.), [:smart])
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">
      <document xmlns=\"http://commonmark.org/xml/1.0\">\n  <paragraph>\n    <text>Use option to enable </text>
          <text>“</text>\n    <text>smart</text>\n    <text>”</text>\n    <text> quotes</text>\n    <text>.</text>
        </paragraph>\n</document>\n"

      iex> Cmark.to_xml([~s(Something "smart"), ~s(em---dashed)], [:smart])
      ["<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">
      <document xmlns=\"http://commonmark.org/xml/1.0\">\n  <paragraph>\n    <text>Something </text>
          <text>“</text>\n    <text>smart</text>\n    <text>”</text>\n  </paragraph>\n</document>\n",
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">
      <document xmlns=\"http://commonmark.org/xml/1.0\">\n  <paragraph>\n    <text>em</text>
          <text>—</text>\n    <text>dashed</text>\n  </paragraph>\n</document>\n"]

  -----

  Compiles one or more (list) Markdown documents to XML and calls function with result.

  ## Examples

      iex> callback = fn (result) -> "XML is #{result}" |> String.strip end
      iex> Cmark.to_xml("test", callback)
      "XML is <?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">
      <document xmlns=\"http://commonmark.org/xml/1.0\">\n  <paragraph>\n    <text>test</text>\n  </paragraph>
      </document>"

      iex> callback = fn (results) ->
      iex>   Enum.map(results, &String.strip/1) |> Enum.join("<joiner>")
      iex> end
      iex> Cmark.to_xml(["list", "test"], callback)
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">
      <document xmlns=\"http://commonmark.org/xml/1.0\">\n  <paragraph>\n    <text>list</text>\n  </paragraph>
      </document><joiner><?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">
      <document xmlns=\"http://commonmark.org/xml/1.0\">\n  <paragraph>\n    <text>test</text>\n  </paragraph>
      </document>"

  """
  @spec to_xml(string_or_list, options_or_callback) :: string_or_list
  def to_xml(data, options_or_callback),
    do: Parser.parse(:xml, data, options_or_callback)

  @doc ~S"""
  Compiles one or more (list) Markdown documents to XML using provided options
  and calls function with result.

  - `data` is either a string or a list
  - `callback` is a callback function
  - `options` is an option list

  """ <> @options_doc <> ~S"""

  ## Examples

      iex> callback = fn (result) -> {:ok, result} end
      iex> Cmark.to_xml(~s(Something "smart" and ... ---you get it!), callback, [:smart])
      {:ok, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">
      <document xmlns=\"http://commonmark.org/xml/1.0\">\n  <paragraph>\n    <text>Something </text>
          <text>“</text>\n    <text>smart</text>\n    <text>”</text>\n    <text> and </text>\n    <text>…</text>
          <text> </text>\n    <text>—</text>\n    <text>you get it</text>\n    <text>!</text>\n  </paragraph>
      </document>\n"}

      iex> callback = fn (results) ->
      iex>   Enum.map(results, &String.strip/1) |> Enum.join("<joiner>")
      iex> end
      iex> Cmark.to_xml(["en-dash --", "ellipsis..."], callback, [:smart])
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">
      <document xmlns=\"http://commonmark.org/xml/1.0\">\n  <paragraph>\n    <text>en</text>\n    <text>-</text>
          <text>dash </text>\n    <text>–</text>\n  </paragraph>
      </document><joiner><?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">
      <document xmlns=\"http://commonmark.org/xml/1.0\">\n  <paragraph>\n    <text>ellipsis</text>\n    <text>…</text>
        </paragraph>\n</document>"

  """
  @spec to_xml(string_or_list, callback_fun, options_list) :: string_or_list
  def to_xml(data, callback, options),
    do: Parser.parse(:xml, data, callback, options)

  @doc ~S"""
  Compiles a list of Markdown documents to XML and calls function for each item.

  - `data` is either a string or a list
  - `callback` is a callback function

  ## Examples

      iex> callback = fn (result) -> "XML is #{result |> String.strip}" end
      iex> Cmark.to_xml_each(["list", "test"], callback)
      ["XML is <?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">
      <document xmlns=\"http://commonmark.org/xml/1.0\">\n  <paragraph>\n    <text>list</text>\n  </paragraph>
      </document>",
      "XML is <?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">
      <document xmlns=\"http://commonmark.org/xml/1.0\">\n  <paragraph>\n    <text>test</text>\n  </paragraph>
      </document>"]

  """
  @spec to_xml_each(string_or_list, callback_fun) :: list
  def to_xml_each(data, callback),
    do: Parser.parse_each(:xml, data, callback)

  @doc ~S"""
  Compiles a list of Markdown documents to XML using provided options and calls
  function for each item.

  - `data` is either a string or a list
  - `callback` is a callback function
  - `options` is an option list

  """ <> @options_doc <> ~S"""

  ## Examples

      iex> callback = fn (result) -> "XML is #{result |> String.strip}" end
      iex> Cmark.to_xml_each(["list --", "test..."], callback, [:smart])
      ["XML is <?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">
      <document xmlns=\"http://commonmark.org/xml/1.0\">\n  <paragraph>\n    <text>list </text>\n    <text>–</text>
        </paragraph>\n</document>",
      "XML is <?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">
      <document xmlns=\"http://commonmark.org/xml/1.0\">\n  <paragraph>\n    <text>test</text>\n    <text>…</text>
        </paragraph>\n</document>"]

  """
  @spec to_xml_each(string_or_list, callback_fun, options_list) :: list
  def to_xml_each(data, callback, options),
    do: Parser.parse_each(:xml, data, callback, options)

  # Manpage #

  @doc ~S"""
  Compiles one or more (list) Markdown documents to Manpage and returns result.

  - `data` is either a string or a list

  ## Examples

      iex> "test" |> Cmark.to_man
      ".PP\ntest\n"

      iex> ["test 1", "test 2"] |> Cmark.to_man
      [".PP\ntest 1\n", ".PP\ntest 2\n"]

  """
  @spec to_man(string_or_list) :: string_or_list
  def to_man(data),
    do: Parser.parse(:man, data)

  @doc ~S"""
  Compiles one or more (list) Markdown documents to Manpage using provided options
  and returns result.

  - `data` is either a string or a list
  - `options_or_callback` is either an option list or a callback function

  """ <> @options_doc <> ~S"""

  ## Examples

      iex> Cmark.to_man(~s(Use option to enable "smart" quotes.), [:smart])
      ".PP\nUse option to enable \\[lq]smart\\[rq] quotes.\n"

      iex> Cmark.to_man([~s(Something "smart"), ~s(em---dashed)], [:smart])
      [".PP\nSomething \\[lq]smart\\[rq]\n", ".PP\nem\\[em]dashed\n"]

  -----

  Compiles one or more (list) Markdown documents to Manpage and calls function with result.

  ## Examples

      iex> callback = fn (result) -> "Manpage is #{result}" |> String.strip end
      iex> Cmark.to_man("test", callback)
      "Manpage is .PP\ntest"

      iex> callback = fn (results) ->
      iex>   Enum.map(results, &String.strip/1) |> Enum.join("%%joiner%%")
      iex> end
      iex> Cmark.to_man(["list", "test"], callback)
      ".PP\nlist%%joiner%%.PP\ntest"
  """
  @spec to_man(string_or_list, options_or_callback) :: string_or_list
  def to_man(data, options_or_callback),
    do: Parser.parse(:man, data, options_or_callback)

  @doc ~S"""
  Compiles one or more (list) Markdown documents to Manpage using provided options
  and calls function with result.

  - `data` is either a string or a list
  - `callback` is a callback function
  - `options` is an option list

  """ <> @options_doc <> ~S"""

  ## Examples

      iex> callback = fn (result) -> {:ok, result} end
      iex> Cmark.to_man(~s(Something "smart" and ... ---you get it!), callback, [:smart])
      {:ok, ".PP\nSomething \\[lq]smart\\[rq] and … \\[em]you get it!\n"}

      iex> callback = fn (results) ->
      iex>   Enum.map(results, &String.strip/1) |> Enum.join("%%joiner%%")
      iex> end
      iex> Cmark.to_man(["en-dash --", "ellipsis..."], callback, [:smart])
      ".PP\nen\\-dash \\[en]%%joiner%%.PP\nellipsis…"

  """
  @spec to_man(string_or_list, callback_fun, options_list) :: string_or_list
  def to_man(data, callback, options),
    do: Parser.parse(:man, data, callback, options)

  @doc ~S"""
  Compiles a list of Markdown documents to Manpage and calls function for each item.

  - `data` is either a string or a list
  - `callback` is a callback function

  ## Examples

      iex> callback = fn (result) -> "Manpage is #{result |> String.strip}" end
      iex> Cmark.to_man_each(["list", "test"], callback)
      ["Manpage is .PP\nlist", "Manpage is .PP\ntest"]

  """
  @spec to_man_each(string_or_list, callback_fun) :: list
  def to_man_each(data, callback),
    do: Parser.parse_each(:man, data, callback)

  @doc ~S"""
  Compiles a list of Markdown documents to Manpage using provided options and calls
  function for each item.

  - `data` is either a string or a list
  - `callback` is a callback function
  - `options` is an option list

  """ <> @options_doc <> ~S"""

  ## Examples

      iex> callback = fn (result) -> "Manpage is #{result |> String.strip}" end
      iex> Cmark.to_man_each(["list --", "test..."], callback, [:smart])
      ["Manpage is .PP\nlist \\[en]", "Manpage is .PP\ntest…"]

  """
  @spec to_man_each(string_or_list, callback_fun, options_list) :: list
  def to_man_each(data, callback, options),
    do: Parser.parse_each(:man, data, callback, options)

  # CommonMark #

  @doc ~S"""
  Compiles one or more (list) Markdown documents to CommonMark and returns result.

  - `data` is either a string or a list

  ## Examples

      iex> "test" |> Cmark.to_commonmark
      "test\n"

      iex> ["test 1", "test 2"] |> Cmark.to_commonmark
      ["test 1\n", "test 2\n"]

  """
  @spec to_commonmark(string_or_list) :: string_or_list
  def to_commonmark(data),
    do: Parser.parse(:commonmark, data)

  @doc ~S"""
  Compiles one or more (list) Markdown documents to CommonMark using provided options
  and returns result.

  - `data` is either a string or a list
  - `options_or_callback` is either an option list or a callback function

  """ <> @options_doc <> ~S"""

  ## Examples

      iex> Cmark.to_commonmark(~s(Use option to enable "smart" quotes.), [:smart])
      "Use option to enable “smart” quotes.\n"

      iex> Cmark.to_commonmark([~s(Something "smart"), ~s(em---dashed)], [:smart])
      ["Something “smart”\n", "em—dashed\n"]

  -----

  Compiles one or more (list) Markdown documents to CommonMark and calls function with result.

  ## Examples

      iex> callback = fn (result) -> "CommonMark is #{result}" |> String.strip end
      iex> Cmark.to_commonmark("test", callback)
      "CommonMark is test"

      iex> callback = fn (results) ->
      iex>   Enum.map(results, &String.strip/1) |> Enum.join("%%joiner%%")
      iex> end
      iex> Cmark.to_commonmark(["list", "test"], callback)
      "list%%joiner%%test"
  """
  @spec to_commonmark(string_or_list, options_or_callback) :: string_or_list
  def to_commonmark(data, options_or_callback),
    do: Parser.parse(:commonmark, data, options_or_callback)

  @doc ~S"""
  Compiles one or more (list) Markdown documents to CommonMark using provided options
  and calls function with result.

  - `data` is either a string or a list
  - `callback` is a callback function
  - `options` is an option list

  """ <> @options_doc <> ~S"""

  ## Examples

      iex> callback = fn (result) -> {:ok, result} end
      iex> Cmark.to_commonmark(~s(Something "smart" and ... ---you get it!), callback, [:smart])
      {:ok, "Something “smart” and … —you get it\\!\n"}

      iex> callback = fn (results) ->
      iex>   Enum.map(results, &String.strip/1) |> Enum.join("%%joiner%%")
      iex> end
      iex> Cmark.to_commonmark(["en-dash --", "ellipsis..."], callback, [:smart])
      "en-dash –%%joiner%%ellipsis…"

  """
  @spec to_commonmark(string_or_list, callback_fun, options_list) :: string_or_list
  def to_commonmark(data, callback, options),
    do: Parser.parse(:commonmark, data, callback, options)

  @doc ~S"""
  Compiles a list of Markdown documents to CommonMark and calls function for each item.

  - `data` is either a string or a list
  - `callback` is a callback function

  ## Examples

      iex> callback = fn (result) -> "CommonMark is #{result |> String.strip}" end
      iex> Cmark.to_commonmark_each(["list", "test"], callback)
      ["CommonMark is list", "CommonMark is test"]

  """
  @spec to_commonmark_each(string_or_list, callback_fun) :: list
  def to_commonmark_each(data, callback),
    do: Parser.parse_each(:commonmark, data, callback)

  @doc ~S"""
  Compiles a list of Markdown documents to CommonMark using provided options and calls
  function for each item.

  - `data` is either a string or a list
  - `callback` is a callback function
  - `options` is an option list

  """ <> @options_doc <> ~S"""

  ## Examples

      iex> callback = fn (result) -> "CommonMark is #{result |> String.strip}" end
      iex> Cmark.to_commonmark_each(["list --", "test..."], callback, [:smart])
      ["CommonMark is list –", "CommonMark is test…"]

  """
  @spec to_commonmark_each(string_or_list, callback_fun, options_list) :: list
  def to_commonmark_each(data, callback, options),
    do: Parser.parse_each(:commonmark, data, callback, options)

  # LaTeX #

  @doc ~S"""
  Compiles one or more (list) Markdown documents to LaTeX and returns result.

  - `data` is either a string or a list

  ## Examples

      iex> "test" |> Cmark.to_latex
      "test\n"

      iex> ["test 1", "test 2"] |> Cmark.to_latex
      ["test 1\n", "test 2\n"]

  """
  @spec to_latex(string_or_list) :: string_or_list
  def to_latex(data),
    do: Parser.parse(:latex, data)

  @doc ~S"""
  Compiles one or more (list) Markdown documents to LaTeX using provided options
  and returns result.

  - `data` is either a string or a list
  - `options_or_callback` is either an option list or a callback function

  """ <> @options_doc <> ~S"""

  ## Examples

      iex> Cmark.to_latex(~s(Use option to enable "smart" quotes.), [:smart])
      "Use option to enable ``smart'' quotes.\n"

      iex> Cmark.to_latex([~s(Something "smart"), ~s(em---dashed)], [:smart])
      ["Something ``smart''\n", "em---dashed\n"]

  -----

  Compiles one or more (list) Markdown documents to LaTeX and calls function with result.

  ## Examples

      iex> callback = fn (result) -> "LaTeX is #{result}" |> String.strip end
      iex> Cmark.to_latex("test", callback)
      "LaTeX is test"

      iex> callback = fn (results) ->
      iex>   Enum.map(results, &String.strip/1) |> Enum.join("%%joiner%%")
      iex> end
      iex> Cmark.to_latex(["list", "test"], callback)
      "list%%joiner%%test"
  """
  @spec to_latex(string_or_list, options_or_callback) :: string_or_list
  def to_latex(data, options_or_callback),
    do: Parser.parse(:latex, data, options_or_callback)

  @doc ~S"""
  Compiles one or more (list) Markdown documents to LaTeX using provided options
  and calls function with result.

  - `data` is either a string or a list
  - `callback` is a callback function
  - `options` is an option list

  """ <> @options_doc <> ~S"""

  ## Examples

      iex> callback = fn (result) -> {:ok, result} end
      iex> Cmark.to_latex(~s(Something "smart" and ... ---you get it!), callback, [:smart])
      {:ok, "Something ``smart'' and \\ldots{} ---you get it!\n"}

      iex> callback = fn (results) ->
      iex>   Enum.map(results, &String.strip/1) |> Enum.join("%%joiner%%")
      iex> end
      iex> Cmark.to_latex(["en-dash --", "ellipsis..."], callback, [:smart])
      "en-dash --%%joiner%%ellipsis\\ldots{}"

  """
  @spec to_latex(string_or_list, callback_fun, options_list) :: string_or_list
  def to_latex(data, callback, options),
    do: Parser.parse(:latex, data, callback, options)

  @doc ~S"""
  Compiles a list of Markdown documents to LaTeX and calls function for each item.

  - `data` is either a string or a list
  - `callback` is a callback function

  ## Examples

      iex> callback = fn (result) -> "LaTeX is #{result |> String.strip}" end
      iex> Cmark.to_latex_each(["list", "test"], callback)
      ["LaTeX is list", "LaTeX is test"]

  """
  @spec to_latex_each(string_or_list, callback_fun) :: list
  def to_latex_each(data, callback),
    do: Parser.parse_each(:latex, data, callback)

  @doc ~S"""
  Compiles a list of Markdown documents to LaTeX using provided options and calls
  function for each item.

  - `data` is either a string or a list
  - `callback` is a callback function
  - `options` is an option list

  """ <> @options_doc <> ~S"""

  ## Examples

      iex> callback = fn (result) -> "LaTeX is #{result |> String.strip}" end
      iex> Cmark.to_latex_each(["list --", "test..."], callback, [:smart])
      ["LaTeX is list --", "LaTeX is test\\ldots{}"]

  """
  @spec to_latex_each(string_or_list, callback_fun, options_list) :: list
  def to_latex_each(data, callback, options),
    do: Parser.parse_each(:latex, data, callback, options)
end
