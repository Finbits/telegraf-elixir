defmodule Telegraf.Transport.UnixSocket do
  @children_opts_definition [
    socket_path: [
      type: :string,
      doc: "Path to the unix socket.",
      default: "/tmp/telegraf.sock"
    ],
    pool_size: [
      type: :pos_integer,
      doc: "The size of the pool tcp sockets. Defaults to `System.schedulers_online()`."
    ]
  ]

  @moduledoc """
  Send events to telegraf via a Unix Domain Socket.
  It uses `NimblePool` to create a pool of open tcp sockets connected
  to the `socket_path`.

  It expects the telegraf daemon to have the [Socket Listener Input Plugin](https://github.com/influxdata/telegraf/blob/release-1.18/plugins/inputs/socket_listener/README.md)
  configured to listen for messages.

  ```
  # telegraf.conf

  [[inputs.socket_listener]]
    service_address = "/tmp/telegraf.sock"
  ```

  ## Usage

  Add to your supervision tree:

      {Telegraf, name: MyTelegraf, transport: #{inspect(__MODULE__)}}

  With custom options:

      {Telegraf,
       name: MyTelegraf,
       transport: #{inspect(__MODULE__)},
       transport_options: [socket_path: "/tmp/cool.sock"]}

  ## Supported options

  #{NimbleOptions.docs(@children_opts_definition)}
  """
  @behaviour NimblePool
  @behaviour Telegraf.Transport

  @impl Telegraf.Transport
  def children(name, opts) do
    opts = validate_children_options!(opts)
    socket_path = Keyword.fetch!(opts, :socket_path)
    pool_size = Keyword.fetch!(opts, :pool_size)

    [
      {NimblePool,
       worker: {__MODULE__, %{socket_path: socket_path}},
       pool_size: pool_size,
       lazy: true,
       name: pool_name(name)}
    ]
  end

  @impl Telegraf.Transport
  def send(name, message, opts \\ []) do
    pool_timeout = Keyword.get(opts, :pool_timeout, 5000)

    NimblePool.checkout!(
      pool_name(name),
      :checkout,
      fn _from, socket ->
        return = :gen_tcp.send(socket, message)

        {return, socket}
      end,
      pool_timeout
    )
  end

  @impl NimblePool
  def init_worker(%{socket_path: socket_path} = pool_state) do
    parent = self()

    async = fn ->
      {:ok, socket} =
        :gen_tcp.connect({:local, socket_path}, 0, [
          :binary,
          active: false,
          packet: :raw
        ])

      :ok = :gen_tcp.controlling_process(socket, parent)
      socket
    end

    {:async, async, pool_state}
  end

  @impl NimblePool
  def handle_checkout(:checkout, _from, socket, pool_state) do
    {:ok, socket, socket, pool_state}
  end

  @impl NimblePool
  def terminate_worker(_reason, socket, pool_state) do
    :gen_tcp.close(socket)
    {:ok, pool_state}
  end

  # credo:disable-for-next-line Credo.Check.Warning.UnsafeToAtom
  defp pool_name(name), do: Module.concat(name, Pool)

  defp validate_children_options!(opts) do
    opts = Keyword.put_new(opts, :pool_size, System.schedulers_online())

    case NimbleOptions.validate(opts, @children_opts_definition) do
      {:ok, opts} ->
        opts

      {:error, %NimbleOptions.ValidationError{message: message}} ->
        raise ArgumentError,
              "invalid configuration given to #{inspect(__MODULE__)}.children/2, " <> message
    end
  end
end
