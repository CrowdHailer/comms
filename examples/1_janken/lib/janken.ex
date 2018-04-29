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

  # Could encode safe binary into return type
  @spec encode_address(Janken.Game.address() | Janken.Player.address()) :: String.t()
  def encode_address(address) do
    :erlang.term_to_binary(address) |> Base.url_encode64()
  end
  @spec decode_address(String.t) :: {:ok, :bob | :cat}
  def decode_address(binary) do
    case Base.url_decode64(binary) do
      {:ok, binary} ->
        {:ok, :erlang.binary_to_term(binary)}
    end
  end

  def run() do
    {:ok, game} = Janken.start_game
    {:ok, alice} = Janken.start_player
    {:ok, bob} = Janken.start_player

    Janken.Game.send(game, {:move, bob, :rock})

    r = alice
    |> encode_address
    |> decode_address
    # |> IO.inspect
    |> foo

    # case r do
    #   {:ok, :bob} ->
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


end
