defmodule PhxProjWeb.PinVerificationLive do
  use PhxProjWeb, :live_view
  alias PhxProj.Accounts.DigitVerification
  alias PhxProj.Accounts



  def mount(_params, %{"user_params" => param}, socket) do
    {:ok, assign(socket, %{pin: "", auth: param, message: "", trigger_submit: false,})}
  end

  def handle_event("verify_pin", %{"pin" => pin}, socket) do
    %{"id" => id } = socket.assigns.auth
    case DigitVerification.confirm_pin(id, pin) do
      :correct ->
        Accounts.confirm_user(id)
        {:noreply, socket |> assign(:message, "PIN verified!") |> assign(:trigger_submit, true)}
      :incorrect ->
        {:noreply, assign(socket, :message, "Incorrect PIN!")}
      :expired ->
        {:noreply, socket |> assign(:message, "PIN expired!")}
      :not_found ->
        {:noreply, socket |> assign(:message, "User not found!")}
    end
  end


  def handle_params(_params, _url, socket) do
    csrf_token = Plug.CSRFProtection.get_csrf_token()
    {:noreply, assign(socket, :csrf_token, csrf_token)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Verify PIN</h1>
      <form
      phx-submit="verify_pin"
      phx-trigger-action={@trigger_submit}
      action={~p"/users/log_in?_action=verification_successful"}
      method="post"
      >
        <input type="text" name="pin" value={@pin} placeholder="Enter PIN" />
        <input type="hidden" name="_csrf_token" value={@csrf_token} />
        <button type="submit">Verify</button>
      </form>
      <p><%= @message %></p>
    </div>
    """
  end
end
