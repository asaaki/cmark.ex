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

```elixir
Cmark.to_html "a markdown string"
#=> "<p>a markdown string</p>\n"
```

## License

[MIT/X11](./LICENSE)
