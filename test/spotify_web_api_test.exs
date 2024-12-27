defmodule SpotifyWebApiTest do
  use ExUnit.Case
  doctest SpotifyWebApi

  test "greets the world" do
    assert SpotifyWebApi.hello() == :world
  end
end
