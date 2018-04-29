defmodule Janken.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    {:ok, _} = DynamicSupervisor.start_link(strategy: :one_for_one, name: Janken.DynamicSupervisor)
    {:ok, game_mailbox} = Janken.Game.start()

    children = [
      {Janken.WWW, [%{game: game_mailbox}, []]}
    ]

    opts = [strategy: :one_for_one, name: Janken.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
