defmodule GaslightWeb.PostLive.PostComponent do
	use GaslightWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="post">
      <div class="row">
        <div class="post-avatar">
        </div>
        <div class="column">
          <em>@<%= @post.username %></em>
          <div class="post-body" >
            <br />
            <%= @post.body%>
          </div>
        </div>
      </div>
      <div class="social-buttons">
        <div>
          <a href="#" phx-click="like" phx-target="<%= @myself %>">
              <i class="far fa-heart"></i> <%= @post.num_likes %>
           </a>
        </div>
        <div>
          <a href="#" phx-click="repost" phx-target="<%= @myself %>">
            <i class="far fa-thumbs-up"></i> <%= @post.num_shares %>
          </a>
        </div>
        <div>
            <%= live_patch to: Routes.post_index_path(@socket, :edit, @post.id) do %>
              <i class="far fa-edit"></i>
            <% end %>
            <%= link to: "#", phx_click: "delete", phx_value_id: @post.id do %>
              <i class="far fa-trash-alt"></i>
            <% end %>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("like", _, socket) do
    Gaslight.Timeline.inc_likes(socket.assigns.post)
	  {:noreply, socket}
  end

  def handle_event("repost", _, socket) do
    Gaslight.Timeline.inc_reposts(socket.assigns.post)
	  {:noreply, socket}
  end

end
