defmodule Janken.MixProject do
  use Mix.Project

  def project do
    [
      app: :janken,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Janken.Application, []}
    ]
  end

  defp deps do
    [
      {:ace, "~> 0.16.3"},
      {:server_sent_event, "~> 0.3.1"},
      {:httpoison, "~> 1.1"},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end
end
