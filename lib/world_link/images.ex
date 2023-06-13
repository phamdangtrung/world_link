defmodule WorldLink.Images do
  @moduledoc """
  The Images context.
  """

  import Ecto.Query, warn: false
  alias WorldLink.Repo

  alias WorldLink.Images.Image

  @doc """
  Returns the list of images.

  ## Examples

      iex> list_images()
      [%Image{}, ...]

  """
  def list_images do
    Repo.all(Image)
  end
end
