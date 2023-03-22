defmodule WorldLinkWeb.AuthController do
  alias WorldLink.Identity
  use WorldLinkWeb, :controller
  plug Ueberauth

  action_fallback WorldLinkWeb.FallbackController

  def callback(conn, _params) do
    assigns = conn.assigns.ueberauth_auth
    user_params = build_params_based_on_provider(assigns.provider, assigns)

    case Identity.verify_user_existence(user_params) do
      {:ok} ->
        {:ok, user} = Identity.create_oauth_user(user_params)
        render(conn, "show.json", user: user)

      {:error, :user_already_exists} ->
        user = Identity.get_user_by_email(user_params.email)
        render(conn, "show.json", user: user)
    end
  end

  defp build_params_based_on_provider(:discord, params) do
    %{
      provider_uid: params.uid,
      oauth_provider: :discord,
      name: params.info.name || params.info.nickname,
      nickname: params.info.nickname || params.info.name,
      email: params.info.email,
      avatar: params.info.image
    }
  end

  defp build_params_based_on_provider(:facebook, params) do
    %{
      provider_uid: params.uid,
      oauth_provider: :facebook,
      name: params.info.name || params.info.nickname,
      nickname: params.info.nickname || params.info.name,
      email: params.info.email,
      avatar: params.info.image
    }
  end
end
