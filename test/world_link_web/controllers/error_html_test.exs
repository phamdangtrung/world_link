defmodule WorldLinkWeb.ErrorHTMLTest do
  use WorldLinkWeb.ConnCase, async: true

  import Phoenix.Template

  # test "renders 404.html" do
  #   {:ok, html} =
  #     render_to_string(WorldLinkWeb.ErrorHTML, "404", "html", []) |> Floki.parse_document()

  #   assert ==
  #     "Sorry, the page you are looking for does not exist"
  # end

  test "renders 500.html" do
    assert render_to_string(WorldLinkWeb.ErrorHTML, "500", "html", []) == "Internal Server Error"
  end
end
