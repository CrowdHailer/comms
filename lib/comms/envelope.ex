defmodule Comms.Envelope do
  @type address :: {:address, module, term}
  @type message :: term
  @opaque t :: {address, term}

  @spec seal(address, message) :: t
  def seal(address, message) do
    {address, message}
  end

  @spec deliver(list(t)) :: :ok
  def deliver([]) do
    :ok
  end
  def deliver([{address, message}| rest]) do
    :ok = do_deliver(address, message)
    deliver(rest)
  end

  defp do_deliver({:address, module, address}, message) do
    module.do_send(address, message)
  end
end
