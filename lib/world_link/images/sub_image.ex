defmodule WorldLink.Images.SubImage do
  @moduledoc """
  SubImage schema
  """
  alias WorldLink.AwsUtils
  alias WorldLink.Images.Image
  use WorldLink.Schema

  @image_types [:thumbnail, :preview, :original]

  schema "sub_images" do
    field(:type, Ecto.Enum, values: @image_types, default: :original)
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

  def generate_sub_images(user_id, %Image{} = image, types)
      when is_list(types) do
    inserted_at = DateTime.utc_now() |> DateTime.truncate(:second)

    Enum.map(
      types,
      &%{
        id: Ecto.ULID.generate(),
        type: &1,
        keyname: AwsUtils.generate_keyname(&1, user_id, image.original_filename),
        image_id: image.id,
        inserted_at: inserted_at,
        updated_at: inserted_at
      }
    )
  end

  def image_types, do: @image_types
end
