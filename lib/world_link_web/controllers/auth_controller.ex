defmodule WorldLinkWeb.AuthController do
  alias WorldLink.Identity
  use WorldLinkWeb, :controller
  plug Ueberauth

  action_fallback WorldLinkWeb.FallbackController

  def callback(conn, _params) do
    assigns = conn.assigns.ueberauth_auth
    user_params = build_params_based_on_provider(assigns.provider, assigns)

    case Identity.create_oauth_user(user_params) do
      {:ok, user} -> render(conn, "show.json", user: user)
    end
  end

  defp build_params_based_on_provider(:discord, params) do
    %{
      provider_uid: params.uid,
      oauth_provider: :discord,
      name: params.info.name || params.info.nickname,
      email: params.info.email,
      avatar: params.info.image
    }
  end
end
