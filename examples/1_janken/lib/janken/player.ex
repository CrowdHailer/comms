defmodule Janken.Player do
  use GenServer
  import Kernel, except: [send: 2]
  @opaque address :: {:address, __MODULE__, pid()}

  def start_link([]) do
    case GenServer.start_link(__MODULE__, :nil) do
      {:ok, pid} ->
        {:ok, pid, address(pid)}
    end
  end

  @spec address(pid) :: address
  defp address(pid) do
    {:address, __MODULE__, pid}
  end

  @type invite :: {:invite, Janken.Game.address()}
  @type result :: {:draw | :win | :loose, Janken.Game.address()}
  @type message :: invite | result

  @spec send(address, message) :: {[Comms.Envelope.t], :ok}
  def send(address, message) do
    {[Comms.Envelope.seal(address, message)], :ok}
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
          address = {:address, __MODULE__, _} ->
            {:ok, address}
        end
    end
  end

  # Could call step of tick or iterate
  @spec handle(message, term) :: {[Comms.Envelope.t], term}
  def handle({:invite, game}, state) do
    {envelopes, _} = Janken.Game.send(game, {:move, address(self()), :rock})
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
