defmodule PhxProj.Accounts.UserNotifier do
  import Swoosh.Email

  alias PhxProj.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"PhxProj", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url, pin) do
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    Here is your verification code to confirm your account:

    #{pin}

    ========
    OR
    ========

    Confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end


  def deliver_invitation_email(email, url) do
    deliver(email, " You just got an Invitation", """
      Hi #{email},

      foollow this url to join the organization
      #{url}
    """)
  end
  def deliver_invitation_added_email(email, org_name) do
    deliver(email, " You just got an Invitation", """
      Sending notification email to #{email}
       that they have been added to #{org_name}
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset password instructions", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
