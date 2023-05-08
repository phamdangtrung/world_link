defmodule WorldLinkWeb.AuthController do
  use WorldLinkWeb, :controller

  alias WorldLink.Identity
  alias WorldLinkWeb.Authentication.Guardian
  plug(Ueberauth)
  plug(WorldLinkWeb.Authentication.UnauthPipeline when action in [:login])

  action_fallback(WorldLinkWeb.FallbackController)

  def login(conn, %{"email_or_username" => email_or_username, "password" => password}) do
    with {:ok, user} <- Identity.get_user_by_email_or_username(email_or_username),
         {:ok, verified_user} <- Identity.verify_user_and_password(user, password) do
      {:ok, tokens} = Guardian.create_token(verified_user)

      render(conn, "user_token.json", tokens)
    end
  end

  def callback(conn, _params) do
    assigns = conn.assigns.ueberauth_auth
    user_params = build_params_based_on_provider(assigns.provider, assigns)

    case Identity.verify_user_existence(user_params) do
      {:ok} ->
        {:ok, user} = Identity.create_oauth_user(user_params)
        render(conn, :user, user: user)

      {:error, :user_already_exists, _user} ->
        conn
        |> put_status(:bad_request)
        |> put_resp_header("location", ~p"/auth/#{assigns.provider}/")
        |> render("400.json", conn.assigns)
    end
  end

  defp build_params_based_on_provider(:discord, params) do
    %{
      provider_uid: params.uid,
      oauth_provider: :discord,
      name: params.info.name || params.info.nickname,
      username: params.info.nickname || params.info.name,
      email: params.info.email,
      avatar: params.info.image
    }
  end

  defp build_params_based_on_provider(:facebook, params) do
    %{
      provider_uid: params.uid,
      oauth_provider: :facebook,
      name: params.info.name || params.info.nickname,
      username: params.info.nickname || params.info.name,
      email: params.info.email,
      avatar: params.info.image
    }
  end
end
