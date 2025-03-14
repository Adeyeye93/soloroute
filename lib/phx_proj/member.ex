defmodule PhxProj.Member do
  import Ecto.Query, warn: false
  alias PhxProj.Repo
  alias PhxProj.Organizations.Member
  # alias PhxProj.Organizations.Organization

  def list_all_organisation_members(organisation_id) do
  Repo.all(from m in Member, where: m.organization_id == ^organisation_id)
  end
end
