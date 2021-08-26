defmodule Telegraf.Transport do
  @callback send(name :: atom(), message :: binary(), opts :: Keyword.t()) ::
              :ok | {:error, term()}
  @callback children(opts :: Keyword.t()) :: [Supervisor.child_spec()]
end
