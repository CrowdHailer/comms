defmodule JankenTest do
  use ExUnit.Case
  doctest Janken

  alias ServerSentEvent, as: SSE

  # test "a single game" do
  #   Janken.run()
  #   |> IO.inspect
  # end
  #
  #
  # test "sessions" do
  #   {:ok, %{body: game_id}} = HTTPoison.get("http://localhost:8080/")
  #
  #   {:ok, _} = HTTPoison.get("http://localhost:8080/session", [], stream_to: self())
  #   assert_receive %HTTPoison.AsyncStatus{code: 200}, 5_000
  #   assert_receive %HTTPoison.AsyncChunk{chunk: event}, 5_000
  #
  #   {:ok, {%{lines: [session_id]}, ""}} = SSE.parse(event)
  #
  #   body = URI.encode_query(%{
  #     player: session_id,
  #     move: "rock"
  #   })
  #   {:ok, _} = HTTPoison.post("http://localhost:8080/game/#{game_id}/move", body, [])
  #   assert_receive %HTTPoison.AsyncChunk{chunk: event}, 5_000
  #   IO.inspect(event)
  #   {:ok, {%{lines: [session_id]}, ""}} = SSE.parse(event)
  #   |> IO.inspect
  # end

  test "better" do
    Janken.run()
  end
end
