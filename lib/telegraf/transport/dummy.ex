defmodule Telegraf.Transport.Dummy do
  @moduledoc """
  TODO
  """

  @behaviour Telegraf.Transport

  @impl Telegraf.Transport
  def children(_opts), do: []

  @impl Telegraf.Transport
  def send(_name, _message, _opts \\ []), do: :ok
end
