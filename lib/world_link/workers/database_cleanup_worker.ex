defmodule WorldLink.Workers.DatabaseCleanupWorker do
  use GenServer
  import Ecto.Query
  require Logger
  alias Ecto.Multi
  alias WorldLink.Identity.{OauthProfile, User}
  alias WorldLink.Repo

  alias WorldLink.Worlds.{
    Character,
    CharacterInfo,
    Timeline,
    TimelinesCharacterInfo,
    World,
    WorldsCharacters
  }

  @one_week 86_400_000 * 7

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(state) do
    schedule_database_cleanup()
    {:ok, state}
  end

  def handle_info(:database_cleanup, state) do
    Logger.info("Starting database cleanup operation")
    Logger.info("Current state:")
    Logger.info(state)

    date = Date.utc_today() |> to_string()
    task = cleanup_database()

    task
    |> case do
      {:ok, _affected_rows} ->
        Logger.info("Successfully cleaned up")

      {:error, reason, message} ->
        Logger.error("Failed to clean up database due to the following reason.")
        Logger.error("Reason: #{reason}")
        Logger.error("Error message: #{message}")
    end

    Logger.info("Ending database cleanup operation")
    schedule_database_cleanup()
    {:noreply, Map.put(state, date, task)}
  end

  defp schedule_database_cleanup() do
    Process.send_after(self(), :database_cleanup, @one_week)
  end

  defp cleanup_database() do
    Multi.new()
    |> Multi.delete_all(
      :delete_all_timelines_character_info,
      from(tci in TimelinesCharacterInfo,
        where: tci.deleted == true
      ),
      []
    )
    |> Multi.delete_all(
      :delete_all_timeline,
      from(t in Timeline,
        where: t.deleted == true
      ),
      []
    )
    |> Multi.delete_all(
      :delete_all_character_info,
      from(ci in CharacterInfo,
        where: ci.deleted == true
      ),
      []
    )
    |> Multi.delete_all(
      :delete_all_worlds_characters,
      from(wc in WorldsCharacters,
        where: wc.deleted == true
      ),
      []
    )
    |> Multi.delete_all(
      :delete_all_world,
      from(w in World,
        where: w.deleted == true
      ),
      []
    )
    |> Multi.delete_all(
      :delete_all_character,
      from(c in Character,
        where: c.deleted == true
      ),
      []
    )
    |> Multi.delete_all(
      :delete_all_oauth_profile,
      from(op in OauthProfile,
        where: op.deleted == true
      ),
      []
    )
    |> Multi.delete_all(
      :delete_all_user,
      from(u in User,
        where: u.deleted == true
      ),
      []
    )
    |> Repo.transaction()
    |> case do
      {:ok, affected_rows} -> {:ok, affected_rows}
      {:error, reason, message, _} -> {:error, reason, message}
    end
  end
end
