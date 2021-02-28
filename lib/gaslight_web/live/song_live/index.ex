defmodule GaslightWeb.SongLive.Index do
  use GaslightWeb, :live_view

  alias Gaslight.Markov
  alias Gaslight.Markov.Song
  alias Gaslight.Repo
  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :songs, list_songs())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"" => id}) do
    socket
    |> assign(:page_title, "Edit Song")
    |> assign(:song, Markov.get_song!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Song")
    |> assign(:song, %Song{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Song Generator")
    |> assign(:song, nil)
  end

  defp apply_action(socket, :list, _params) do
    socket
    |> assign(:page_title, "Songs")
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    song = Markov.get_song!(id)
    {:ok, _} = Markov.delete_song(song)

    {:noreply, assign(socket, :songs, list_songs())}
  end

  def handle_event("bandError", _params, socket) do
    {:noreply,
     socket
     |> put_flash(:error, "Band not found. Try Again")}
  end

  def handle_event("saveSong", params, socket) do
    IO.inspect(params, [])
    %Song{}
    |> Song.changeset(params)
    |> Repo.insert()
  end

  defp list_songs do
    Markov.list_songs()
  end

end
