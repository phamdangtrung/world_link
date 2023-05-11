defmodule WorldLink.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      WorldLink.Repo,
      # Start the Telemetry supervisor
      WorldLinkWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: WorldLink.PubSub},
      # Start the Endpoint (http/https)
      WorldLinkWeb.Endpoint,
      # Start a worker by calling: WorldLink.Worker.start_link(arg)
      {WorldLink.Workers.DatabaseCleanupWorker, %{}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WorldLink.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WorldLinkWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
