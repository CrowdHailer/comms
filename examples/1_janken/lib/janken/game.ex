defmodule Janken.Game do
  use GenServer
  @opaque address :: {:via, __MODULE__, pid()}

  @spec start_link([]) :: {:ok, pid(), address}
  def start_link([]) do
    case GenServer.start_link(__MODULE__, :nil) do
      {:ok, pid} ->
        {:ok, pid, {:via, __MODULE__, pid}}
    end
  end

  @typep move :: {:move, Janken.Player.address(), :rock | :paper | :scissors}
  @type message :: move

  @spec send(address, message) :: term
  def send(address, message) do
    {[{address, message}], :ok}
  end

  # Could encode safe binary into return type
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

  def handle_info(x, s) do
    IO.inspect("RECEIVED GAME")
    IO.inspect(x)
  end
end
