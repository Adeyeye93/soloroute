defmodule PhxProjWeb.OrganizationLive.Index do
  use PhxProjWeb, :live_view

  alias PhxProj.Organizations
  alias PhxProj.Organizations.Organization

  @impl true
  def mount(_params, _session, socket) do
    %{current_user: %{id: user_id}} = socket.assigns
    socket =
      socket
      |> assign(user_Key: user_id)
      |> stream(:organizations, Organizations.list_organizations(user_id))
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Organization")
    |> assign(:organization, Organizations.get_organization!(id))
  end

  defp apply_action(socket, :new, _params) do
    %{current_user: %{id: user_id}} = socket.assigns
    socket
    |> assign(:page_title, "New Organization")
    |> assign(:organization, %Organization{})
    |> assign(:user_Key, user_id)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Organizations")
    |> assign(:organization, nil)
  end

  @impl true
  def handle_info({PhxProjWeb.OrganizationLive.FormComponent, {:saved, organization}}, socket) do
    {:noreply, stream_insert(socket, :organizations, organization)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    organization = Organizations.get_organization!(id)
    {:ok, _} = Organizations.delete_organization(organization)

    {:noreply, stream_delete(socket, :organizations, organization)}
  end
end
