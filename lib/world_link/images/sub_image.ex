defmodule WorldLink.Images.SubImage do
  @moduledoc """
  Image schema
  """
  alias WorldLink.Images.Image
  import Ecto.Changeset
  use WorldLink.Schema

  @image_type [:thumbnail, :preview, :original]

  schema "sub_images" do
    field(:type, Ecto.Enum, values: @image_type, default: :original)
    field(:keyname, :string)

    belongs_to(:image, Image)
    timestamps()
  end

  @type t() :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: Ecto.ULID.t(),
          type: atom(),
          keyname: String.t(),
          image_id: Ecto.ULID.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  def original_image_changeset(assoc_changeset, image_url_attrs) do
    assoc_changeset
    |> cast(image_url_attrs, [:type, :keyname])
    |> validate_required([:type, :keyname])
    |> validate_length(:keyname, max: 1024)
    |> validate_length(:type, max: 20)
  end

  def image_types, do: @image_type
end
