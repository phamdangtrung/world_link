defmodule WorldLink.Identity.UserToken do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Query
  alias WorldLink.Accounts.UserToken

  @hash_algorithm :sha512
  @rand_size 64

  # It is very important to keep the reset password token expiry short,
  # since someone with access to the email may take over the account.
  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7
  @change_email_validity_in_days 7
  @session_validity_in_days 60
end
