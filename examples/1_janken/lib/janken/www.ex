defmodule Janken.WWW do
  use Ace.HTTP.Service, [port: 8080, cleartext: true]

  alias __MODULE__

  # use Raxx.Router, [
  #   {%{path: []}, WWW.Lobby},
  #   {%{path: ["session"]}, WWW.Session},
  #   {%{path: ["game", _game_id, "move"]}, WWW.Play}
  # ]


end
