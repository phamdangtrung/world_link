defmodule WorldLink.Repo do
  use Ecto.Repo,
    otp_app: :world_link,
    adapter: Ecto.Adapters.Postgres
end
