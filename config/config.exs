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
  render_errors: [view: WorldLinkWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: WorldLink.PubSub,
  live_view: [signing_salt: "UdqkcrYi"]

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
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
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

# Strategy provider configuration
# config :ueberauth, Ueberauth.Strategy.Discord.OAuth,
#   client_id: System.get_env("DISCORD_CLIENT_ID"),
#   client_secret: System.get_env("DISCORD_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Discord.OAuth,
  client_id: "1080413348081958922",
  client_secret: "384DtQlPrie0fjvLy6jpk73Opm34bHI3"

config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: "943252580360716",
  client_secret: "2b570e7a587af6069b1bce4dbeb5a411"

# Configuration for Stripe

config :stripity_stripe,
  api_key:
    "sk_test_51MmSWJAgrTXGiFxd0xUx3lBd2CiPfPBpvHtGXeBb4nrGE89V5cVs5tg9PjBa011URub7sNvvhGvsbm3X9gz4eWZy00bXdxQ9Eg",
  hackney_opts: [{:connect_timeout, 1000}, {:recv_timeout, 5000}],
  retries: [max_attempts: 2, base_backoff: 500, max_backoff: 2_000]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
