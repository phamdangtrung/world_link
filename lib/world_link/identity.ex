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
  Gets a single user using id.

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
      {:ok, %{user: %User{}, oauth_profile: _}}

      iex> create_oauth_user(%{field: bad_value})
      {:error, "An error occurred when trying to register this user."}

      iex> create_oauth_user(%{field: bad_value})
      {:error, "An error occurred when trying to register an oauth profile for this user."}

      iex> create_oauth_user(%{field: bad_value})
      {:error, "An unknown error."}

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

      {:error, :user, changeset, _} ->
        {:error, :user, changeset}

      {:error, :oauth_profile, changeset, _} ->
        {:error, :oauth_profile, changeset}

      {:error, _, _, _} ->
        {:error, "An unknown error."}
    end
  end

  @doc """
  Assigns an %OauthProfile{} to an existing %User{}.

  ## Examples

      iex> assign_oauth_profile(%User{}, attrs)
      {:ok, %OauthProfile{}}

      iex> assign_oauth_profile(%User{}, attrs)
      {:error, changeset

  """

  def assign_oauth_profile(%User{} = user, attrs \\ %{}) do
    OauthProfile.registration_changeset(user, attrs)
    |> Repo.insert()
  end

  @doc """
  Verifies whether user with the provided email or a combination of provider_uid and oauth_provider exist in the database

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

    with nil <- get_oauth_user(email),
         nil <- get_oauth_user(provider_uid, oauth_provider) do
      {:ok}
    else
      user -> {:error, :user_already_exists, user}
    end
  end

  @doc """
  Gets a user by email or username.

  ## Examples

      iex> get_user_by_email_or_username("foo@example.com")
      {:ok, %User{}}

      iex> get_user_by_email_or_username("foo_bar")
      {:ok, %User{}}

      iex> get_user_by_email("unknown@example.com")
      {:error, :not_found}

      iex> get_user_by_email("foo")
      {:error, :not_found}

  """
  def get_user_by_email_or_username(email_or_username) when is_binary(email_or_username) do
    get_user_by_email(email_or_username)
    |> get_user_by_username()
    |> case do
      %User{} = user -> {:ok, user}
      nil -> {:error, :not_found}
    end
  end

  defp get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, normalized_email: email |> String.downcase())
    |> case do
      %User{} = user -> user
      nil -> email
    end
  end

  defp get_user_by_username(username) when is_binary(username) do
    Repo.get_by(User, normalized_username: username |> String.downcase())
    |> case do
      %User{} = user -> user
      nil -> nil
    end
  end

  defp get_user_by_username(user) when is_struct(user), do: user

  @doc """
  Verifies password and returns a tuple.

  ## Examples

      iex> verify_user_and_password(%User{}, correct_password)
      {:ok, user}

      iex> verify_user_and_password(%User{}, incorrect_password)
      {:error, :unauthenticated}

  """

  def verify_user_and_password(%User{} = user, password) do
    if User.valid_password?(user, password) do
      {:ok, user}
    else
      {:error, :unauthenticated}
    end
  end

  @doc """
  Gets a user by oauth credentials.

  ## Examples

      iex> get_oauth_user("some-correct-email")
      %User{}

      iex> get_oauth_user("some-incorrect-email")
      nil

  """
  def get_oauth_user(email) when is_binary(email) do
    Repo.get_by(User, normalized_email: email |> String.downcase())
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
