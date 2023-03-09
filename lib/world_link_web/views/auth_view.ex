defmodule WorldLinkWeb.AuthView do
  use WorldLinkWeb, :view

  def render("show.json", %{user: user}) do
    %{data: render_one(user, __MODULE__, "user.json", as: :user)}
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
end
