defmodule JankenTest do
  use ExUnit.Case
  doctest Janken

  test "a single game" do
    Janken.run()
    |> IO.inspect
  end

end
