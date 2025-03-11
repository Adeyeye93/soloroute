defmodule PhxProjWeb.OrganizationLive.InviteForm do
  use PhxProjWeb, :live_component

  alias PhxProj.Organizations
  alias PhxProj.Organizations.OrganizationInvitation

  def render(assigns) do
    ~H"""
    <div>
      <h1>Invite Form</h1>

      <form phx-submit="submit" phx-target={@myself}>
        <label for="email">Email:</label>
        <input type="email" id="email" name="email" value={@email} />
        <%= if @changeset.action do %>
          <div>
            <%= for {attr, msg} <- @changeset.errors do %>
              <p>{"#{attr} #{msg}"}</p>
            <% end %>
          </div>
        <% end %>
         <button type="submit">Invite</button>
      </form>
    </div>
    """
  end

  # Using mount/3 here. Adjust your organization-fetching logic as needed.
  def update(assigns, socket) do
    %{organization: organization} = assigns
    changeset = Organizations.change_invitation(%OrganizationInvitation{})
    {:ok,
     socket
     |> assign(assigns)
     |> assign(organization: organization)
     |> assign(email: "")
     |> assign(changeset: changeset)}
  end

def handle_event("submit", %{"email" => email}, socket) do
  inviter_id = socket.assigns.user_id
  %{organization: organization} = socket.assigns
  invitation_params = %{email: email, organization_id: organization.id, inviter_id: inviter_id}

  case Organizations.send_invitation(socket.assigns.organization, invitation_params) do
    {:ok, _result} ->
      socket = put_flash(socket, :info, "Invitation sent!")
      new_changeset = Organizations.change_invitation(%PhxProj.Organizations.OrganizationInvitation{})
      {:noreply, assign(socket, email: "", changeset: new_changeset)}

    {:error, changeset} ->
      socket = put_flash(socket, :info, "Invitation sent!")
      {:noreply, assign(socket, changeset: changeset)}
  end
end

end
