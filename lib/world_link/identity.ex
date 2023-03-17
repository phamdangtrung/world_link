defmodule WorldLink.Identity do
  @moduledoc """
  The Identity context.
  """

  import Ecto.Query, warn: false
  alias WorldLink.Repo

  alias WorldLink.Identity.User

  @doc """
  Returns the list of users with pagination.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users(opts \\ []) do
    defaults = %{
      page: 1,
      page_size: 10
    }

    %{page: page, page_size: page_size} = Enum.into(opts, defaults)

    Repo.all(
      from users in User,
        select: [:id, :name, :activated, :provider_uid, :uuid, :oauth_provider],
        limit: ^page_size,
        offset: ^((page - 1) * page_size)
    )
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def create_oauth_user(attrs \\ %{}) do
    %User{}
    |> User.oauth_registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """

  # def change_user(%User{} = user, attrs \\ %{}) do
  #   User.changeset(user, attrs)
  # end

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end


  @doc """
  Gets a user by oauth credentials.

  ## Examples

      iex> get_oauth_user("some-correct-uuid", :provider)
      %User{}

      iex> get_oauth_user("some-incorrect-uuid", :provider)
      nil

  """
  def get_oauth_user(provider_uid, oauth_provider)
    when is_binary(provider_uid) and is_atom(oauth_provider) do
    Repo.get_by(User, [provider_uid: provider_uid, oauth_provider: oauth_provider])
  end
end
