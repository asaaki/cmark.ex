# Cmark

[![Build Status](https://travis-ci.org/asaaki/cmark.ex.svg?branch=master)](https://travis-ci.org/asaaki/cmark.ex)

Elixir NIF for [CommonMark (in C)](https://github.com/jgm/CommonMark), a parser following the [CommonMark](http://commonmark.org/) spec.

## Install

```elixir
{ :cmark, "~> 0.1.1" }
```

## Usage

```elixir
Cmark.to_html "a markdown string"
#=> "<p>a markdown string</p>\n"
```

## License

[MIT/X11](./LICENSE)
