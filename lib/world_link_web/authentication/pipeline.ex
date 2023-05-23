defmodule WorldLinkWeb.Authentication.Pipeline do
  @moduledoc """
  Pipeline to ensure the user is logged in
  """
  use Guardian.Plug.Pipeline,
    otp_app: :world_link_api,
    module: WorldLinkWeb.Authentication.Guardian,
    error_handler: WorldLinkWeb.Authentication.ErrorHandler

  plug(Guardian.Plug.VerifySession)
  plug(Guardian.Plug.VerifyHeader)
  plug(Guardian.Plug.EnsureAuthenticated, claims: %{"typ" => "access"})
  plug(Guardian.Plug.LoadResource)
end
