def get_token do
  credentials = Application.get_env(:spotify_web_api, :spotify_credentials)
  client_id = credentials[:client_id]
  client_secret = credentials[:client_secret]

  IO.inspect(client_id, label: "Client ID")
  IO.inspect(client_secret, label: "Client Secret")

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

      IO.inspect(token, label: "Access Token")
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
