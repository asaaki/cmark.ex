# Cmark

[![Build Status](https://travis-ci.org/asaaki/cmark.ex.svg?branch=master)](https://travis-ci.org/asaaki/cmark.ex)

Elixir NIF for [CommonMark (in C)](https://github.com/jgm/CommonMark), a parser following the [CommonMark](http://commonmark.org/) spec.

## Install

### Prerequisites

You need `make` (mostly present), `cmake` and `re2c` (both are not present in default system setups).

If you want to run the specs, also `perl` needs to be installed.

### mix.exs

```elixir
{ :cmark, "~> 0.2.0" }
```

## Usage

```elixir
Cmark.to_html "a markdown string"
#=> "<p>a markdown string</p>\n"
```

## License

[MIT/X11](./LICENSE)
