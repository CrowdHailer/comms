defmodule Janken.Game do
  use GenServer

  def whereis_name({id, supervisor})  do
    child_spec = %{
      id: id,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :temporary,
      shutdown: 500
    }
    case Supervisor.start_child(supervisor, child_spec) do
      {:ok, pid} ->
        pid
      {:error, {:already_started, pid}} ->
        pid
      _ ->
        :undefined
    end
  end

  def start_link() do
    GenServer.start_link(__MODULE__, :nil)
  end


  def handle(%{player: player, move: move}, {nil, nil}) do
    state = {{player, :move}, nil}
    {[], state}
  end
  def handle(%{player: p2, move: m2}, {{p1, m1}, nil}) when p1 != p2 do
    state = {{player, :move}, nil}
    e1 = Player.send(p2, :win)
    e2 = Player.send(p1, :loose)
    {[e1, e2], state}
  end


end
