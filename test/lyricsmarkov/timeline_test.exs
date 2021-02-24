defmodule Phxtwit.TimelineTest do
  use Phxtwit.DataCase

  alias Phxtwit.Timeline

  describe "posts" do
    alias Phxtwit.Timeline.Post

    @valid_attrs %{body: "some body", num_likes: 42, num_shares: 42, username: "some username"}
    @update_attrs %{body: "some updated body", num_likes: 43, num_shares: 43, username: "some updated username"}
    @invalid_attrs %{body: nil, num_likes: nil, num_shares: nil, username: nil}

    def post_fixture(attrs \\ %{}) do
      {:ok, post} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Timeline.create_post()

      post
    end

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Timeline.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Timeline.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      assert {:ok, %Post{} = post} = Timeline.create_post(@valid_attrs)
      assert post.body == "some body"
      assert post.num_likes == 42
      assert post.num_shares == 42
      assert post.username == "some username"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      assert {:ok, %Post{} = post} = Timeline.update_post(post, @update_attrs)
      assert post.body == "some updated body"
      assert post.num_likes == 43
      assert post.num_shares == 43
      assert post.username == "some updated username"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_post(post, @invalid_attrs)
      assert post == Timeline.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Timeline.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Timeline.change_post(post)
    end
  end
end
