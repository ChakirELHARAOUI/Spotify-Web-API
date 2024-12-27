defmodule SpotifyWebApi do
  @moduledoc """
  Documentation for `SpotifyWebApi`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> SpotifyWebApi.hello()
      :world

  """
  def hello do
    :world
  end

  def get_token do
    credentials = Application.get_env(:spotify_web_api, :spotify_credentials)
    client_id = credentials[:client_id]
    client_secret = credentials[:client_secret]

    #IO.inspect(client_id, label: "Client ID")
    #IO.inspect(client_secret, label: "Client Secret")

    url = "https://accounts.spotify.com/api/token"
    body = URI.encode_query(%{
      grant_type: "client_credentials"
    })

    headers = [
      {"Authorization", "Basic " <> Base.encode64("#{client_id}:#{client_secret}")},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        token = response_body
                |> Jason.decode!()
                |> Map.get("access_token")

        #IO.inspect(token, label: "Access Token")
        token  # Retourne le token

      {:ok, %HTTPoison.Response{status_code: status, body: response_body}} ->
        IO.puts("Erreur HTTP : #{status}")
        IO.puts("Message : #{response_body}")
        nil  # Retourne nil en cas d'erreur

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Erreur de requête : #{reason}")
        nil  # Retourne nil en cas d'erreur
    end
  end

  def get_list_albums_artist do

    artists_id = Application.get_env(:spotify_web_api, :spotify_id_artist)
    orlesan_id = artists_id[:orelsan_id]
    IO.inspect(orlesan_id, label: "Orlesan ID")

    token = get_token()
    #IO.inspect(token, label: "GET ALBUM | TOKEN")

    url = "https://api.spotify.com/v1/artists/#{orlesan_id}/albums"
    headers = [
      {"Authorization", "Bearer #{token}"}
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        albums = response_body
                 |> Jason.decode!()
                 |> Map.get("items", [])
                 |> Enum.map(fn album -> %{name: album["name"], release_date: album["release_date"]} end)
        #IO.inspect(albums, label: "Albums")
        albums
      {:ok, %HTTPoison.Response{status_code: status, body: response_body}} ->
        IO.puts("Erreur HTTP : #{status}")
        IO.puts("Message : #{response_body}")
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Erreur de requête : #{reason}")
    end
  end

  def get_list_albums_artist_without_single do

    artists_id = Application.get_env(:spotify_web_api, :spotify_id_artist)
    orlesan_id = artists_id[:orelsan_id]
    IO.inspect(orlesan_id, label: "Orlesan ID")

    token = get_token()
    #IO.inspect(token, label: "GET ALBUM | TOKEN")

    url = "https://api.spotify.com/v1/artists/#{orlesan_id}/albums?include_groups=album"
    headers = [
      {"Authorization", "Bearer #{token}"}
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        albums = response_body
                 |> Jason.decode!()
                 |> Map.get("items", [])
                 |> Enum.map(fn album -> %{name: album["name"], release_date: album["release_date"]} end)


        albums_displayed =
            albums
            |> Enum.map(& &1.name)


        IO.inspect(albums_displayed, label: "Noms albums")
        albums
      {:ok, %HTTPoison.Response{status_code: status, body: response_body}} ->
        IO.puts("Erreur HTTP : #{status}")
        IO.puts("Message : #{response_body}")
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Erreur de requête : #{reason}")
    end
  end

  def list_albums_sorted_by_date do
    albums = get_list_albums_artist_without_single()

    sorted_album_names =
      albums
      |> Enum.sort_by(fn album ->
        case Date.from_iso8601(album.release_date) do
          {:ok, date} -> date  #Convertir date
          {:error, _} -> ~D[9999-12-31]  # Si échec
        end
      end, {:desc, Date}) # Trier ordre décroissant
      #|> Enum.map(& &1.name) # Extraire uniquement les noms

    #IO.inspect(sorted_album_names, label: "Albums triés par date")
    sorted_album_names
  end

end
