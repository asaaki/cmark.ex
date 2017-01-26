# Cmark

[![Hex.pm package version](https://img.shields.io/hexpm/v/cmark.svg?style=flat-square)](https://hex.pm/packages/cmark)
[![Hex.pm package docs](https://img.shields.io/badge/hex-docs-orange.svg?style=flat-square)](http://hexdocs.pm/cmark/)
[![Hex.pm package license](https://img.shields.io/hexpm/l/cmark.svg?style=flat-square)](https://github.com/asaaki/cmark.ex/blob/master/LICENSE)
[![Build Status (master)](https://img.shields.io/travis/asaaki/cmark.ex/master.svg?style=flat-square)](https://travis-ci.org/asaaki/cmark.ex)
[![Coverage Status (master)](https://img.shields.io/coveralls/asaaki/cmark.ex/master.svg?style=flat-square)](https://coveralls.io/r/asaaki/cmark.ex)
[![Inline docs](http://inch-ci.org/github/asaaki/cmark.ex.svg?branch=master&style=flat-square)](http://inch-ci.org/github/asaaki/cmark.ex)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/asaaki/cmark.ex.svg)](https://beta.hexfaktor.org/github/asaaki/cmark.ex)

Elixir NIF for [cmark (C)](https://github.com/jgm/cmark), a parser library following the [CommonMark](http://commonmark.org/) spec.

## CommonMark

> A strongly specified, highly compatible implementation of Markdown

For more information visit <http://commonmark.org/>.

## Install

### Prerequisites

You need a C compiler like `gcc` or `clang`.

### mix.exs

Add this to your dependencies:

```elixir
{:cmark, "~> 0.7"}
```

## Usage

### Quick example

```elixir
Cmark.to_html "a markdown string"
#=> "<p>a markdown string</p>\n"
```

More detailed documentation at <http://hexdocs.pm/cmark/>.

### Available functions

#### HTML

-   `Cmark.to_html/1`
-   `Cmark.to_html/2`
-   `Cmark.to_html/3`
-   `Cmark.to_html_each/2`
-   `Cmark.to_html_each/3`

#### XML

-   `Cmark.to_xml/1`
-   `Cmark.to_xml/2`
-   `Cmark.to_xml/3`
-   `Cmark.to_xml_each/2`
-   `Cmark.to_xml_each/3`

#### Manpage

-   `Cmark.to_man/1`
-   `Cmark.to_man/2`
-   `Cmark.to_man/3`
-   `Cmark.to_man_each/2`
-   `Cmark.to_man_each/3`

#### CommonMark

-   `Cmark.to_commonmark/1`
-   `Cmark.to_commonmark/2`
-   `Cmark.to_commonmark/3`
-   `Cmark.to_commonmark_each/2`
-   `Cmark.to_commonmark_each/3`

#### LaTeX

-   `Cmark.to_latex/1`
-   `Cmark.to_latex/2`
-   `Cmark.to_latex/3`
-   `Cmark.to_latex_each/2`
-   `Cmark.to_latex_each/3`

## Documentation

Latest API docs can be found at: <http://hexdocs.pm/cmark/Cmark.html>

## Licenses

-   Cmark.ex: [LICENSE](./LICENSE) (MIT)
-   cmark (C): [c_src/COPYING](./c_src/COPYING) (multiple)
