defmodule WorldLink.User do
  @moduledoc """
  User context for user management
  """
  import Ecto.Query

  alias WorldLink.Identity.User
  alias WorldLink.Repo

  @spec list_users(map()) :: [User.t(), ...] | []
  @doc """
  Returns the list of users with pagination.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users(opts \\ %{}) do
    defaults = %{
      page_size: 20,
      last_user_id: nil
    }

    %{page_size: page_size, last_user_id: last_user_id} = Enum.into(opts, defaults)

    list_users(page_size, last_user_id)
  end

  defp list_users(page_size, last_user_id) when not is_nil(last_user_id) do
    from(users in User,
      select: [:id, :name, :activated, :normalized_email, :normalized_username, :role_name],
      limit: ^page_size,
      where: users.id > ^last_user_id
    )
    |> Repo.all()
  end

  defp list_users(page_size, _) do
    from(users in User,
      select: [:id, :name, :activated, :normalized_email, :normalized_username, :role_name],
      limit: ^page_size
    )
    |> Repo.all()
  end

  @spec get_user_by_id(String.t()) :: User.t() | %Ecto.NoResultsError{}
  @doc """
  Gets a single user using id.

  Returns :nil if the User does not exist.

  ## Examples

      iex> get_user_by_id(123)
      %User{}

      iex> get_user_by_id(456)
      nil

  """
  def get_user_by_id(id), do: Repo.get(User, id)

  @spec get_user_by_email(String.t()) :: User.t() | %Ecto.NoResultsError{}
  @doc """
  Gets a single user using email.

  Returns :nil if the User does not exist.

  ## Examples

      iex> get_user_by_email("123@test.com")
      %User{}

      iex> get_user_by_email(456)
      nil

  """
  def get_user_by_email(email), do: Repo.get_by(User, normalized_email: email |> String.downcase())
end