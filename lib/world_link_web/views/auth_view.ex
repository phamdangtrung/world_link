defmodule WorldLinkWeb.AuthView do
  use WorldLinkWeb, :view

  def render("token.json", %{tokens: jwt_tokens}) do
    %{
      access: jwt_tokens.access,
      refresh: jwt_tokens.refresh
    }
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

  def render("user_token.json", %{tokens: jwt_tokens}) do
    %{data: render_one(jwt_tokens, __MODULE__, "token.json", as: :tokens)}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, __MODULE__, "user.json", as: :user)}
  end
end
