defmodule WorldLinkWeb.UserView do
  use WorldLinkWeb, :view

  def render("show.json", %{user: user}) do
    %{data: render_one(user, __MODULE__, "user.json", as: :user)}
  end

  def render("show.json", %{users: users}) do
    %{data: render_many(users, __MODULE__, "user_reduced.json")}
  end

  def render("403", _) do
    render_one(nil, __MODULE__, "403.json", as: :error)
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      nickname: user.nickname,
      email: user.email,
      activated: user.activated,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end

  def render("user_reduced.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      nickname: user.nickname,
      email: user.email,
      activated: user.activated,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end

  def render("403.json", _) do
    %{
      error: "unauthorized"
    }
  end
end
