defmodule WorldLink.Repo do
  use Ecto.Repo,
    otp_app: :world_link,
    adapter: Ecto.Adapters.Postgres

  def init(_, config) do
    config =
      config
      |> Keyword.put(:username, System.get_env("PGUSER"))
      |> Keyword.put(:password, System.get_env("PGPASSWORD"))
      |> Keyword.put(:database, System.get_env("PGDATABASE"))
      |> Keyword.put(:hostname, System.get_env("PGHOST"))
      |> Keyword.put(:port, System.get_env("PGPORT"))

      # config
      # |> Keyword.put(:username, "postgres")
      # |> Keyword.put(:password, "123")
      # |> Keyword.put(:database, "wl_development")
      # |> Keyword.put(:hostname, "localhost")
      # |> Keyword.put(:port, 5432)

    {:ok, config}
  end
end
