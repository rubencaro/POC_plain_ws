defmodule CardoServer.Connection do
  use GenServer, restart: :transient

  defmodule D do
    defstruct [:opts, :client]
  end

  def start_link(client), do: GenServer.start_link(__MODULE__, client)

  def init(client) do
    case verify_client(client) do
      {:ok, _} ->
        schedule_loop()
        {:ok, %D{client: client}}

      {:error, error} ->
        {:stop, error}
    end
  end

  defp verify_client(client), do: Socket.Web.accept(client)

  def handle_info(:loop, %D{client: c} = state) do
    case Socket.Web.recv(c, timeout: 5000) do
      {:ok, packet} ->
        IO.inspect(packet, label: "Received")

      {:error, :timeout} ->
        IO.puts(".")

      {:error, error} ->
        IO.inspect(error, label: "Could not read packet")
    end

    schedule_loop()

    {:noreply, state}
  end

  defp schedule_loop, do: Process.send(self(), :loop, [])
end
