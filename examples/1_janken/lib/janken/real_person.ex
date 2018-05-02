defmodule Janken.RealPerson do
  @opaque address :: {:address, __MODULE__, String.t()}
  import Kernel, except: [send: 2]

  # This is really sign up
  @spec address(String.t()) :: address
  def address(name) do
    {:address, __MODULE__, name}
  end

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

  @spec subscribe(address) :: :ok
  def subscribe({:address, __MODULE__, name}) do
    :ok = :pg2.create(name)
    :ok = :pg2.join(name, self())
  end

  @type invite :: {:invite, Janken.Game.address()}
  @type result :: {:draw | :win | :loose, Janken.Game.address()}
  @type message :: invite | result

  @spec send(address, message) :: {[Comms.Envelope.t()], :ok}
  def send(address, message) do
    {[Comms.Envelope.seal(address, message)], :ok}
  end

  def do_send(group, message) do
    :ok = :pg2.create(group)

    for client <- :pg2.get_members(group) do
      Kernel.send(client, message)
    end

    :ok
  end
end
