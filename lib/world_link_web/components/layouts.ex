defmodule WorldLinkWeb.Layouts do
  @moduledoc """
  Docs
  """
  use WorldLinkWeb, :html

  embed_templates("layouts/*")
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}
end
