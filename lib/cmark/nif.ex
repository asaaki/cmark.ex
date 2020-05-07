defmodule Cmark.Nif do
  @moduledoc false
  @on_load {:init, 0}

  @doc false
  @spec init :: :ok
  def init do
    path = Application.app_dir(:cmark, "priv/cmark")
    :ok = :erlang.load_nif(String.to_charlist(path), 0)
  end

  @doc false
  @spec render(String.t(), integer, integer) :: String.t()
  def render(_data, _options, _format),
    do: exit(:nif_library_not_loaded)
end
