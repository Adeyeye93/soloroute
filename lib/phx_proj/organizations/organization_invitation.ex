defmodule PhxProj.Organizations.OrganizationInvitation do
  use PhxProj.Schema
  import Ecto.Changeset

  schema "organization_invitations" do
    field :email, :string
    field :token, :string
    field :status, :string, default: "pending"  # pending, accepted, declined
    belongs_to :organization, PhxProj.Organizations.Organization, type: :binary_id
    belongs_to :inviter, PhxProj.Accounts.User, type: :binary_id

    timestamps()
  end

  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:email, :token, :status, :organization_id, :inviter_id])
    |> validate_required([:email, :token, :organization_id, :inviter_id])
    |> unique_constraint(:token)
  end
end

