defmodule Match.Password do
  import Bcrypt, only: [hash_pwd_salt: 1, verify_pass: 2, no_user_verify: 0]

  def hash(password) do
    hash_pwd_salt(password)
  end

  def verify(password, hash) do
    verify_pass(password, hash)
  end

  def dummy_verify, do: no_user_verify()
end
