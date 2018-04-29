defmodule Janken.WWW.Play do
  use Raxx.Server

  @impl Raxx.Server
  def handle_request(request = %{method: :POST}, _) do
    data = URI.decode_query(request.body)

    {:ok, player_binary} = data["player"] |> Base.decode64
    player = player_binary |> :erlang.binary_to_term() |> IO.inspect

    move = data["move"]

    # Janken.send(player, {:result, :win})
    response(:created)
  end
end
