defmodule Comms.Actor do
  @moduledoc """
  A behaviour module for implementing general purpose actors.

  A `Comms.Actor` is designed to allow easy implementation of the actor model.

  ## Example

      defmodule Ping do
        use Comms.Actor

        @impl Comms.Actor
        def handle({:ping, pid}, state) do
          {[{pid, :pong}], state}
        end
      end

      {:ok, p} = Comms.Actor.start_link(Ping, nil)

      send(p, {:ping, self()})

      flush()
      # => :pong

  ## Actor Model

  > An actor is a computational entity that, in response to a message it receives, can concurrently:
  >
  > 1. send a finite number of messages to other actors;
  > 2. create a finite number of new actors;
  > 3. designate the behavior to be used for the next message it receives.
  >
  > There is no assumed sequence to the above actions and they could be carried out in parallel.

  The `Comms.Actor` behavior is a replacement for `GenServer` that more closely follows these principles.

  - There is only one callback to deal with incomming messages, `handle/2`.
    `Comms.Actor` works with `GenServer.call/2` etc but these are just another type of message
  - The return value of the `handle/2` callback is always the same shape.
    A list of outbound messages and a new state.
    This allows an `Comms.Agent` to send any number of replies rather than 1 or 0 that is the case for GenServers.

  ## Gen messages

  Calls and cast from the `GenServer` module etc are just wrappers around the erlang `:gen` module.
  A proccess implementing `Comms.Actor` can respond to these like normal messages.

      defmodule PairUp do
        use Comms.Actor

        def start_link do
          Comms.Actor.start_link(__MODULE__, :none)
        end

        @impl Comms.Actor
        def handle({:"$gen_call", from, {:pair, pid}}, :none) do
          {[], {:waiting, from, pid}}
        end
        def handle({:"$gen_call", from2, {:pair, pid2}}, {:waiting, from1, pid1}) do
          messages = [
            {from2, {:other, pid1}},
            {from1, {:other, pid2}},
          ]
          {messages, :none}
        end
      end

  """

  @typedoc """
  Location where an actor can direct messages too.
  """
  @type address :: pid | {pid, reference} | :timeout

  @typedoc """
  The payload of a sent or received message
  """
  @type message :: term

  @typedoc """
  Any value that an actor maintains between receiving messages
  """
  @type state :: term

  @typedoc """
  Response to a 
  """
  @type reaction :: {[{address, message}], state}

  @callback handle(message, state) :: reaction

  defmacro __using__(_opts) do
    quote location: :keep do
      use GenServer
      @behaviour unquote(__MODULE__)

      @impl GenServer
      def handle_call(message, from, state) do
        handle({:"$gen_call", from, message}, state)
        |> react_to_action()
      end

      @impl GenServer
      def handle_cast(message, state) do
        handle({:"$gen_cast", message}, state)
        |> react_to_action()
      end

      @impl GenServer
      def handle_info(message, state) do
        handle(message, state)
        |> react_to_action()
      end

      defp react_to_action({outbound, new_state}) do
        {timeout, outbound} = Keyword.pop(outbound, :timeout, :infinity)

        outbound
        |> Enum.each(fn {t, m} -> deliver(t, m) end)

        case new_state do
          {:STOP, reason, state} ->
            {:stop, reason, state}

          _ ->
            {:noreply, new_state, timeout}
        end
      end

      defp deliver(target, message) when is_pid(target) do
        send(target, message)
      end

      defp deliver(from = {p, r}, message) when is_pid(p) and is_reference(r) do
        GenServer.reply(from, message)
      end
    end
  end

  @doc """
  Starts a `Comms.Actor` process without links (outside of a supervision tree).

  See start_link/3 for more information.
  """
  @spec start(module(), any(), GenServer.options()) :: GenServer.on_start()
  def start(module, args, options \\ []) do
    GenServer.start(module, args, options)
  end

  @doc """
  Starts a `Comms.Actor` process linked to the current process.

  The arguments for this are identical to `GenServer.start_link/3` and should be used for reference docs.
  """
  @spec start_link(module(), any(), GenServer.options()) :: GenServer.on_start()
  def start_link(module, args, options \\ []) do
    GenServer.start_link(module, args, options)
  end
end
