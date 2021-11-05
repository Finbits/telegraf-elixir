defmodule Telegraf.Transport.Dummy do
  @moduledoc """
  Dummy implementation of `Telegraf.Transport`. It does nothing.
  Useful to avoid setting up telegraf for development enviroment.

  ## Usage

      {Telegraf, name: MyTelegraf, transport: Telegraf.Transport.Dummy}

  """

  @behaviour Telegraf.Transport

  @impl Telegraf.Transport
  def children(_name, _opts), do: []

  @impl Telegraf.Transport
  def send(_name, _message, _opts \\ []), do: :ok
end
