defmodule CmarkTest do
  use ExUnit.Case, async: true

  @cmark_specs "test/cmark_specs.json" |> File.read! |> Jason.decode!(keys: :atoms)

  for %{
        section: section,
        example: example,
        markdown: markdown,
        html: html,
        start_line: start_line,
        end_line: end_line
      } <- @cmark_specs do
    test "Section: »#{section}«, Example: #{example}, Lines: #{start_line}-#{end_line}" do
      real_markdown = unquote(markdown)
      actual_html   = Cmark.to_html(real_markdown, [:unsafe])
      expected_html = unquote(html)
      error_message = """
      MARKDOWN: #{inspect real_markdown}
      ACTUAL:   #{inspect actual_html}
      EXPECTED: #{inspect expected_html}
      """
      assert actual_html == expected_html, error_message
    end
  end

  @cmark_smart_punct "test/cmark_smart_punct.json" |> File.read! |> Jason.decode!(keys: :atoms)

  for %{
        section: section,
        example: example,
        markdown: markdown,
        html: html,
        start_line: start_line,
        end_line: end_line
      } <- @cmark_smart_punct do
    test "Section: »#{section}«, Example: #{example}, Lines: #{start_line}-#{end_line}" do
      real_markdown = unquote(markdown)
      actual_html   = Cmark.to_html(real_markdown, [:smart])
      expected_html = unquote(html)
      error_message = """
      MARKDOWN: #{inspect real_markdown}
      ACTUAL:   #{inspect actual_html}
      EXPECTED: #{inspect expected_html}
      """
      assert actual_html == expected_html, error_message
    end
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
