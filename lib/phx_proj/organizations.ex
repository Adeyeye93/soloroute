defmodule PhxProj.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias PhxProj.Repo


  import Ecto.Changeset
  alias PhxProj.Organizations.{Organization, OrganizationInvitation}
  alias PhxProj.Accounts.User

  @doc """
  Returns the list of organizations.

  ## Examples

      iex> list_organizations()
      [%Organization{}, ...]

  """
  def list_organizations do
    Repo.all(Organization)
  end

  @doc """
  Returns the list of organizations for a specific user.

  ## Examples

      iex> list_organizations(123)
      [%Organization{}, ...]

  """
  def list_organizations(user_id) do
    Organization
    |> join(:left, [o], m in assoc(o, :members))
    |> where([o, m], o.user_id == ^user_id or m.id == ^user_id)
    |> distinct([o], o.id)
    |> Repo.all()
  end

  @doc """
  Gets a single organization.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization!(123)
      %Organization{}

      iex> get_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_organization!(id), do: Repo.get!(Organization, id)

  @doc """
  Creates a organization.

  ## Examples

      iex> create_organization(%{field: value})
      {:ok, %Organization{}}

      iex> create_organization(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_organization(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a organization.

  ## Examples

      iex> update_organization(organization, %{field: new_value})
      {:ok, %Organization{}}

      iex> update_organization(organization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a organization.

  ## Examples

      iex> delete_organization(organization)
      {:ok, %Organization{}}

      iex> delete_organization(organization)
      {:error, %Ecto.Changeset{}}

  """
  def delete_organization(%Organization{} = organization) do
    Repo.delete(organization)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organization changes.

  ## Examples

      iex> change_organization(organization)
      %Ecto.Changeset{data: %Organization{}}

  """
  def change_organization(%Organization{} = organization, attrs \\ %{}) do
    Organization.changeset(organization, attrs)
  end

  def change_invitation(%OrganizationInvitation{} = invitation, attrs \\ %{}) do
    OrganizationInvitation.changeset(invitation, attrs)
  end

  # defmodule PhxProj.Organizations.OrganizationInvitation do
  #   use Ecto.Schema
  #   import Ecto.Changeset

  #   schema "organization_invitations" do
  #     field :email, :string
  #     field :organization_id, :id
  #     timestamps()
  #   end

  #   @doc false
  #   def changeset(invitation, attrs) do
  #     invitation
  #     |> cast(attrs, [:email, :organization_id])
  #     |> validate_required([:email, :organization_id])
  #     |> validate_format(:email, ~r/@/)
  #     |> unique_constraint(:email, name: :unique_email_per_organization, message: "This email has already been invited to the organization.")
  #   end
  # end

  # def send_invitation(%Organization{} = org, %{email: email} = invitation_params) do
  #   case Repo.get_by(PhxProj.Accounts.User, email: email) do
  #     nil ->
  #       # User not found, create an invitation record (or handle accordingly)
  #       %PhxProj.Organizations.OrganizationInvitation{}
  #       |> PhxProj.Organizations.OrganizationInvitation.changeset(invitation_params)
  #       |> Ecto.Changeset.put_change(:organization_id, org.id)
  #       |> Repo.insert()
  #     user ->
  #       # If user exists, add them as a member
  #       org = Repo.preload(org, :members)
  #       updated_members = [user | org.members]
  #       org
  #       |> Ecto.Changeset.change()
  #       |> Ecto.Changeset.put_assoc(:members, updated_members)
  #       |> Repo.update()
  #   end


  @doc """
  Sends an invitation for the given organization. If a user with the given email exists,
  they are added as a member and a notification email is sent.
  Otherwise, an invitation record is created with a generated token and an invitation
  email is sent.

  Expects `invitation_params` to include at least:
    - email: the invitee's email,
    - inviter_id: the current user's id sending the invite.
  """


  def send_invitation(
        %Organization{} = org,
        %{email: email, inviter_id: inviter_id} = invitation_params
      ) do
    case Repo.get_by(User, email: email) do
      nil ->
        # User not found, so create an invitation record.
        token = generate_token()

        # Merge the generated token into the params.
        invitation_params = Map.put(invitation_params, :token, token)

        invitation_changeset =
          %OrganizationInvitation{}
          |> OrganizationInvitation.changeset(invitation_params)
          |> put_change(:organization_id, org.id)
          |> put_change(:inviter_id, inviter_id)

        case Repo.insert(invitation_changeset) do
          {:ok, invitation} ->
            send_invitation_email(email, invitation)
            {:ok, invitation}

          {:error, changeset} ->
            {:error, changeset}
        end

      user ->
        # User exists, so add them as a member.
        org = Repo.preload(org, :members)

        # Optionally, check if the user is already a member.
        if Enum.any?(org.members, &(&1.id == user.id)) do
          {:error, :already_member}
        else
          updated_members = org.members ++ [%PhxProj.Organizations.Member{user_id: user.id}]

          org_changeset =
            org
            |> change()
            |> put_assoc(:members, updated_members)

          case Repo.update(org_changeset) do
            {:ok, updated_org} ->
              send_member_notification_email(email, updated_org)
              {:ok, updated_org}

            {:error, changeset} ->
              {:error, changeset}
          end
        end
    end
  end

  # Generates a random token to be used for the invitation.
  defp generate_token do
    :crypto.strong_rand_bytes(16)
    |> Base.url_encode64(padding: false)
    |> binary_part(0, 22)
  end

  # Stub function: implement your email sending logic here.
  defp send_invitation_email(email, %OrganizationInvitation{token: token}) do
    # For example, using Bamboo or Swoosh.
    PhxProj.Accounts.UserNotifier.deliver_invitation_email(email, token)
    {:ok, token}
  end

  # Stub function: implement your member notification email logic here.
  defp send_member_notification_email(email, %Organization{name: org_name}) do
    PhxProj.Accounts.UserNotifier.deliver_invitation_added_email(email, org_name)
    {:ok, org_name}
  end
end
