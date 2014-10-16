# Stmd

Elixir NIF for [stmd](https://github.com/jgm/stmd) (C implementation), a [CommonMark](http://commonmark.org/) parser

## Install

```elixir
{ :stmd, "~> 0.0.1" }
```

## Usage

```elixir
Stmd.to_html "a markdown string"
#=> "<p>a markdown string</p>\n"
```

## License

[MIT/X11](./LICENSE)
