defmodule Janken do
  import Kernel, except: [send: 2]

  def run() do
    {:ok, game_mailbox} = Janken.Game.start
    player_mailbox = {:mailbox, self(), Player}
    send(game_mailbox, {:move, player_mailbox, :rock})

    # Dialyzer will now spot that this is an invalid message to a game_mailbox
    # Can fix by having the user match mailbox to send function
    # defining the spec allows dialyzer to work
    # send(game_mailbox, {:result, :win})

    # Dialyzer will now spot that this is an invalid message to send
    # send(game_mailbox, {:move, player_mailbox, :lizard})
  end

  @type action :: :rock | :paper | :scissors

  defmodule Game do
    @type mailbox :: {:mailbox, pid(), __MODULE__}

    @spec start() :: {:ok, mailbox}
    def start() do
      game_ref = make_ref()
      child_spec = %{
        id: game_ref,
        start: {:proc_lib, :start_link, [Janken.Game, :init, [game_ref]]},
        restart: :temporary
      }
      {:ok, _pid, mailbox} = DynamicSupervisor.start_child(Janken.DynamicSupervisor, child_spec)
      {:ok, mailbox}
    end

    def init(game_ref) do
      [parent | _] = Process.get(:"$ancestors")

      mailbox = {:mailbox, self(), Game}

      :proc_lib.init_ack(parent, {:ok, self(), mailbox});
      loop(mailbox, :state)
    end

    def loop(mailbox, state) do
      # The must be some way to write a receive on mailbox macro that checks if pid is self and can be used to check all message types handled
      receive do
        {:move, reply_mailbox, action} ->
          IO.inspect("received #{inspect(action)}")
          # Janken.send(player_mailbox, :waiting)
      end
    end
  end

  @spec send({:mailbox, pid(), Game}, {:move, {:mailbox, pid, Player}, action}) :: :ok
  @spec send({:mailbox, pid, Player}, {:result, :win | :loose}) :: :ok
  def send({:mailbox, pid, Game}, message = {:move, {:mailbox, _pid, Player}, action}) when action in [:rock, :paper, :scissors] do
    Kernel.send(pid, message)
    :ok
  end
  def send({:mailbox, pid, Player}, message = {:result, result}) when result in [:win, :loose] do
    Kernel.send(pid, message)
    :ok
  end

end
