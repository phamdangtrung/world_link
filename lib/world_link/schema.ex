defmodule WorldLink.Schema do
  @moduledoc """
  Shared schema configuration for ecto
  """

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @primary_key {:id, Ecto.ULID, autogenerate: true}
      @foreign_key_type Ecto.ULID
      @timestamps_opts [type: :utc_datetime]
    end
  end
end
