# Janken

**Japanese for rock paper scissors**

Can start a game knowing player mailboxes
Can start a game and send player mailboxes
Can name a game and discover from the lobby

Could use mailbox as capability objects pass one to p1 and one to p2

```elixir
defmodule Persona do
  use Comms.Address # mailbox

  @type invite :: {:invite, Janken.Game.address()}
  @type result :: {:draw | :win | :loose, Janken.Game.address()}
  @message invite | result
end

# Equivalent to

defmodule Persona. do

end
defmodule Persona do
  @opaque t :: User.t | ComputerPlayer.t
  @opaque t :: {module, term}

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

  def post(address, message) do
    {[Comms.Envelope.seal(address, message)], :ok}
  end

  def do_send({module, term}, message) do
    module.do_send(term, message)
  end
end

defmodule ComputerPlayer do
  @spec start_link([]) :: {:ok, pid, ComputerPlayer.t}
  def start_link([]) do
    case GenServer.start_link(__MODULE__, nil) do
      {:ok, pid} ->
        {:ok, pid, Persona.address(ComputerPlayer, pid)}
    end
  end


  @spec do_send(term, Persona.message) :: type
  def do_send(term, message) do

  end
end

defmodule PostalPlayer do
  @spec do_send(term, Persona.message) :: type
  def do_send(term, message) do

  end
end
```
