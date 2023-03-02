defmodule WorldLinkWeb.AuthController do
  use WorldLinkWeb, :controller
  plug Ueberauth

  def callback(conn, params) do
    IO.puts("### Conn")
    conn
    |> dbg()

    IO.puts("### Params")
    params
    |> IO.inspect()

    conn
  end
end
