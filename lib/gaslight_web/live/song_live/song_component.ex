defmodule GaslightWeb.SongLive.SongComponent do
	use GaslightWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="post">
      <%= live_redirect @title, to: Routes.song_show_path(@socket, :show, @id) %>
    </div>
    """
  end
end

# <%= raw(@lyrics) %>
