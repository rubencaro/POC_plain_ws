defmodule CardoServer.Connection do
  use GenServer, restart: :transient

  defmodule D do
    defstruct [:opts, :client]
  end

  # Initialization

  def start_link(client), do: GenServer.start_link(__MODULE__, client)

  def init(client) do
    case verify_client(client) do
      {:ok, _} ->
        schedule_recv_loop()
        schedule_ping_loop()
        {:ok, %D{client: client}}

      {:error, error} ->
        {:stop, error}
    end
  end

  defp verify_client(client), do: Socket.Web.accept(client)

  # Client API

  def send(pid, package, timeout \\ 5000), do: GenServer.call(pid, {:send, package}, timeout)
  def close(pid, timeout \\ 5000), do: GenServer.call(pid, :close, timeout)

  # Server callbacks

  def handle_info(:recv_loop, %D{client: c} = state) do
    k = c.key
    case Socket.Web.recv(c, timeout: 5_000) do
      {:ok, {:ping, cookie}} -> pong(state, cookie)
      {:ok, {:pong, ^k}} -> :ok
      {:ok, packet} -> IO.inspect(packet, label: "Received")
      {:error, :timeout} -> :ok
      {:error, error} -> IO.inspect(error, label: "Could not read packet")
    end

    schedule_recv_loop()

    {:noreply, state}
  end

  def handle_info(:ping_loop, %D{client: c} = state) do
    case Socket.Web.ping(c, c.key) do
      {:error, error} -> IO.inspect(error, label: "Could not read ping")
      _ -> IO.puts("Ping " <> c.key)
    end

    schedule_ping_loop()

    {:noreply, state}
  end

  defp schedule_recv_loop, do: Process.send(self(), :recv_loop, [])
  defp schedule_ping_loop, do: Process.send_after(self(), :ping_loop, 20_000)

  def handle_call({:send, packet}, %D{client: c} = state) do
    {:reply, Socket.Web.send(c, packet), state}
  end

  def handle_call(:close, %D{client: c} = state) do
    {:reply, Socket.Web.close(c), state}
  end

  defp pong(%D{client: c}, cookie) do
    case Socket.Web.pong(c, cookie) do
      {:error, error} -> IO.inspect(error, label: "Could not send pong")
      _ -> IO.puts("Pong")
    end
  end
end
