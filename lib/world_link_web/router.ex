defmodule WorldLinkWeb.Router do
  use WorldLinkWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {WorldLinkWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(WorldLinkWeb.Locale, "en")
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :auth do
    plug(WorldLinkWeb.Authentication.Pipeline)
  end

  pipeline :un_auth do
    plug(WorldLinkWeb.Authentication.UnauthPipeline)
  end

  pipeline :admin do
    plug(WorldLinkWeb.Plugs.EnsureRolePlug, [:admin])
  end

  scope "/", WorldLinkWeb do
    pipe_through(:browser)

    get("/", PageController, :home)
  end

  scope "/auth", WorldLinkWeb do
    pipe_through([:api, :un_auth])

    post("/login", AuthController, :login)
    get("/:provider", AuthController, :request)
    get("/:provider/callback", AuthController, :callback)
  end

  # Other scopes may use custom stacks.
  scope "/api", WorldLinkWeb do
    pipe_through(:api)
    post("/process", PageController, :process)

    scope "/users" do
      pipe_through([:auth, :admin])
      get("/", UserController, :index)
    end
  end

  scope "/api/swagger" do
    forward("/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :world_link,
      swagger_file: "swagger.json"
    )
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)

      live_dashboard("/dashboard",
        ecto_repos: [WorldLink.Repo],
        ecto_psql_extras_options: [long_running_queries: [threshold: "200 milliseconds"]],
        metrics: WorldLinkWeb.Telemetry
      )
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "World Link API",
        basePath: "/api"
      },
      securityDefinitions: %{
        Bearer: %{
          type: "apiKey",
          name: "Authorization",
          in: "header"
        }
      }
    }
  end

  ## Authentication routes

  # scope "/", WorldLinkWeb do
  #   pipe_through [:browser, :redirect_if_user_is_authenticated]

  #   get "/users/register", UserRegistrationController, :new
  #   post "/users/register", UserRegistrationController, :create
  #   get "/users/log_in", UserSessionController, :new
  #   post "/users/log_in", UserSessionController, :create
  #   get "/users/reset_password", UserResetPasswordController, :new
  #   post "/users/reset_password", UserResetPasswordController, :create
  #   get "/users/reset_password/:token", UserResetPasswordController, :edit
  #   put "/users/reset_password/:token", UserResetPasswordController, :update
  # end

  # scope "/", WorldLinkWeb do
  #   pipe_through [:browser, :require_authenticated_user]

  #   get "/users/settings", UserSettingsController, :edit
  #   put "/users/settings", UserSettingsController, :update
  #   get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  # end

  # scope "/", WorldLinkWeb do
  #   pipe_through [:browser]

  #   delete "/users/log_out", UserSessionController, :delete
  #   get "/users/confirm", UserConfirmationController, :new
  #   post "/users/confirm", UserConfirmationController, :create
  #   get "/users/confirm/:token", UserConfirmationController, :edit
  #   post "/users/confirm/:token", UserConfirmationController, :update
  # end
end
