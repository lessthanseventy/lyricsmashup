defmodule GaslightWeb.SongLive.SongComponent do
	use GaslightWeb, :live_component

  # def render(assigns) do
  #   ~L"""
  #   <div class="post">
  #     <%= live_redirect @title, to: Routes.song_show_path(@socket, :show, @id) %>
  #   </div>
  #   """
  # end
  def render(assigns) do
    ~L"""
    <div class="post">
      <div class="row">
      <div class="post-avatar" style="background-image:url('https://picsum.photos/200')">
        </div>
        <div class="column">
          <div class="post-body" >
            <br />
            <%= live_redirect @title, to: Routes.song_show_path(@socket, :show, @id) %>
          </div>
        </div>
      </div>
      <div class="social-buttons">
        <div>
          <a href="#" phx-click="like" phx-target="<%= @myself %>">
          <i class="far fa-thumbs-up"></i> <%= @num_likes %>
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
    Gaslight.Markov.inc_likes(socket.assigns.song)
	  {:noreply, socket}
  end

end

# <%= raw(@lyrics) %>
