defmodule GaslightWeb.SongLive.Show do
  use GaslightWeb, :live_view

  alias Gaslight.Markov

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:song, Markov.get_song!(id))}
  end

  defp page_title(:show), do: "Show Song"
  defp page_title(:edit), do: "Edit Song"
end
