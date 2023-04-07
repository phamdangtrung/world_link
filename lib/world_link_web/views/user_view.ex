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
      username: user.normalized_username,
      email: user.normalized_email,
      activated: user.activated,
      activated_at: user.activated_at,
      role_name: user.role_name
    }
  end

  def render("user_reduced.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      username: user.normalized_username,
      email: user.normalized_email,
      activated: user.activated,
      activated_at: user.activated_at,
      role_name: user.role_name
    }
  end
end
