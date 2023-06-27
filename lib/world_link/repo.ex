defmodule WorldLink.Repo do
  use Ecto.Repo,
    otp_app: :world_link,
    adapter: Ecto.Adapters.Postgres

  def init(_, config) do
    env = Mix.env() |> to_string |> String.upcase()
    
    config
    |> initialize_db_settings(env)
    |> configure_additional_db_settings(env)

    {:ok, config}
  end

  defp initialize_db_settings(config, env) do
    config
    |> Keyword.put(:username, System.get_env("#{env}_DB_USERNAME"))
    |> Keyword.put(:password, System.get_env("#{env}_DB_PASSWORD"))
    |> Keyword.put(:database, System.get_env("#{env}_DB_DATABASE"))
    |> Keyword.put(:hostname, System.get_env("#{env}_DB_HOSTNAME"))
    |> Keyword.put(:port, System.get_env("#{env}_DB_PORT"))
  end

  defp configure_additional_db_settings(config, env) when env == "DEV" do
    config
    |> Keyword.put(:stacktrace, true)
    |> Keyword.put(:show_sensitive_data_on_connection_error, true)
    |> Keyword.put(:pool_size, 10)
  end

  defp configure_additional_db_settings(config, env) when env == "TEST" do
    config
    |> Keyword.put(:pool, Ecto.Adapters.SQL.Sandbox)
    |> Keyword.put(:pool_size, 10)
  end
end
