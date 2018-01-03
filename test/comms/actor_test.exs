defmodule Comms.ActorTest do
  use ExUnit.Case

  defmodule Stack do
    use Comms.Actor

    @impl Comms.Actor
    def handle({:"$gen_call", from, :pop}, [head | tail]) do
      {[{from, head}], tail}
    end

    def handle({:"$gen_cast", {:push, number}}, stack) do
      {[], [number | stack]}
    end

    def handle({:broadcast, [pid1, pid2]}, [first, second | rest]) do
      {[{pid1, {:pop, first}}, {pid2, {:pop, second}}], rest}
    end

    def handle({:timeout, delay}, state) do
      {[{:timeout, delay}], state}
    end

    def handle(:timeout, state) do
      {[], {:STOP, :timeout, state}}
    end

    def handle({:"$gen_call", from, {:stop, reason}}, state) do
      {[{from, reason}], {:STOP, reason, state}}
    end
  end

  test "Server knows how to respond to `Gen.call`s" do
    {:ok, stack} = Comms.Actor.start_link(Stack, [3, 2, 1])

    3 = GenServer.call(stack, :pop)
    2 = GenServer.call(stack, :pop)
  end

  test "Server knows how to respond to `Gen.casts`s" do
    {:ok, stack} = Comms.Actor.start_link(Stack, [])

    :ok = GenServer.cast(stack, {:push, 1})
    :ok = GenServer.cast(stack, {:push, 2})
    2 = GenServer.call(stack, :pop)
  end

  test "Server can be stopped for any reason" do
    {:ok, stack} = Comms.Actor.start_link(Stack, [3, 2, 1])
    monitor = Process.monitor(stack)

    assert :normal = GenServer.call(stack, {:stop, :normal})

    assert_receive {:DOWN, ^monitor, :process, ^stack, :normal}
  end

  test "Server can send multiple messages to single action" do
    {:ok, stack} = Comms.Actor.start_link(Stack, [3, 2, 1])

    send(stack, {:broadcast, [self(), self()]})

    assert_receive {:pop, 3}
    assert_receive {:pop, 2}
  end

  test "Understands a timeout reaction" do
    {:ok, stack} = Comms.Actor.start(Stack, [3, 2, 1])
    monitor = Process.monitor(stack)

    send(stack, {:timeout, 10})

    assert_receive {:DOWN, ^monitor, :process, ^stack, :timeout}
  end
end
