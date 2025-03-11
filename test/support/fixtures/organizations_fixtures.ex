defmodule PhxProj.OrganizationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PhxProj.Organizations` context.
  """

  @doc """
  Generate a organization.
  """
  def organization_fixture(attrs \\ %{}) do
    {:ok, organization} =
      attrs
      |> Enum.into(%{
        address: "some address",
        description: "some description",
        name: "some name",
        status: "some status"
      })
      |> PhxProj.Organizations.create_organization()

    organization
  end
end
