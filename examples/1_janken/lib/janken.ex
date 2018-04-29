defmodule Janken do
  import Kernel, except: [send: 2]

  @spec start_game() :: {:ok, Janken.Game.address()}
  def start_game(supervisor \\ Janken.DynamicSupervisor) do
    {:ok, _pid, address} = DynamicSupervisor.start_child(supervisor, Janken.Game)
    {:ok, address}
  end

  @spec start_player() :: {:ok, Janken.Player.address()}
  def start_player(supervisor \\ Janken.DynamicSupervisor) do
    {:ok, _pid, address} = DynamicSupervisor.start_child(supervisor, Janken.Player)
    {:ok, address}
  end

  def run() do
    {:ok, game} = Janken.start_game
    {:ok, alice} = Janken.start_player
    {:ok, bob} = Janken.start_player

    Janken.Game.send(game, {:move, bob, :rock})

    r = alice
    |> Janken.Player.encode_address
    |> Janken.Player.decode_address
    # attatch decode address to module
    # |> IO.inspect
    # |> foo

    # send(game, 5)
    # Comms.Envelope.seal(:bob, :do)
    # case r do
    #   {:ok, game} ->
    #     Janken.Game.send(game, {:move, bob, :rock})
    #     :ok
    # end
    # Janken.Game.send(alice, {:move, bob, :rock})

    # Dialyzer will now spot that this is an invalid message to a game_mailbox
    # Can fix by having the user match mailbox to send function
    # defining the spec allows dialyzer to work
    # send(game_mailbox, {:result, :win})

    # Dialyzer will now spot that this is an invalid message to send
    # send(game_mailbox, {:move, player_mailbox, :lizard})
  end

  # @spec foo({:ok, :bob | :cat}) :: true
  def foo({:ok, :bob}) do
    true
  end

  # Dont use via tuple as it makes no sense in Gen call and cast because some cases are not pids
  # @spec send(address(T), T) :: {[term], :ok}
  # def send(address, message) do
  #   {[{address, message}], :ok}
  # end

end
