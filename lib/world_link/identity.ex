defmodule WorldLink.Identity do
  @moduledoc """
  The Identity context.
  """

  import Ecto.Query, warn: false

  alias WorldLink.Repo
  alias Ecto.Multi
  alias WorldLink.Identity.User
  alias WorldLink.Identity.OauthProfile

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
        select: [:id, :name, :activated, :username, :email],
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

  @doc """
  Creates a user using OAuth2.

  ## Examples

      iex> create_oauth_user(%{field: value})
      {:ok, %User{}}

      iex> create_oauth_user(%{field: bad_value})
      {:error, "message"}

  """

  def create_oauth_user(attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:user, User.oauth_registration_changeset(%User{}, attrs))
    |> Multi.run(:oauth_profile, fn repo, %{user: user} ->
      OauthProfile.registration_changeset(user, attrs)
      |> repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user, oauth_profile: _}} ->
        {:ok, user}

      {:error, :user} ->
        {:error, "An error occurred when trying to register this user."}

      {:error, :oauth_profile} ->
        {:error, "An error occurred when trying to register an oauth profile for this user."}

      {:error, _} ->
        {:error, "An unknown error."}
    end
  end

  @doc """
  Returns a tuple for checking user existence.

  ## Examples

      iex> verify_user_existence(attrs)
      {:ok}

      iex> verify_user_existence(attrs)
      {:error, :user_already_exists}

  """

  def verify_user_existence(attrs \\ []) do
    defaults = %{
      provider_uid: nil,
      oauth_provider: nil
    }

    %{email: email, provider_uid: provider_uid, oauth_provider: oauth_provider} =
      Enum.into(attrs, defaults)

    with nil <- get_user_by_email(email),
         nil <- get_oauth_user(provider_uid, oauth_provider) do
      {:ok}
    else
      _ -> {:error, :user_already_exists}
    end
  end

  # Database getters

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

    if User.valid_password?(user, password) do
      user
    else
      User.valid_password?(nil, nil)
    end
  end

  def verify_password(%User{} = user, password) do
    User.valid_password?(user, password)
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
    Repo.get_by(OauthProfile, provider_uid: provider_uid, oauth_provider: oauth_provider)
  end

  def get_oauth_user(_provider_uid, _oauth_provider), do: nil
end
