defmodule Telegraf do
  use Supervisor

  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    Supervisor.start_link(__MODULE__, opts, name: name)
  end

  @impl true
  def init(opts) do
    name = Keyword.fetch!(opts, :name)
    transport = Keyword.fetch!(opts, :transport)
    serializer = Keyword.get(opts, :serializer, Telegraf.Serializer.LineProtocol)

    :persistent_term.put({__MODULE__, name}, {transport, serializer})

    opts
    |> transport.children()
    |> Supervisor.init(strategy: :one_for_one)
  end

  def send(name, metric_or_metrics, opts \\ []) do
    {transport, serializer} = :persistent_term.get({__MODULE__, name})

    message = metric_or_metrics |> List.wrap() |> serializer.serialize()

    transport.send(name, message, opts)
  end
end
