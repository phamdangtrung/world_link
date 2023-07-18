defmodule WorldLink.Images do
  @moduledoc """
  The Images context.
  """
  alias WorldLink.Identity.User
  alias WorldLink.Images.{Album, Image}
  alias WorldLink.Repo

  import Ecto.Query, warn: false

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

  @doc """
  Returns the list of images.

  ## Examples

      iex> list_images(user, last_image_id)
      [%Image{}, ...]

  """

  def list_images(%User{id: user_id} = _user, last_image_id)
      when not is_nil(last_image_id) and is_binary(last_image_id) do
    from(i in Image,
      where: i.user_id == ^user_id and i.id > ^last_image_id
    )
    |> Repo.all()
  end

  def list_images(%User{id: user_id} = _user, _last_image_id) do
    from(i in Image,
      where: i.user_id == ^user_id
    )
    |> Repo.all()
  end
end
