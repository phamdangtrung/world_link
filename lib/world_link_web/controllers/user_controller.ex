defmodule WorldLinkWeb.UserController do
  use WorldLinkWeb, :controller
  use PhoenixSwagger
  alias WorldLink.Identity
  alias WorldLinkWeb.Router.Helpers

  @uri %URI{scheme: "http", host: "localhost", port: 4001}

  swagger_path :index do
    get(Helpers.user_path(@uri, :index))
    summary("List all user records")
    description("List all user records. The default page and page size is 1 and 10 respectively")
    security([%{Bearer: []}])
    response(200, "Ok", Schema.ref(:Users))
  end

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

  def swagger_definitions() do
    %{
      User:
        swagger_schema do
          title("User")
          description("A user of the application")

          properties do
            id(:ulid, "ULID of a user", required: false)
            activated(:boolean, "Has user confirmed their email?", required: false)
            activated_at(:utc_datetime, "Time when user confirmed their email", required: false)
            name(:string, "Name of user", required: true)
            username(:string, "Username registered", required: true)
            email(:string, "Email registered", required: true)
            role_name(:string, "Role of user", required: true)
            password(:string, "Password of user", required: true)
          end

          example(%{
            data: [
              %{
                id: "0921df04-cefc-11ed-bba2-32e44bcb0a53",
                activated: true,
                activated_at: "2023-03-30 13:10:52",
                name: "John Doe",
                username: "john_doe",
                email: "john@doe.com",
                role_name: "user",
                updated_at: "2023-03-30 13:10:52",
                inserted_at: "2023-03-30 13:10:52"
              }
            ]
          })
        end,
      Users:
        swagger_schema do
          title("Users")
          description("A collection of Users")
          type(:array)
          items(Schema.ref(:User))
        end
    }
  end
end
