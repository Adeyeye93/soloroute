defmodule PhxProj.OrganizationsTest do
  use PhxProj.DataCase

  alias PhxProj.Organizations

  describe "organizations" do
    alias PhxProj.Organizations.Organization

    import PhxProj.OrganizationsFixtures

    @invalid_attrs %{name: nil, status: nil, address: nil, description: nil}

    test "list_organizations/0 returns all organizations" do
      organization = organization_fixture()
      assert Organizations.list_organizations() == [organization]
    end

    test "get_organization!/1 returns the organization with given id" do
      organization = organization_fixture()
      assert Organizations.get_organization!(organization.id) == organization
    end

    test "create_organization/1 with valid data creates a organization" do
      valid_attrs = %{name: "some name", status: "some status", address: "some address", description: "some description"}

      assert {:ok, %Organization{} = organization} = Organizations.create_organization(valid_attrs)
      assert organization.name == "some name"
      assert organization.status == "some status"
      assert organization.address == "some address"
      assert organization.description == "some description"
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organizations.create_organization(@invalid_attrs)
    end

    test "update_organization/2 with valid data updates the organization" do
      organization = organization_fixture()
      update_attrs = %{name: "some updated name", status: "some updated status", address: "some updated address", description: "some updated description"}

      assert {:ok, %Organization{} = organization} = Organizations.update_organization(organization, update_attrs)
      assert organization.name == "some updated name"
      assert organization.status == "some updated status"
      assert organization.address == "some updated address"
      assert organization.description == "some updated description"
    end

    test "update_organization/2 with invalid data returns error changeset" do
      organization = organization_fixture()
      assert {:error, %Ecto.Changeset{}} = Organizations.update_organization(organization, @invalid_attrs)
      assert organization == Organizations.get_organization!(organization.id)
    end

    test "delete_organization/1 deletes the organization" do
      organization = organization_fixture()
      assert {:ok, %Organization{}} = Organizations.delete_organization(organization)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_organization!(organization.id) end
    end

    test "change_organization/1 returns a organization changeset" do
      organization = organization_fixture()
      assert %Ecto.Changeset{} = Organizations.change_organization(organization)
    end
  end
end
