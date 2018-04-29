defmodule Janken.Player do
  use GenServer
  import Kernel, except: [send: 2]
  @opaque address :: {:via, __MODULE__, pid()}

  def start_link([]) do
    case GenServer.start_link(__MODULE__, :nil) do
      {:ok, pid} ->
        {:ok, pid, address(pid)}
    end
  end

  @spec address(pid) :: address
  defp address(pid) do
    {:via, __MODULE__, pid}
  end

  @type message :: {:invite, Janken.Game.address()}

  @spec send(address, message) :: term
  def send(address, message) do
    {[{address, message}], :ok}
  end

  @spec encode_address(address) :: String.t()
  def encode_address(address) do
    :erlang.term_to_binary(address) |> Base.url_encode64()
  end
  @spec decode_address(String.t) :: {:ok, address}
  def decode_address(binary) do
    case Base.url_decode64(binary) do
      {:ok, binary} ->
        case :erlang.binary_to_term(binary) do
          address = {:via, __MODULE__, _} ->
            {:ok, address}
        end
    end
  end

  @spec handle(message, term) :: term
  def handle({:invite, game}, state) do
    Janken.Game.send(game, {:move, address(self()), :rock})
    IO.inspect("RECEIVED PLAYER")
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
end
