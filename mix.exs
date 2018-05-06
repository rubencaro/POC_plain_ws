defmodule CardoServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :cardo_server,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {CardoServer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:socket, "~> 0.3"},
      {:socket, git: "https://github.com/rubencaro/elixir-socket", branch: "fix_accept"},
    ]
  end
end
