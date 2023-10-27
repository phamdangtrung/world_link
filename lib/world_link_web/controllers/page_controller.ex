defmodule WorldLinkWeb.PageController do
  use WorldLinkWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def process(conn, params) do
    # The home page is often custom made,
    # so skip the default app layout.
    conn |> IO.inspect()
    params |> IO.inspect()
    render(conn, :ok)
  end
end
