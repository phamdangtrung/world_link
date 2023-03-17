defmodule WorldLinkWeb.AuthController do
  alias WorldLink.Identity
  alias WorldLink.Identity.User
  use WorldLinkWeb, :controller
  plug Ueberauth

  action_fallback WorldLinkWeb.FallbackController

  def callback(conn, _params) do
    assigns = conn.assigns.ueberauth_auth
    user_params = build_params_based_on_provider(assigns.provider, assigns)
    user = search_for_user(user_params)

    case user do
      %User{} -> render(conn, "show.json", user: user)
      _ -> {:ok, user} = Identity.create_oauth_user(user_params)
      render(conn, "show.json", user: user)
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

  defp search_for_user(%{provider_uid: provider_uid, oauth_provider: oauth_provider}) do
    Identity.get_oauth_user(provider_uid, oauth_provider)
  end
end
