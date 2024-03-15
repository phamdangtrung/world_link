defmodule WorldLink.AwsUtils do
  @moduledoc """
  AWS Utilities module.
  """

  alias ExAws.S3

  # @available_regions ["us-east-1"]
  @bucket_name "world-link"
  @expiry_time 2

  def generate_presigned_url(keyname) do
    :s3
    |> ExAws.Config.new()
    |> S3.presigned_url(:post, @bucket_name, keyname, expires_in: @expiry_time)
  end

  def generate_keyname(type, user_id, original_filename) do
    "#{type}/#{user_id}/#{Ecto.ULID.generate()}_#{UUID.uuid1()}_#{original_filename}"
  end
end
