# Spotify Web API

Ce projet consiste en une application permettant d'interagir avec l'API Web de Spotify. Dans cet exemple, l'application récupère d'abord la liste des albums d'Orelsan, puis offre la possibilité de filtrer les singles et enfin de trier les albums en fonction de leur date de sortie.

### Fonctionnalités principales :
1. Récupération des albums d'Orelsan.
2. Filtrage des albums pour exclure les singles.
3. Tri des albums par date de parution, du plus récent au plus ancien.

### Tester l'application :
Pour tester les fonctionnalités, exécutez la commande suivante dans votre terminal :

#### Commande à exécuter :

```bash
iex -S mix 
SpotifyWebApi.list_albums                   (Fonctionnalité 1)
SpotifyWebApi.list_albums_without_singles   (Fonctionnalité 2)
SpotifyWebApi.list_albums_sorted_by_date    (Fonctionnalité 3)

"(pour les test)"
iex -S mix test 
TestSpotifyWebApi.test
