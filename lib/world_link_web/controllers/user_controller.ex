defmodule WorldLinkWeb.UserController do
  use WorldLinkWeb, :controller

  def index(conn, _params) do
    user1 = %{
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

    user2 = %{
      id: "2",
      name: "TunTun",
      email: "test@example.com",
      activated: false,
      provider_uid: "uid",
      oauth_provider: "discord",
      uuid: "uuid",
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }

    users = [user1, user2]

    render(conn, "show.json", users: users)
  end
end
