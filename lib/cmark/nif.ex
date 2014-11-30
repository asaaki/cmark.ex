defmodule Cmark.Nif do
  @on_load { :init, 0 }
  @moduledoc """
  NIF module

  Wraps the libcmark library.
  Do not use this module directly but via `Cmark`'s functions.
  """

  @doc false
  def init do
    path = :filename.join(:code.priv_dir(:cmark), 'cmark')
    :ok  = :erlang.load_nif(path, 1)
  end

  @doc false
  def to_html(_) do
    exit(:nif_library_not_loaded)
  end
end
