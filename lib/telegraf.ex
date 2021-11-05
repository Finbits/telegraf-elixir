defmodule Telegraf do
  use Supervisor

  @moduledoc """
  Telegraf client.

  Checkout `send/3` for more detailed usage.
  """

  @typedoc "Name of the telegraf instance."
  @type name :: atom()

  @opts_definition [
    name: [
      type: :atom,
      doc: "Name of the telegraf instance.",
      required: true
    ],
    transport: [
      type: :atom,
      doc: "A module implementing `Telegraf.Transport` behaviour.",
      default: Telegraf.Transport.UnixSocket
    ],
    transport_options: [
      type: :keyword_list,
      doc:
        "Options passed to the transport adapter. " <>
          "Checkout each transport adapter docs for a detailed description of the options.",
      default: []
    ],
    serializer: [
      type: :atom,
      doc: "A module implementing `Telegraf.Serializer` behaviour.",
      default: Telegraf.Serializer.LineProtocol
    ]
  ]

  @doc """
  Starts a #{inspect(__MODULE__)} supervisor.

  ## Supported options

  #{NimbleOptions.docs(@opts_definition)}
  """
  def start_link(opts) do
    opts = validate_options!(opts)

    name = Keyword.fetch!(opts, :name)
    Supervisor.start_link(__MODULE__, opts, name: name)
  end

  @impl Supervisor
  def init(opts) do
    name = Keyword.fetch!(opts, :name)
    transport = Keyword.fetch!(opts, :transport)
    serializer = Keyword.fetch!(opts, :serializer)
    transport_options = Keyword.fetch!(opts, :transport_options)

    :persistent_term.put({__MODULE__, name}, {transport, serializer})

    name
    |> transport.children(transport_options)
    |> Supervisor.init(strategy: :one_for_one)
  end

  @doc """
  Sends a metric to the telegraf daemon

  ## Usage

  1. Add `Telegraf` to your supervision tree:


  ```elixir
  {Telegraf, name: MyTelegraf}
  ```

  2. Send the metric:

  ```elixir
  metric = %Telegraf.Metric{
    name: "weather",
    tag_set: %{location: "us-midwest"},
    field_set: %{temperature: 82},
    timestamp: System.os_time()
  }

  Telegraf.send(MyTelegraf, metric)
  ```

  """
  @spec send(name(), Metric.t() | [Metric.t()], Keyword.t()) :: :ok | {:error, term()}
  def send(name, metric_or_metrics, opts \\ []) do
    {transport, serializer} = :persistent_term.get({__MODULE__, name})

    message = metric_or_metrics |> List.wrap() |> serializer.serialize()

    transport.send(name, message, opts)
  end

  defp validate_options!(opts) do
    case NimbleOptions.validate(opts, @opts_definition) do
      {:ok, opts} ->
        opts

      {:error, %NimbleOptions.ValidationError{message: message}} ->
        raise ArgumentError,
              "invalid configuration given to #{inspect(__MODULE__)}.start_link/1, " <> message
    end
  end
end
