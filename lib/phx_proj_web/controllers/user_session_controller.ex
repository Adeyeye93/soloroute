defmodule PhxProjWeb.UserSessionController do
  use PhxProjWeb, :controller

  alias PhxProj.Accounts
  alias PhxProjWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    # create(conn, params, "Account created successfully!")
    redirect_to_verification(conn, params)
  end

  def create(conn, %{"_action" => "verification_successful"}) do
    params = conn.private[:plug_session]["user_params"]
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, user_params, info) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/users/log_in")
    end
  end

  defp redirect_to_verification(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    user = Accounts.get_user_by_email_and_password(email, password)
    user_id = user.id
    user_params = Map.put(user_params, "id", user_id)

    conn
    |> put_session(:user_params, user_params)
    |> put_flash(:info, "Account created successfully! Please verify your email.")
    |> redirect(to: ~p"/users/register/verify")
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
