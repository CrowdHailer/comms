defmodule Janken.Player do
  use GenServer
  @type address :: {:via, __MODULE__, pid()}

  @spec start_link([]) :: {:ok, pid, address}
  def start_link([]) do
    case GenServer.start_link(__MODULE__, :nil) do
      {:ok, pid} ->
        {:ok, pid, {:via, __MODULE__, pid}}
    end
  end
end
