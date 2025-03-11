defmodule PhxProj.Organizations.Member do
  use PhxProj.Schema
  import Ecto.Changeset

  schema "members" do
    field :role, :string

    belongs_to :organization, PhxProj.Organizations.Organization, type: :binary_id
    belongs_to :user, PhxProj.Accounts.User, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:role, :organization_id, :user_id])
    |> validate_required([:role, :organization_id, :user_id])
  end
end


