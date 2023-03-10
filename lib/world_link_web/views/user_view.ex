defmodule WorldLinkWeb.UserView do
  use WorldLinkWeb, :view

  def render("show.json", %{user: user}) do
    %{data: render_one(user, __MODULE__, "user.json", as: :user)}
  end

  def render("show.json", %{users: users}) do
    %{data: render_many(users, __MODULE__, "user_reduced.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      activated: user.activated,
      provider_uid: user.provider_uid,
      uuid: user.uuid,
      oauth_provider: user.oauth_provider,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end

  def render("user_reduced.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      activated: user.activated,
      provider_uid: user.provider_uid,
      uuid: user.uuid,
      oauth_provider: user.oauth_provider
    }
  end
end
