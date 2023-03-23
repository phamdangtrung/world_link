defmodule WorldLinkWeb.Authentication.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :world_link_api,
    module: WorldLinkWeb.Authentication.Guardian,
    error_handler: WorldLinkWeb.Authentication.ErrorHandler

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
