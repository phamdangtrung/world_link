defmodule WorldLink.Images.ImageUrl do
  @moduledoc """
  Image schema
  """
  alias WorldLink.Images.Image
  import Ecto.Changeset
  use WorldLink.Schema

  @image_type [:thumbnail, :preview, :original]

  schema "image_urls" do
    field(:type, Ecto.Enum, values: @image_type, default: :original)
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

  def original_image_changeset(assoc_changeset, image_url_attrs) do
    assoc_changeset
    |> cast(image_url_attrs, [:type, :s3_url, :url])
    |> validate_required([:type, :s3_url, :url])
  end

  def image_types, do: @image_type
end
