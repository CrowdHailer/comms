defmodule Janken.Persona do
  @opaque t :: {module, term}

  @type invite :: {:invite, Janken.Game.address()}
  @type result :: {:draw | :win | :loose, Janken.Game.address()}
  @type subscribe :: :subscribe
  @type message :: invite | result | subscribe

  @callback do_send(term, message) :: :ok

  @spec address(module, term) :: t
  def address(mod, term) do
    # Can runtime test implementation here
    {mod, term}
  end

  @spec encode(t) :: String.t
  def encode({module, term}) do
    :erlang.term_to_binary({__MODULE__, module, term}) |> Base.url_encode64()
  end

  @spec decode(String.t()) :: {:ok, t}
  def decode(binary) do
    case Base.url_decode64(binary) do
      {:ok, binary} ->
        case :erlang.binary_to_term(binary) do
          {__MODULE__, module, term} ->
            {:ok, {module, term}}
        end
    end
  end

  @spec post(t, message) :: {[Comms.Envelope.t()], :ok}
  def post({mod, t}, message) do
    {[Comms.Envelope.seal({:address, mod, t}, message)], :ok}
  end
end
