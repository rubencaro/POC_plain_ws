defmodule CardoServer.Acceptor do
  use GenServer

  defmodule D do
    defstruct [:opts, :server]
  end

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  def init(opts) do
    case Socket.Web.listen(4040) do
      {:ok, server} ->
        schedule_loop()
        res = %D{opts: opts, server: server}
        {:ok, res}

      {:error, error} ->
        {:stop, error}
    end
  end

  def handle_info(:loop, %D{server: s} = state) do
    case Socket.Web.accept(s) do
      {:ok, client} ->
        add_connection(client)
        schedule_loop()

      {:error, error} ->
        IO.inspect(error, label: "Could not accept client")
    end

    {:noreply, state}
  end

  defp schedule_loop, do: Process.send(self(), :loop, [])

  defp add_connection(client) do
    res =
      Supervisor.start_child(
        CardoServer.Supervisor,
        {CardoServer.Connection, client}
      )

    case res do
      {:error, error} -> IO.inspect(error, label: "Could not start connection process")
      _ -> :ok
    end
  end
end
