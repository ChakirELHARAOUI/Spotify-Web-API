defmodule TestSpotifyWebApi do
  def test do
    IO.puts("Testing list_albums...")
    IO.inspect(SpotifyWebApi.list_albums())

    IO.puts("\nTesting list_albums_without_singles...")
    IO.inspect(SpotifyWebApi.list_albums_without_singles())

    IO.puts("\nTesting list_albums_sorted_by_date...")
    IO.inspect(SpotifyWebApi.list_albums_sorted_by_date())
  end
end
