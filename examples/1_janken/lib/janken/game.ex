defmodule Janken.Game do
  use GenServer
  @type address :: {:via, __MODULE__, pid()}

  @spec start_link([]) :: {:ok, pid(), address}
  def start_link([]) do
    case GenServer.start_link(__MODULE__, :nil) do
      {:ok, pid} ->
        {:ok, pid, {:via, __MODULE__, pid}}
    end
  end

  @type move :: {:move, Janken.Player.address(), :rock | :paper | :scissors}
  @type message :: move

  @spec send(address, message) :: term
  def send(address, message) do
    {[{address, message}], :ok}
  end
end
