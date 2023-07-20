defmodule Support.Factories.IdentityFactory do
  @moduledoc """
  Factory for generating Identity' schemas
  """

  use ExMachina.Ecto, repo: WorldLink.Repo
  alias WorldLink.Identity.{OauthProfile, User}

  @seconds_per_day 86_400
  @rand_range 0..1_000
  @supported_providers OauthProfile.supported_providers()

  def user_factory(attrs) do
    email = sequence(:email, &"email-#{&1}@email.com")
    username = sequence(:username, &"username#{&1}")

    %User{
      name: Faker.Person.name(),
      email: email |> String.downcase(),
      normalized_email: email |> String.downcase(),
      username: username,
      normalized_username: username,
      role_name: :user,
      password: "testPassword@123"
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def confirm_account(user) do
    random_number = Enum.random(@rand_range)
    days_ago = -random_number * @seconds_per_day

    activated_date =
      DateTime.utc_now() |> DateTime.add(days_ago, :second) |> DateTime.truncate(:millisecond)

    %{user | activated: true, activated_at: activated_date}
  end

  def make_admin(user) do
    %{user | role_name: :admin}
  end

  def add_oauth(user) do
    build(:oauth, %{user: user})
  end

  def oauth_factory(attrs) do
    %OauthProfile{
      provider_uid: Faker.Internet.user_name(),
      oauth_provider: @supported_providers |> Enum.random()
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  def user_params_factory(%{excluded_fields: excluded_fields}) do
    user_params()
    |> nullify_fields(excluded_fields)
  end

  def user_params_factory(attrs) do
    user_params()
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end

  defp user_params() do
    email = sequence(:email, &"email-#{&1}@email.com")
    username = sequence("username")

    %{
      name: Faker.Person.name(),
      email: email |> String.downcase(),
      normalized_email: email |> String.downcase(),
      username: username,
      normalized_username: username,
      role_name: :user,
      password: "testPassword@123"
    }
  end

  defp nullify_fields(map, [head | tail]) do
    Map.put(map, head, nil)
    |> nullify_fields(tail)
  end

  defp nullify_fields(map, []), do: map
end
