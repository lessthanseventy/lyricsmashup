defmodule LyricsmashupWeb.SongLive.SongComponent do
	use LyricsmashupWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="post">
      <div class="row">
      <div class="post-avatar">
      <%= img_tag(@song.img_url) %>
        </div>
        <div class="column">
          <div class="post-body" >
            <br />
            <%= live_redirect @song.title, to: Routes.song_show_path(@socket, :show, @id) %>
          </div>
        </div>
      </div>
      <div class="social-buttons">
        <div>
          <a href="#" phx-click="like" phx-target="<%= @myself %>">
          <i class="far fa-thumbs-up"></i> <%= @song.num_likes %>
           </a>
        </div>
        <div>
          <%= live_patch to: Routes.song_index_path(@socket, :edit, @id) do %>
            <i class="far fa-edit"></i>
          <% end %>
          <%= link to: "#", phx_click: "delete", phx_value_id: @id do %>
            <i class="far fa-trash-alt"></i>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("like", _, socket) do
    Lyricsmashup.Markov.inc_likes(socket.assigns.song)
	  {:noreply, socket}
  end

end

# <%= raw(@lyrics) %>
