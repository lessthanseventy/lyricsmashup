defmodule GaslightWeb.SongLive.Index do
  use GaslightWeb, :live_view

  alias Gaslight.Markov
  alias Gaslight.Markov.Song
  alias Gaslight.Repo
  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Markov.subscribe()
    {:ok, assign(socket, :songs, list_songs()), temporary_assigns: [songs: []]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
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
    case Markov.create_song(params) do
      {:ok, _song} ->
        {:noreply,
         socket
         |> put_flash(:info, "Song Saved Successfully")
         |> push_redirect(to: "/new")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def handle_info({:song_created, song}, socket) do
    {:noreply, update(socket, :songs, fn songs -> [song | songs] end)}
  end

  def handle_info({:song_updated, song}, socket) do
    IO.inspect(socket, [])
    {:noreply, update(socket, :songs, fn songs -> [song | songs] end)}
  end

  def handle_info({:song_deleted, _song}, socket) do
    {:noreply, update(socket, :songs, fn songs -> [songs] end)}
  end

  defp list_songs do
    Markov.list_songs()
  end

end
