defmodule Telegraf.Transport do
  @moduledoc """
  Defines a transport for `Telegraf`.

  A transport implements a method to communicate with the telegraf daemon,
  sending already serialized messages.
  """

  @doc """
  Sends a message to the telegraf daemon.
  """
  @callback send(name :: Telegraf.name(), message :: binary(), opts :: Keyword.t()) ::
              :ok | {:error, term()}

  @doc """
  Returns a list of children to be started by the `Telegraf` supervisor.

  Use it to start any processes necessary to the transport of the messages.
  Ex: Pool of connections with the daemon.
  """
  @callback children(name :: Telegraf.name(), opts :: Keyword.t()) :: [Supervisor.child_spec()]
end
