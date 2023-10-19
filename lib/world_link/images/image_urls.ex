defmodule WorldLink.Images.ImageUrl do
  @moduledoc """
  Image schema
  """
  alias WorldLink.Images.Image
  use WorldLink.Schema

  @image_type [:thumbnail, :preview, :original]

  schema "image_urls" do
    field(:type, Ecto.Enum, values: @image_type)
    field(:s3_url, :string)
    field(:url, :string)

    belongs_to(:image, Image)
    timestamps()
  end

  @type t() :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: Ecto.ULID.t(),
          type: atom(),
          s3_url: String.t(),
          url: String.t(),
          image_id: Ecto.ULID.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  def image_types, do: @image_type
end
