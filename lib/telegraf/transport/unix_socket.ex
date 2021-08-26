defmodule Telegraf.Transport.UnixSocket do
  @behaviour NimblePool
  @behaviour Telegraf.Transport

  @impl Telegraf.Transport
  def children(opts) do
    name = Keyword.fetch!(opts, :name)
    socket_path = Keyword.get(opts, :socket_path, "/tmp/telegraf.sock")
    pool_size = Keyword.get(opts, :pool_size, System.schedulers_online())

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
end
