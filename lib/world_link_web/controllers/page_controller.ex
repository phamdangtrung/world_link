defmodule WorldLinkWeb.PageController do
  use WorldLinkWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
