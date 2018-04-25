defmodule Janken.WWW.Lobby do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(request = %{method: :GET}, %{game: game}) do
    game_id = :erlang.term_to_binary(game) |> Base.url_encode64()

    response(:ok)
    |> set_body(game_id)
  end
end
