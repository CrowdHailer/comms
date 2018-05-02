defmodule Janken.RealPerson do
  import Kernel, except: [send: 2]

  # This is really sign up
  @spec address(String.t()) :: Janken.Persona.t
  def address(name) do
    Janken.Persona.address(__MODULE__, name)
  end

  @behaviour Janken.Persona

  def do_send(name, :subscribe) do
    :ok = :pg2.create(name)
    :ok = :pg2.join(name, self())
    :ok
  end
  def do_send(group, message) do
    IO.inspect(group)
    :ok = :pg2.create(group)

    for client <- :pg2.get_members(group) do
      Kernel.send(client, message)
    end

    :ok
  end
end
