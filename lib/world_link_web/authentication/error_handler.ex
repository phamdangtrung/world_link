defmodule  WorldLinkWeb.Authentication.ErrorHandler do
  import Plug.Conn

  def auth_error(conn, {:unauthenticated = type, _reason}, _opts) do
    body = Jason.encode!(%{error: to_string(type)})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
  end

  def auth_error(conn, {:unauthorized = type, _reason}, _opts) do
    body = Jason.encode!(%{error: to_string(type)})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(403, body)
  end
end
