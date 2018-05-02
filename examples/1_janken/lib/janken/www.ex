defmodule Janken.WWW do
  use Ace.HTTP.Service, port: 8080, cleartext: true

  alias ServerSentEvent, as: SSE

  alias __MODULE__

  @impl Raxx.Server
  def handle_request(request = %{method: :PUT, path: ["sign-in"]}, state) do
    %{"name" => name} = URI.decode_query(request.body)

    address = Janken.RealPerson.address(name)
    # Probably should be /user/address/events
    redirect("/events/" <> Janken.RealPerson.encode_address(address))
  end

  def handle_request(%{method: :GET, path: ["events", address]}, _) do
    {:ok, address} = Janken.RealPerson.decode_address(address)
    Janken.RealPerson.subscribe(address)

    head =
      response(:ok)
      |> set_header("content-type", SSE.mime_type())
      |> set_body(true)

    {[head], :events}
  end

  def handle_request(request = %{method: :POST, path: ["start-game"]}, state) do
    {:ok, game} = Janken.start_game()
    redirect("/games/" <> Janken.Game.encode_address(game))
  end

  def handle_request(request = %{method: :POST, path: ["personas", address, "invite"]}, state) do
    {:ok, persona} = Janken.RealPerson.decode_address(address)
    %{"game" => game_address} = URI.decode_query(request.body)
    {:ok, game} = Janken.Game.decode_address(game_address)
    {envelopes, :ok} = Janken.RealPerson.send(persona, {:invite, game})
    Comms.Envelope.deliver(envelopes)
    response(:created)
  end

  def handle_request(request = %{method: :PUT, path: ["games", address, "play"]}, state) do
    {:ok, game} = Janken.Game.decode_address(address)
    %{"move" => move, "player" => player_str} = URI.decode_query(request.body)
    {:ok, player} = Janken.RealPerson.decode_address(player_str)
    move = String.to_atom(move)
    {envelopes, :ok} = Janken.Game.send(game, {:move, player, move})
    Comms.Envelope.deliver(envelopes)
    response(:created)
  end

  @impl Raxx.Server
  def handle_info({:invite, game}, :events) do
    game_address = Janken.Game.encode_address(game)
    {[data(SSE.serialize(game_address, type: "invite"))], :events}
  end

  @spec decode_query(binary) :: %{binary => binary}
  defp decode_query(q) do
    URI.decode_query(q)
  end
end

# NOTE for dialyzer
# - no unification of polymorphic types
# - no exhausiveness checking
# - really poor errors particulary in handle callbacks.
