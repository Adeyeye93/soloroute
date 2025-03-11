defmodule PhxProjWeb.OrganizationLive.Show do
  use PhxProjWeb, :live_view

  alias PhxProj.Organizations

  @impl true
  def mount(_params, _session, socket) do
    %{current_user: %{id: user_id}} = socket.assigns

    {:ok, socket |> assign(:user_id, user_id)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:organization, Organizations.get_organization!(id))}
  end

  defp page_title(:show), do: "Show Organization"
  defp page_title(:edit), do: "Edit Organization"
  defp page_title(:invite), do: "invite to Organization"
end
