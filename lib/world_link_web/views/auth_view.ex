defmodule WorldLinkWeb.AuthView do
  use WorldLinkWeb, :view

  def render("show.json", %{user: user}) do
    %{data: render_one(user, __MODULE__, "user.json", as: :user)}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      username: user.username,
      email: user.email,
      activated: user.activated,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end
end
