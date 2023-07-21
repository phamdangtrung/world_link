defmodule WorldLink.Images do
  @moduledoc """
  The Images context.
  """
  alias Ecto.{Changeset}
  alias WorldLink.Identity.User
  alias WorldLink.Images.{Album, AlbumsImages, Image}
  alias WorldLink.Repo

  import Ecto
  import Ecto.Query, warn: false

  @spec add_to_album(Album.t() | any(), list(Image.t())) ::
          {:ok, non_neg_integer()}
          | {:error, :no_change}
          | {:error, :invalid_params}
  @doc """
  Returns a tuple after trying to add a list of images to an album

   ## Examples

      iex> add_to_album(%Album{}, [%Image{}, ...])
      {:ok, affected_rows}

      iex> add_to_album(%Album{}, [%Image{}, ...])
      {:error, :no_change}

      iex> add_to_album("123", [%Image{}, ...])
      {:error, :invalid_params}

  """
  def add_to_album(%Album{} = album, images) when is_list(images) do
    entries =
      Enum.map(images, & &1.id)
      |> filter_existing_images_in_album(album.id)
      |> Enum.map(&%{album_id: album.id, image_id: &1})

    Repo.transaction(fn repo ->
      repo.insert_all(AlbumsImages, entries)
    end)
    |> case do
      {:ok, {0, _}} -> {:error, :no_change}
      {:ok, {affected_rows, _}} -> {:ok, affected_rows}
      _ -> {:error, :no_change}
    end
  end

  def add_to_album(_, _), do: {:error, :invalid_params}

  defp filter_existing_images_in_album(image_ids, album_id) do
    already_added_images =
      from(ai in AlbumsImages,
        where: ai.album_id == ^album_id and ai.image_id in ^image_ids,
        select: ai.image_id
      )
      |> Repo.all()
      |> Enum.map(& &1.image_id)

    Enum.filter(image_ids, &(!Enum.member?(already_added_images, &1)))
  end

  @spec create_album(User.t() | any(), %{} | map() | any()) ::
          {:ok, Album.t()}
          | {:error, Changeset.t()}
          | {:error, :invalid_params}
  @doc """
  Returns a tuple after trying to create an album for a given user

   ## Examples

      iex> create_album(%User{}, %{title: "test", description: "something"})
      {:ok, %Album{}}

      iex> get_album(%User{}, %{})
      {:error, %Ecto.Changeset{}}

      iex> get_album("test", %{})
      {:error, :invalid_params}

  """
  def create_album(%User{} = user, album_attrs) do
    Repo.transaction(fn repo ->
      user
      |> build_assoc(:albums)
      |> Album.new_album_changeset(album_attrs)
      |> repo.insert()
    end)
    |> case do
      {_, {:ok, %Album{} = album}} -> {:ok, album}
      {_, {:error, %Changeset{} = changeset}} -> {:error, changeset}
    end
  end

  def create_album(_, _), do: {:error, :invalid_params}

  @spec get_album(String.t() | any()) :: Album.t() | {:error, :invalid_params}
  @doc """
  Returns an album with a given album id

  ## Examples

      iex> get_album(album_id)
      %Album{}

      iex> get_album(nil)
      {:error, :invalid_params}

  """
  def get_album(album_id) when is_binary(album_id) do
    Repo.get_by(Album, id: album_id)
  end

  def get_album(_) do
    {:error, :invalid_params}
  end

  @spec list_albums(User.t() | any()) :: list(Album.t()) | {:error, :invalid_params}
  @doc """
  Returns the list of albums created by a user.

  ## Examples

      iex> list_albums(%User{})
      [%Album{}, ...]

      iex> list_albums(any())
      {:error, :invalid_params}

  """
  def list_albums(%User{id: user_id} = _user) do
    from(a in Album,
      where: a.user_id == ^user_id
    )
    |> Repo.all()
  end

  def list_albums(_) do
    {:error, :invalid_params}
  end

  @spec update_album_count(Album.t() | any()) :: Album.t() | {:error, :invalid_params}
  def update_album_count(%Album{} = album) do
    attrs = %{count: count_images(album)}

    Repo.transaction(fn repo ->
      Album.album_count_changeset(album, attrs)
      |> repo.update()
    end)
  end

  def(update_album_count(_), do: {:error, :invalid_params})

  defp count_images(%Album{id: album_id}) do
    from(ai in AlbumsImages,
      where: ai.album_id == ^album_id
    )
    |> Repo.aggregate(:count, :image_id)
  end

  def delete_album(album_id) when is_binary(album_id) do
  end
end
