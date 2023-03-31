defmodule WorldLink.Repo do
  use Ecto.Repo,
    otp_app: :world_link,
    adapter: Ecto.Adapters.Postgres

  def init(_, config) do
    config =
      config
      |> Keyword.put(:username, "postgres")
      |> Keyword.put(:password, "123")
      |> Keyword.put(:database, "wl_development")
      |> Keyword.put(:hostname, "localhost")
      |> Keyword.put(:port, "5432")

    {:ok, config}
  end
end
