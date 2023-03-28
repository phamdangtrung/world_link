defmodule WorldLinkWeb.Authentication.UnauthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :world_link_api,
    module: WorldLinkWeb.Authentication.Guardian,
    error_handler: WorldLinkWeb.Authentication.ErrorHandler

  plug Guardian.Plug.EnsureNotAuthenticated
end
