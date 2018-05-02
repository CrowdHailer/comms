defmodule JankenTest do
  use ExUnit.Case
  doctest Janken

  alias ServerSentEvent, as: SSE

  test "real people" do
    {:ok, %{headers: headers}} =
      HTTPoison.put(
        "http://localhost:8080/sign-in",
        URI.encode_query(%{"name" => "penny"})
      )

    "/events/" <> penny = Raxx.get_header(%{headers: headers}, "location")

    {:ok, _} = HTTPoison.get("http://localhost:8080/events/" <> penny, [], stream_to: self())

    {:ok, %{headers: headers}} =
      HTTPoison.put(
        "http://localhost:8080/sign-in",
        URI.encode_query(%{"name" => "quentin"})
      )

    "/events/" <> quentin = Raxx.get_header(%{headers: headers}, "location")

    {:ok, _} = HTTPoison.get("http://localhost:8080/events/" <> quentin, [], stream_to: self())

    {:ok, %{headers: headers}} =
      HTTPoison.post(
        "http://localhost:8080/start-game",
        ""
      )

    "/games/" <> game = Raxx.get_header(%{headers: headers}, "location")

    Process.sleep(1_000)

    # {:ok, {_, _, pid}} = Janken.RealPerson.decode_address(penny)
    [pid] = :pg2.get_members("penny")
    # IO.inspect(pid)
    # send(pid, :TADA)

    # From penny
    {:ok, %{headers: headers}} =
      HTTPoison.post(
        "http://localhost:8080/personas/#{penny}/invite",
        URI.encode_query(%{"game" => game})
      )

    assert_receive %{chunk: chunk}, 1_000
    IO.inspect(chunk)

    {:ok, %{headers: headers}} =
      HTTPoison.put(
        "http://localhost:8080/games/#{game}/play",
        URI.encode_query(%{"move" => "rock", "player" => penny})
      )

    assert_receive %{chunk: chunk}, 1_000
    IO.inspect(chunk)
  end

  @tag :skip
  test "better" do
    Janken.run()
    Process.sleep(2_000)
  end
end
