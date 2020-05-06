defmodule Cmark do
  @moduledoc """
  Converts Markdown to supported target formats.

  All functions below support the following options:

    - `:sourcepos` -
      Include a `data-sourcepos` attribute on all block elements.
    - `:hardbreaks`
      Render `softbreak` elements as hard line breaks.
    - `:nobreaks`
      Render `softbreak` elements as spaces.
    - `:normalize`
      Normalize tree by consolidating adjacent text nodes.
    - `:smart`
      Convert straight quotes to curly, --- to em dashes, -- to en dashes.
    - `:validate_utf8`
      Validate UTF-8 in the input before parsing, replacing
      illegal sequences with the replacement character U+FFFD.
    - `:unsafe`
      Allow raw HTML and unsafe links (`javascript:`, `vbscript:`, `file:`, and
      `data:`, except for `image/png`, `image/gif`, `image/jpeg`, or `image/webp`
      mime types). The default is to treat everything as unsafe, which replaces
      invalid nodes by a placeholder HTML comment and unsafe links by empty strings.

  """

  @html_id 1
  @xml_id 2
  @man_id 3
  @commonmark_id 4
  @latex_id 5

  # c_src/cmark.h -> CMARK_OPT_*
  @flags %{
    sourcepos: 2,        # (1 <<< 1)
    hardbreaks: 4,       # (1 <<< 2)
    nobreaks: 16,        # (1 <<< 4)
    normalize: 256,      # (1 <<< 8)
    validate_utf8: 512,  # (1 <<< 9)
    smart: 1024,         # (1 <<< 10)
    unsafe: 131072       # (1 <<< 17)
  }

  @typedoc "A list of atoms describing the options to use (see module docs)"
  @type options_list ::
          [:sourcepos | :hardbreaks | :nobreaks | :normalize | :validate_utf8 | :smart | :unsafe]

  @doc ~S"""
  Converts the Markdown document to HTML.

  See `Cmark` module docs for all options.

  ## Examples

      iex> Cmark.to_html("test")
      "<p>test</p>\n"

  """
  @spec to_html(String.t, options_list) :: String.t
  def to_html(document, options_list \\ [])
      when is_binary(document) and is_list(options_list) do
    convert(document, options_list, @html_id)
  end

  @doc ~S"""
  Converts the Markdown document to XML.

  See `Cmark` module docs for all options.

  ## Examples

      iex> Cmark.to_xml("test")
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">\n<document xmlns=\"http://commonmark.org/xml/1.0\">\n  <paragraph>\n    <text xml:space=\"preserve\">test</text>\n  </paragraph>\n</document>\n"

  """
  @spec to_xml(String.t, options_list) :: String.t
  def to_xml(document, options_list \\ [])
      when is_binary(document) and is_list(options_list) do
    convert(document, options_list, @xml_id)
  end

  @doc ~S"""
  Converts the Markdown document to Manpage.

  See `Cmark` module docs for all options.

  ## Examples

      iex> Cmark.to_man("test")
      ".PP\ntest\n"

  """
  @spec to_man(String.t, options_list) :: String.t
  def to_man(document, options_list \\ [])
      when is_binary(document) and is_list(options_list) do
    convert(document, options_list, @man_id)
  end

  @doc ~S"""
  Converts the Markdown document to Commonmark.

  See `Cmark` module docs for all options.

  ## Examples

      iex> Cmark.to_commonmark("test")
      "test\n"

  """
  @spec to_commonmark(String.t, options_list) :: String.t
  def to_commonmark(document, options_list \\ [])
      when is_binary(document) and is_list(options_list) do
    convert(document, options_list, @commonmark_id)
  end

  @doc ~S"""
  Converts the Markdown document to LaTeX.

  See `Cmark` module docs for all options.

  ## Examples

      iex> Cmark.to_latex("test")
      "test\n"

  """
  @spec to_latex(String.t, options_list) :: String.t
  def to_latex(document, options_list \\ [])
      when is_binary(document) and is_list(options_list) do
    convert(document, options_list, @latex_id)
  end

  defp convert(document, options_list, format_id) when is_integer(format_id) do
    bitflag = Enum.reduce(options_list, 0, fn flag, acc -> Map.fetch!(@flags, flag) + acc end)
    Cmark.Nif.render(document, bitflag, format_id)
  end
end
