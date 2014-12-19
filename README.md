# Cmark

[![Hex.pm package version](https://img.shields.io/hexpm/v/cmark.svg?style=flat-square)](https://hex.pm/packages/cmark)
[![Hex.pm package license](https://img.shields.io/hexpm/l/cmark.svg?style=flat-square)](https://github.com/asaaki/cmark.ex/blob/master/LICENSE)
[![Build Status (master)](https://img.shields.io/travis/asaaki/cmark.ex/master.svg?style=flat-square)](https://travis-ci.org/asaaki/cmark.ex)
[![Coverage Status (master)](https://img.shields.io/coveralls/asaaki/cmark.ex/master.svg?style=flat-square)](https://coveralls.io/r/asaaki/cmark.ex)
[![Support via Gratipay](http://img.shields.io/gratipay/asaaki.svg?style=flat-square)](https://gratipay.com/asaaki)

Elixir NIF for [libcmark](https://github.com/jgm/CommonMark), a parser library following the [CommonMark](http://commonmark.org/) spec.

## Install

### Prerequisites

You need a C compiler like `gcc` or `clang`.

### mix.exs

```elixir
{ :cmark, "~> 0.4" }
```

## Usage

### Quick example

```elixir
Cmark.to_html "a markdown string"
#=> "<p>a markdown string</p>\n"
```

### `Cmark.to_html/1`

```elixir
"test" |> Cmark.to_html
#=> "<p>test</p>\n"
```

```elixir
["# also works", "* with list", "`of documents`"] |> Cmark.to_html
#=> ["<h1>also works</h1>\n",
#    "<ul>\n<li>with list</li>\n</ul>\n",
#    "<p><code>of documents</code></p>\n"]
```

### `Cmark.to_html/2`

```elixir
callback = fn (html) -> "HTML is #{html}" |> String.strip end
"test" |> Cmark.to_html(callback)
#=> "HTML is <p>test</p>"
```

```elixir
callback = fn (htmls) ->
 Enum.map(htmls, &String.strip/1) |> Enum.join("<hr>")
end
["list", "test"] |> Cmark.to_html(callback)
#=> "<p>list</p><hr><p>test</p>"
```

### `Cmark.to_html_each/2`

```elixir
callback = fn (html) -> "HTML is #{html |> String.strip}" end
["list", "test"] |> Cmark.to_html_each(callback)
#=> ["HTML is <p>list</p>", "HTML is <p>test</p>"]
```

## Licenses

- Cmark.ex: [MIT/X11](./LICENSE)
- CommonMark C code: [BSD](./c_src/LICENSE)
