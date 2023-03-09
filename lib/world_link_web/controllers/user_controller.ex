defmodule WorldLinkWeb.UserController do
  use WorldLinkWeb, :controller

  def index(conn, _params) do
    user = %{
      id: "1",
      name: "TunTun",
      email: "test@example.com",
      activated: false,
      provider_uid: "uid",
      oauth_provider: "discord",
      uuid: "uuid",
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }

    render(conn, "show.json", user: user)
  end
end
