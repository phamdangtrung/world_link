defmodule WorldLink.Images do
  @moduledoc """
  The Images context.
  """
  alias WorldLink.AwsUtils
  alias Ecto.{Changeset, Multi}
  alias WorldLink.Identity.User
  alias WorldLink.Images.{Image, SubImage}
  alias WorldLink.Repo

  import Ecto
  import Ecto.Query, warn: false

  @spec create_image(User.t() | any(), %{} | map() | any()) ::
          {:ok, Image.t()} | {:error, Changeset.t()} | {:error, :unknown_error}
  @doc """
  Create an image for a given user

  ## Examples

      iex> create_image(%User{}, %{})
      {:ok, %Image{}}

      iex> create_image(%User{}, %{})
      {:error, %Changeset{}}

      iex> create_image(%User{}, %{})
      {:error, :unknown_error}

      iex> create_image(%User{}, %{})
      {:error, :invalid_params}

  """
  def create_image(%User{} = user, image_attrs) do
    Multi.new()
    |> Multi.insert(
      :create_image,
      user
      |> build_assoc(:images)
      |> Image.changeset(image_attrs)
    )
    |> Multi.run(
      :create_sub_images,
      fn repo, %{create_image: image} ->
        entries =
          SubImage.generate_sub_images(user.id, image, [:original, :preview ])

        case repo.insert_all(SubImage, entries) do
          {0, _} ->
            {:error, :internal_error}

          {_, _} ->
            {:ok, entries}
        end
      end
    )
    |> Multi.run(
      :create_presigned_urls,
      fn _, %{create_sub_images: sub_images} ->
        presigned_urls =
          Enum.map(
            sub_images,
            fn sub_image ->
              {:ok, url} = AwsUtils.generate_presigned_url(sub_image.keyname)

              %{
                type: sub_image.type,
                url: url
              }
            end
          )

        {:ok, presigned_urls}
      end
    )
    |> Repo.transaction()
  end

  def create_image(_, _), do: {:error, :invalid_params}
end
