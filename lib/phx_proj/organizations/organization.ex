defmodule PhxProj.Organizations.Organization do
  use PhxProj.Schema
  import Ecto.Changeset


schema "organizations" do
  field :name, :string
  field :status, :string
  field :address, :string
  field :description, :string

  belongs_to :user, PhxProj.Accounts.User
  has_many :members, PhxProj.Organizations.Member

  timestamps(type: :utc_datetime)
end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :address, :description, :status, :user_id])
    |> validate_required([:name, :address, :description, :status, :user_id])
  end
end
