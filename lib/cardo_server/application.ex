defmodule CardoServer.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      CardoServer.Acceptor
    ]

    opts = [strategy: :one_for_one, name: CardoServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
