# ![Cmark](./assets/cmark_ex_logo.png)

[![Hex.pm package version](https://img.shields.io/hexpm/v/cmark.svg?style=flat-square)](https://hex.pm/packages/cmark)
[![Hex.pm package docs](https://img.shields.io/badge/hex-docs-orange.svg?style=flat-square)](http://hexdocs.pm/cmark/)
[![Hex.pm package license](https://img.shields.io/hexpm/l/cmark.svg?style=flat-square)](https://github.com/asaaki/cmark.ex/blob/master/LICENSE)
[![Build Status (master)](https://img.shields.io/travis/asaaki/cmark.ex/master.svg?style=flat-square)](https://travis-ci.org/asaaki/cmark.ex)
[![Coverage Status (master)](https://img.shields.io/coveralls/asaaki/cmark.ex/master.svg?style=flat-square)](https://coveralls.io/r/asaaki/cmark.ex)
[![Inline docs](http://inch-ci.org/github/asaaki/cmark.ex.svg?branch=master&style=flat-square)](http://inch-ci.org/github/asaaki/cmark.ex)

**Cmark** is an Elixir NIF for [cmark (C)](https://github.com/jgm/cmark), a parser library following the [CommonMark](http://commonmark.org/) spec.

## CommonMark

> A strongly defined, highly compatible specification of Markdown

For more information visit <http://commonmark.org/>.

## Install

### Prerequisites

You need a C compiler like `gcc` or `clang`.

### mix.exs

Add this to your dependencies:

```elixir
{:cmark, "~> 0.8"}
```

## Usage

```elixir
Cmark.to_html("a markdown string")
#=> "<p>a markdown string</p>\n"
```

It supports conversions to HTML, XML, Manpage, CommonMark, and Latex.

Latest API docs can be found at: <http://hexdocs.pm/cmark/Cmark.html>

## Licenses

-   Cmark.ex: [LICENSE](https://github.com/asaaki/cmark.ex/blob/master/LICENSE) (MIT)
-   cmark (C): [c_src/COPYING](https://github.com/asaaki/cmark.ex/blob/master/c_src/COPYING) (multiple)
