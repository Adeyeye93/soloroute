defmodule PhxProj.Repo.Migrations.CreateOrganizationInvitations do
  use Ecto.Migration

  def change do
    create table(:organization_invitations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :token, :string, null: false
      add :status, :string, null: false, default: "pending"
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all), null: false
      add :inviter_id, references(:users, type: :binary_id, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:organization_invitations, [:token])
  end
end
