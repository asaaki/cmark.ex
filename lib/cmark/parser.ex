defmodule Cmark.Parser do
  alias Cmark.Nif

  @doc false
  def parse(format, data) when is_list(data),
    do: parse_doc_list(data, [], format)
  def parse(format, data) when is_bitstring(data),
    do: parse_doc(data, [], format)

  @doc false
  def parse(format, data, options) when is_list(data) and is_list(options),
    do: parse_doc_list(data, options, format)
  def parse(format, data, options) when is_bitstring(data) and is_list(options),
    do: parse_doc(data, options, format)

  @doc false
  def parse(format, data, callback) when is_list(data) and is_function(callback),
    do: parse_doc_list(data, callback, [], format)
  def parse(format, data, callback) when is_bitstring(data) and is_function(callback),
    do: parse_doc(data, callback, [], format)

  @doc false
  def parse(format, data, callback, options) when is_list(data) and is_function(callback) and is_list(options),
    do: parse_doc_list(data, callback, options, format)
  def parse(format, data, callback, options) when is_bitstring(data) and is_function(callback) and is_list(options),
    do: parse_doc(data, callback, options, format)

  @doc false
  def parse_each(format, data, callback, options \\ []) when is_list(data),
    do: parse_doc_list_each(data, callback, options, format)

  @doc false
  def parse_doc_list(documents, callback, options, format) when is_function(callback) do
    callback.(parse_doc_list(documents, options, format))
  end

  @doc false
  defp parse_doc_list(documents, options, format) when is_list(options) do
    documents
    |> Enum.map(&Task.async(fn -> parse_doc(&1, options, format) end))
    |> Enum.map(&Task.await(&1))
  end

  @doc false
  defp parse_doc_list_each(documents, callback, options, format) do
    documents
    |> Enum.map(&Task.async(fn -> parse_doc(&1, callback, options, format) end))
    |> Enum.map(&Task.await(&1))
  end


  @doc false
  defp parse_doc(document, callback, options, format),
    do: callback.(parse_doc(document, options, format))

  @doc false
  defp parse_doc(document, options, format),
    do: Nif.render(document, parse_options(options), format_id(format))

  # c_src/cmark.h -> CMARK_OPT_*
  @flags %{
    sourcepos: 2,        # (1 <<< 1)
    hardbreaks: 4,       # (1 <<< 2)
    safe: 16,            # (1 <<< 3)
    normalize: 256,      # (1 <<< 8)
    validate_utf8: 512,  # (1 <<< 9)
    smart: 1024,         # (1 <<< 10)
  }

  @doc false
  defp parse_options(options),
    do: Enum.reduce(options, 0, fn(flag, acc) -> @flags[flag] + acc end)

  @doc false
  defp format_id(:html), do: 1
  defp format_id(:xml), do: 2
  defp format_id(:man), do: 3
  defp format_id(:commonmark), do: 4
  defp format_id(:latex), do: 5
  # defp format_id(_), do: 1
end
