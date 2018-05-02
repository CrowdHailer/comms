defmodule Janken.Game do
  use GenServer
  import Kernel, except: [send: 2]
  @opaque address :: {:address, __MODULE__, pid()}

  @spec start_link([]) :: {:ok, pid(), address}
  def start_link([]) do
    case GenServer.start_link(__MODULE__, nil) do
      {:ok, pid} ->
        {:ok, pid, address(pid)}
    end
  end

  defp address(pid) do
    {:address, __MODULE__, pid}
  end

  @typep move :: {:move, Janken.Persona.t(), :rock | :paper | :scissors}
  @type message :: move

  @spec send(address, message) :: {[Comms.Envelope.t()], :ok}
  def send(address, message) do
    {[Comms.Envelope.seal(address, message)], :ok}
  end

  # Could encode safe binary into return type
  @spec encode_address(address) :: String.t()
  def encode_address(address) do
    :erlang.term_to_binary(address) |> Base.url_encode64()
  end

  @spec decode_address(String.t()) :: {:ok, address}
  def decode_address(binary) do
    case Base.url_decode64(binary) do
      {:ok, binary} ->
        case :erlang.binary_to_term(binary) do
          address = {:address, __MODULE__, _} ->
            {:ok, address}
        end
    end
  end

  @spec handle(message, term) :: {[Comms.Envelope.t()], term}
  def handle({:move, player, action}, state) do
    case action do
      _ ->
        Janken.Persona.post(player, {:draw, address(self())})
    end
  end

  def handle_info(message, state) do
    {envelopes, state} = handle(message, state)
    :ok = Comms.Envelope.deliver(envelopes)
    {:noreply, state}
  end

  def do_send(pid, message) do
    ^message = Kernel.send(pid, message)
    :ok
  end
end
