defmodule Cmark.Nif do
  @on_load { :init, 0 }
  @moduledoc """
  NIF module

  Wraps the libcmark library.
  Do not use this module directly but via `Cmark`'s functions.
  """

  @doc false
  def init do
    path = :filename.join(priv_dir, 'cmark')
    :ok  = :erlang.load_nif(path, 0)
  end

  defp priv_dir do
    case :code.priv_dir(:cmark) do
      {:error, _} ->
        :code.which(:cmark)
        |> :filename.dirname
        |> :filename.dirname
        |> :filename.join('priv')
      path ->
        path
    end
  end

  @doc false
  def render(_, _, _) do
    exit(:nif_library_not_loaded)
  end
end
