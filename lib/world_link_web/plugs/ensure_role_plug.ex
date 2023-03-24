defmodule WorldLinkWeb.Plugs.EnsureRolePlug do
  @moduledoc """
  This plug ensures that a user has a particular role.
  """
  import Plug.Conn

  def init(roles), do: roles

  def call(conn, roles) do
    conn
    |> Guardian.Plug.current_resource() |> IO.inspect()

    conn
    |> Guardian.Plug.current_resource() |> has_role?(conn)|> IO.inspect()

    conn
    |> Guardian.Plug.current_resource()
    |> has_role?(roles)
    |> maybe_halt(conn)
  end

  defp maybe_halt(true, conn), do: conn

  defp maybe_halt(_, conn) do
    body = Jason.encode!(%{error: to_string(:unauthorized)})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(403, body)
  end

  def has_role?(nil, _roles), do: false
  def has_role?(user, roles) when is_list(roles) do
    Enum.any?(roles, &has_role?(user, &1))
  end
  def has_role?(%{role_name: role}, role), do: true
  def has_role?(_user, _role), do: false
end
