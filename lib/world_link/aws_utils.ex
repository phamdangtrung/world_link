defmodule WorldLink.AwsUtils do
  @moduledoc """
  AWS Utilities module.
  """

  @available_regions ["us-east-1"]
  @bucket_name "world-link"

  def generate_presigned_url do
    @available_regions
    @bucket_name
  end
end
