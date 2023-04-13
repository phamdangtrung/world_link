defmodule WorldLink.Repo do
  use Ecto.Repo,
    otp_app: :world_link,
    adapter: Ecto.Adapters.Postgres

  def init(_, config) do
    config =
      config
      |> Keyword.put(:username, "postgres")
      |> Keyword.put(:password, "postgres")
      |> Keyword.put(:database, "wl_development")
      |> Keyword.put(:hostname, "db")
      |> Keyword.put(:port, "5432")

    {:ok, config}
  end
end
