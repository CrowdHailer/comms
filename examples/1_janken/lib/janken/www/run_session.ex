defmodule Janken.WWW.Session do
  # use Raxx.Server
  import Raxx
  alias ServerSentEvent, as: SSE

  @impl Raxx.Server
  def handle_request(%{method: :GET}, state) do
    my_mailbox = {:mailbox, self(), __MODULE__}

    session_id = :erlang.term_to_binary(my_mailbox) |> Base.url_encode64()

    head = response(:ok)
    |> set_header("content-type", SSE.mime_type())
    |> set_body(true)

    data = data(SSE.serialize(session_id, type: "session"))

    {[head, data], state}
  end

  def handle_info({:result, type}, state) do
    # serialize needs to take type string.
    data = data(SSE.serialize("#{type}", type: "message"))
    IO.inspect("sending")
    {[data], state}
  end
end
