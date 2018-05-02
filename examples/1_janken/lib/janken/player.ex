defmodule Janken.Player do
  use GenServer
  import Kernel, except: [send: 2]

  def start_link([]) do
    case GenServer.start_link(__MODULE__, nil) do
      {:ok, pid} ->
        {:ok, pid, Janken.Persona.address(__MODULE__, pid)}
    end
  end

  # Could call step of tick or iterate
  @spec handle(Janken.Persona.message, term) :: {[Comms.Envelope.t()], term}
  def handle({:invite, game}, state) do
    address = Janken.Persona.address(__MODULE__, self())
    {envelopes, _} = Janken.Game.send(game, {:move, address, :rock})
    IO.inspect("RECEIVED Invite")
    {envelopes, state}
  end

  def handle({:draw, game}, state) do
    case game do
      _ ->
        game + 5
    end

    {[], state}
  end

  def handle(:foo, state) do
    {[], state}
  end

  # @spec handle_info({:invite, Janken.Game.address(), address}, term) :: {:noreply, term}
  def handle_info(message, state) do
    {list, state} = handle(message, state)
    {:noreply, state}
  end

  def do_send(pid, message) do
    ^message = Kernel.send(pid, message)
    :ok
  end
end
