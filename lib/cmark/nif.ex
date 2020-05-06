defmodule Cmark.Nif do
  @moduledoc false
  @on_load {:init, 0}

  @doc false
  @spec init :: :ok
  def init do
    :ok = :erlang.load_nif(nif_path(), 0)
  end

  @doc false
  defp nif_path,
    do: :filename.join(priv_dir(), 'cmark')

  @doc false
  defp priv_dir do
    :cmark
    |> :code.priv_dir
    |> maybe_priv_dir
  end

  @doc false
  defp maybe_priv_dir({:error, _}) do
    :cmark
    |> :code.which
    |> :filename.dirname
    |> :filename.dirname
    |> :filename.join('priv')
  end
  defp maybe_priv_dir(path),
    do: path

  @doc false
  @spec render(String.t, list, integer) :: String.t
  # def render(data, options, format)
  def render(_, _, _),
    do: exit(:nif_library_not_loaded)
end
