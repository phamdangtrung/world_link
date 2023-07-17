# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :world_link,
  ecto_repos: [WorldLink.Repo]

# Configuration for migration primary key

config :world_link,
       WorldLink.Repo,
       migration_primary_key: [name: :id, type: :binary_id]

# Configures the endpoint
config :world_link, WorldLinkWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: WorldLinkWeb.ErrorHTML, json: WorldLinkWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: WorldLink.PubSub,
  live_view: [signing_salt: "UdqkcrYi"]

# Configures Guardian
config :world_link, WorldLinkWeb.Authentication.Guardian,
  issuer: "world_link",
  secret_key: System.get_env("GUARDIAN_SECRET")

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :world_link, WorldLink.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Ueberauth configs
config :ueberauth, Ueberauth,
  providers: [
    discord:
      {Ueberauth.Strategy.Discord,
       [
         #  default_scope: "identify connections email guilds",
         default_scope: "email",
         prompt: "none"
       ]},
    facebook:
      {Ueberauth.Strategy.Facebook,
       [
         default_scope: "email,public_profile"
       ]}
  ]

# PhoenixSwagger configuration

config :world_link, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      # phoenix routes will be converted to swagger paths
      router: WorldLinkWeb.Router,
      # (optional) endpoint config used to set host, port and https schemes.
      endpoint: WorldLinkWeb.Endpoint
    ]
  }

config :phoenix_swagger, json_library: Jason

# Strategy provider configuration
# config :ueberauth, Ueberauth.Strategy.Discord.OAuth,
#   client_id: System.get_env("DISCORD_CLIENT_ID"),
#   client_secret: System.get_env("DISCORD_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Discord.OAuth,
  client_id: System.get_env("DEV_UEBERAUTH_DISCORD_CLIENT_ID"),
  client_secret: System.get_env("DEV_UEBERAUTH_DISCORD_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: System.get_env("DEV_UEBERAUTH_FACEBOOK_CLIENT_ID"),
  client_secret: System.get_env("DEV_UEBERAUTH_FACEBOOK_CLIENT_SECRET")

# Configuration for Stripe

config :stripity_stripe,
  api_key: System.get_env("DEV_STRIPE_KEY"),
  hackney_opts: [{:connect_timeout, 1000}, {:recv_timeout, 5000}],
  retries: [max_attempts: 2, base_backoff: 500, max_backoff: 2_000]

# Configuration for commit_lint
config :commitlint,
  allowed_types: [
    "feat",
    "fix",
    "docs",
    "style",
    "refactor",
    "perf",
    "test",
    "build",
    "ci",
    "chore",
    "revert"
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
