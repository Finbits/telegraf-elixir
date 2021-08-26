defmodule Telegraf.FakeUnixSocket do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  @impl Supervisor
  def init(opts) do
    name = Keyword.fetch!(opts, :name)
    socket_path = Keyword.fetch!(opts, :socket_path)
    on_message = Keyword.fetch!(opts, :on_message)
    on_start = Keyword.fetch!(opts, :on_start)

    children = [
      {Task.Supervisor, strategy: :one_for_one, name: task_supervisor(name)},
      {Task, fn -> accept(name, socket_path, on_message, on_start) end}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def accept(name, socket_path, on_message, on_start) do
    {:ok, listen_socket} =
      :gen_tcp.listen(0, [
        :binary,
        packet: :raw,
        active: false,
        reuseaddr: true,
        ifaddr: {:local, socket_path}
      ])

    on_start.()

    loop_acceptor(name, listen_socket, on_message)
  end

  defp loop_acceptor(name, listen_socket, on_message) do
    {:ok, socket} = :gen_tcp.accept(listen_socket)

    {:ok, pid} =
      Task.Supervisor.start_child(task_supervisor(name), __MODULE__, :serve, [
        name,
        socket,
        on_message
      ])

    :ok = :gen_tcp.controlling_process(socket, pid)

    loop_acceptor(name, listen_socket, on_message)
  end

  def serve(name, socket, on_message) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, message} ->
        on_message.(message)

      {:error, :closed} ->
        Task.Supervisor.terminate_child(task_supervisor(name), self())
    end

    serve(name, socket, on_message)
  end

  defp task_supervisor(name), do: Module.concat(name, TaskSupervisor)
end
