defmodule Cmark do
  @moduledoc """
    Compiles Markdown formatted text into HTML
  """

  @doc """
    Compiles one or more (list) Markdown documents to HTML and returns result
  """
  def to_html(input) when is_list(input) do
    parse_doc_list input
  end

  def to_html(input) when is_bitstring(input) do
    parse_doc(input)
  end

  @doc """
    Compiles one or more (list) Markdown documents to HTML and calls function with result
  """
  def to_html(input, callback) when is_list(input) do
    parse_doc_list input, callback
  end

  def to_html(input, callback) when is_bitstring(input) do
    parse_doc input, callback
  end

  @doc """
    Compiles a list of Markdown documents and calls function for each item
  """
  def to_html_each(input, callback) when is_list(input) do
    parse_doc_list_each input, callback
  end

  ### PRIVATE

  defp parse_doc_list(documents) do
    documents
    |> Enum.map(&Task.async(fn -> parse_doc(&1) end))
    |> Enum.map(&Task.await(&1))
  end

  defp parse_doc_list(documents, callback) do
    callback.(parse_doc_list(documents))
  end

  defp parse_doc_list_each(documents, callback) do
    documents
    |> Enum.map(&Task.async(fn -> parse_doc(&1, callback) end))
    |> Enum.map(&Task.await(&1))
  end

  defp parse_doc(document) do
    Cmark.Nif.to_html(document)
  end

  defp parse_doc(document, callback) do
    callback.(Cmark.Nif.to_html(document))
  end
end
