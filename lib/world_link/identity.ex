defmodule WorldLink.Identity do
  @moduledoc """
  The Identity context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias WorldLink.Identity.OauthProfile
  alias WorldLink.Identity.User
  alias WorldLink.Repo

  @spec create_user(%{} | map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
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

  @spec create_oauth_user(%{} | map()) ::
          {:ok, User.t()} | {:error, atom(), Ecto.Changeset.t()} | {:error, String.t()}
  @doc """
  Creates a user using OAuth2.

  ## Examples

      iex> create_oauth_user(%{field: value})
      {:ok, %User{}}

      iex> create_oauth_user(%{field: bad_value})
      {:error, :user, %Ecto.Changeset{}}

      iex> create_oauth_user(%{field: bad_value})
      {:error, :oauth_profile, %Ecto.Changeset{]}}

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

  @spec assign_oauth_profile(User.t(), %{} | map()) ::
          {:ok, OauthProfile.t()} | {:error, %Ecto.Changeset{}} | {:error, :invalid_params}
  @doc """
  Assigns an %OauthProfile{} to an existing %User{}.

  ## Examples

      iex> assign_oauth_profile(%User{}, attrs)
      {:ok, %OauthProfile{}}

      iex> assign_oauth_profile(%User{}, attrs)
      {:error, %Ecto.Changeset{}}

  """
  def assign_oauth_profile(%User{} = user, attrs) when is_map(attrs) do
    OauthProfile.registration_changeset(user, attrs)
    |> Repo.insert()
  end

  def assign_oauth_profile(_, _), do: {:error, :invalid_params}
  @spec verify_user_existence(%{} | map()) :: {:ok} | {:error, :user_already_exists, User.t()}
  @doc """
  Verifies whether user with the provided email or a combination of provider_uid and oauth_provider exist in the database

  ## Examples

      iex> verify_user_existence(attrs)
      {:ok}

      iex> verify_user_existence(attrs)
      {:error, :user_already_exists, %User{}}

  """
  def verify_user_existence(attrs \\ %{}) do
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
      user -> {:error, :user_already_exists, user}
    end
  end

  @spec get_user_by_email_or_username(String.t()) ::
          {:ok, User.t()}
          | {:error, :not_found}
          | {:error, :invalid_params}
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

      iex> get_user_by_email(123)
      {:error, :invalid_params}


  """
  def get_user_by_email_or_username(email_or_username) when is_binary(email_or_username) do
    with nil <- get_user_by_email(email_or_username),
         nil <- get_user_by_username(email_or_username) do
      {:error, :not_found}
    else
      %User{} = user -> {:ok, user}
    end
  end

  def get_user_by_email_or_username(_), do: {:error, :invalid_params}

  defp get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, normalized_email: email |> String.downcase())
    |> case do
      %User{} = user -> user
      nil -> nil
    end
  end

  defp get_user_by_username(username) when is_binary(username) do
    Repo.get_by(User, normalized_username: username |> String.downcase())
    |> case do
      %User{} = user -> user
      nil -> nil
    end
  end

  @spec verify_user_and_password(User.t(), String.t()) ::
          {:error, :unauthenticated} | {:ok, User.t()}
  @doc """
  Verifies password and returns a tuple.

  ## Examples

      iex> verify_user_and_password(%User{}, correct_password)
      {:ok, user}

      iex> verify_user_and_password(%User{}, incorrect_password)
      {:error, :unauthenticated}

      iex> verify_user_and_password(%OauthProfile{}, incorrect_password)
      {:error, :invalid_params}

  """
  def verify_user_and_password(%User{} = user, password) do
    if User.valid_password?(user, password) do
      {:ok, user}
    else
      {:error, :unauthenticated}
    end
  end

  def verify_user_and_password(_, _), do: {:error, :invalid_params}

  @spec get_oauth_user(String.t() | any(), atom() | any()) :: User.t() | nil
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
    |> Repo.preload(:user)
    |> case do
      %OauthProfile{} = oauth_profile -> oauth_profile.user
      nil -> nil
    end
  end

  def get_oauth_user(_provider_uid, _oauth_provider), do: nil
end
