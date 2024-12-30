defmodule SpotifyWebApi do
  @moduledoc """
  Module pour interagir avec l'API Spotify et récupérer les informations sur les albums d'Orelsan.
  """

  @base_url "https://api.spotify.com/v1"

  # Fonction qui retourne la liste des noms d'albums d'Orelsan.
  def list_albums do
    get_albums()
    |> extract_album_names()
  end

  # Fonction qui retourne la liste des noms d'albums d'Orelsan, mais exclut les singles.
  def list_albums_without_singles do
    get_albums("?include_groups=album")
    |> extract_album_names()
  end

  # Fonction qui retourne la liste des albums d'Orelsan triés par date de sortie du plus récent, avec leurs dates.
  def list_albums_sorted_by_date do
    get_albums()
    |> sort_albums_by_date()
    |> extract_album_names_and_dates()
  end

  # Fonction interne pour récupérer les albums d'Orelsan via l'API Spotify.
  # Elle prend un paramètre optionnel pour ajuster la requête (par exemple, inclure uniquement les albums).
  def get_albums(query_params \\ "") do
    token = get_token()          # Récupère le token d'authentification.
    artist_id = get_orlesan_id()  # Récupère l'ID Spotify de l'artiste Orelsan.
    url = "#{@base_url}/artists/#{artist_id}/albums#{query_params}"
    headers = [{"Authorization", "Bearer #{token}"}]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{body: body}} ->
        parse_albums(body)  # Parse la réponse pour extraire les informations des albums.
      {:error, _reason} ->
        []  # Retourne une liste vide en cas d'erreur.
    end
  end

  # Fonction interne pour récupérer le token d'authentification de l'API Spotify.
  def get_token do
    credentials = Application.get_env(:spotify_web_api, :spotify_credentials)
    client_id = credentials[:client_id]
    client_secret = credentials[:client_secret]

    url = "https://accounts.spotify.com/api/token"
    body = URI.encode_query(%{grant_type: "client_credentials"})
    headers = [
      {"Authorization", "Basic " <> Base.encode64("#{client_id}:#{client_secret}")},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{body: body}} ->
        Jason.decode!(body)["access_token"]  # Récupère le token dans la réponse.
      {:error, _reason} ->
        nil  # Retourne nil en cas d'erreur.
    end
  end

  # Fonction interne pour récupérer l'ID Spotify de l'artiste Orelsan à partir des configurations.
  def get_orlesan_id do
    Application.get_env(:spotify_web_api, :spotify_id_artist)[:orelsan_id]
  end

  # Fonction interne pour parser la réponse JSON contenant les albums et en extraire le nom et la date de sortie.
  def parse_albums(response_body) do
    Jason.decode!(response_body)
    |> Map.get("items", [])  # Récupère la liste des albums dans la réponse.
    |> Enum.map(&%{"name" => &1["name"], "release_date" => &1["release_date"]})  # Extrait les informations nécessaires.
  end

  # Fonction qui extrait seulement les noms des albums à partir de la liste des albums.
  def extract_album_names(albums) do
    Enum.map(albums, & &1["name"])  # Retourne une liste uniquement avec des noms d'albums.
  end

  # Fonction qui trie les albums par date de sortie, du plus récent au plus ancien.
  def sort_albums_by_date(albums) do
    Enum.sort_by(albums, & &1["release_date"], :desc)  # Trie par date de sortie dans l'ordre décroissant.
  end

  # Fonction qui extrait les noms et dates de sortie des albums.
  def extract_album_names_and_dates(albums) do
    Enum.map(albums, fn album -> {album["name"], album["release_date"]} end)  # Retourne une liste de tuples (nom, date).
  end
end
