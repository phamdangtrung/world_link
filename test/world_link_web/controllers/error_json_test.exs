defmodule WorldLinkWeb.ErrorJSONTest do
  use WorldLinkWeb.ConnCase, async: true

  test "renders 404" do
    assert WorldLinkWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert WorldLinkWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error occurred!"}}
  end
end
