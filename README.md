# Comms

**Explicit message passing for improved reasoning about actor systems.**

## Goals

The ultimate goal is a program that has deep insight into the message patterns in a program.
This insight should be sufficient to warn of race conditions or deadlocks.
By using Elixirscript these insights should extend to client server interactions.

*Elixir and erlang are very powerful languages.
The realistic approach to this goal is to define some constraints to the program.
Where these constraints are applied the promised insight is available.*

### Is this even possible?

In short I believe so.
Also that it is possible to do it in a way useful to programmers.

1. The actor model is a complete model of computation.
2. Consistency as Logical Monotonicity (CALM) applies to the set of all messages sent,
   *A message can never be unsent.*

##### [Actor model of computation: Scalable Robust Information Systems](https://arxiv.org/ftp/arxiv/papers/1008/1008.1459.pdf)

This paper discusses the Actor model at a theoretical level.
Also discussed several actor implementations, including erlangs.

##### ["I See What You Mean" by Peter Alvaro](https://www.youtube.com/watch?v=R2Aa4PivG0g)

A great talk about many things, including logical time and the CALM Theorem.

##### [The Actor Model (everything you wanted to know, but were afraid to ask)](https://channel9.msdn.com/Shows/Going+Deep/Hewitt-Meijer-and-Szyperski-The-Actor-Model-everything-you-wanted-to-know-but-were-afraid-to-ask)

What are actors, exactly? No, really. What are they? When is an actor an actor? Everything you wanted to know about actors, but we're afraid to ask... It's all right here. Big thanks to Carl, Clemens and Erik.

## Steps

### 1. `Comms.Actor` (Done)

**Explicit message passing and state changes.**

Behaviours such as `GenServer` are like actors but not quite.
In a `GenServer` replies to calls can explicit by using the `{:send, message, new_state}`.
However using `GenServer.reply/2`; or `receive/1` instead of a callback means that some message handling would be hidden from a type specification of the callback.

`Comms.Actor` fixes these limitation by providing a callback that allows multiple messages to be sent.

The return value from `Comms.Actor.handle/2` is always the same two parts.
1. A list of two tuples consisting of the destination of a message and content of a message.
2. The new state of the actor.

### 2. `Comms.Address` (In progress)

**Extensible address types for actors.**

By default the `Comms.Actor` understands three types of addresses

1. `pid()` for simple message passing
2. `GenServer.from()` for replying to a GenServer call.
3. `:timeout` send a message to receive a timeout message in a given time.

The actor model is not limited to erlang processes.

> Electronic mail (e-mail) can be modeled as an Actor system. Accounts are modeled as Actors and email addresses as Actor addresses.
[wikipedia](https://en.wikipedia.org/wiki/Actor_model#Applications)

It should be possible to extend the range of addresses that can be used, for example an email address.

```elixir
def handle({:sign_up, username, email_address}, users) do
  new_users = Map.put(users, username, %{email_address: email_address})
  welcome = "Hello there. :-)"
  {[email_address, welcome], new_users}
end
```

### 3. `Comms.Monad` (In progress)

**Composing message sending**

When using `Comms.Actor` the developer is relied upon to not break the contract by using send or receive within a handle call.
It can also become tedious to keep passing a growing list of messages to send.

This can all be fixed using a reader monad.

### 4. ... (The future)

- Immortal actors
- Property tested mailboxes

## Get involved

Right now the most helpful thing would be to experiment with `Comms.Actor` in place of `GenServer` and other behaviours.
The theory tells us that everything should be possible with actors.
However, it is valuable to find out what is easier (or harder).
This will give a handle on the cost of changing developers behaviour to only send messages and change state as part of explicit contracts.
