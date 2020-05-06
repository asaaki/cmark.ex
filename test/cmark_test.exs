defmodule CmarkTest do
  use ExUnit.Case, async: true

  test "empty strings" do
    assert Cmark.to_html("") == ""
    assert Cmark.to_man("") == "\n"
    assert Cmark.to_commonmark("") == "\n"
    assert Cmark.to_latex("") == "\n"
    assert Cmark.to_xml("") == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE document SYSTEM \"CommonMark.dtd\">\n<document xmlns=\"http://commonmark.org/xml/1.0\" />\n"
  end

  test "UTF-8" do
    assert Cmark.to_html(<<0>>) == "<p>�</p>\n"
    assert Cmark.to_man(<<0>>) == ".PP\n�\n"
    assert Cmark.to_commonmark(<<0>>) == "�\n"
    assert Cmark.to_latex(<<0>>) == "�\n"
    assert Cmark.to_xml(<<0>>) =~ "<text xml:space=\"preserve\">�</text>"

    assert Cmark.to_html(<<255>>) == "<p>\xFF</p>\n"
    assert Cmark.to_man(<<255>>) == ".PP\n"
    assert Cmark.to_commonmark(<<255>>) == "\n"
    assert Cmark.to_latex(<<255>>) == "\n"
    assert Cmark.to_xml(<<255>>) =~ "<text xml:space=\"preserve\">\xFF</text>"

    assert Cmark.to_html(<<255>>, [:validate_utf8]) == "<p>�</p>\n"
    assert Cmark.to_man(<<255>>, [:validate_utf8]) == ".PP\n�\n"
    assert Cmark.to_commonmark(<<255>>, [:validate_utf8]) == "�\n"
    assert Cmark.to_latex(<<255>>, [:validate_utf8]) == "�\n"
    assert Cmark.to_xml(<<255>>, [:validate_utf8]) =~ "<text xml:space=\"preserve\">�</text>"
  end

  @invalid_when_safe [
    "<script>alert(document.cookie);</script>",
    "</span>",
    ~S(<a href="https://example.com">)
  ]

  for markdown <- @invalid_when_safe do
    test "Removes HTML by default: #{markdown}" do
      real_markdown = unquote(markdown)
      actual_html  = Cmark.to_html(real_markdown)
      expected_html = "<!-- raw HTML omitted -->\n"
      error_message = """
      MARKDOWN: #{inspect real_markdown}
      ACTUAL:   #{inspect actual_html}
      EXPECTED: #{inspect expected_html}
      """
      assert actual_html == expected_html, error_message
    end
  end
end
