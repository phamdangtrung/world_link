defmodule WorldLinkWeb.UserController do
  use WorldLinkWeb, :controller
  alias WorldLink.Identity

  def index(conn, %{"page" => page, "page_size" => page_size}) do
    {page, _} = Integer.parse(page)
    {page_size, _} = Integer.parse(page_size)
    users = Identity.list_users(page: page, page_size: page_size)

    render(conn, "show.json", users: users)
  end

  def index(conn, _params) do
    users = Identity.list_users()

    render(conn, "show.json", users: users)
  end
end
