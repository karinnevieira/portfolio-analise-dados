--Todas as consultas utilizadas no projeto SPOTIFY

----------------------NULOS---------------------------------
--Consulta da quantidade de valores nulos na tabela Spotify
SELECT  
COUNTIF(track_id IS NULL)            AS nulos_track_id,
COUNTIF(track_name IS NULL)          AS nulos_track_name,
COUNTIF(artists_name IS NULL)        AS nulos_artists_name,
COUNTIF(artist_count IS NULL)        AS nulos_artist_countmain_music_genre,
COUNTIF(main_music_genre IS NULL)    AS nulos_main_music_genre,
COUNTIF(main_country IS NULL)        AS nulos_main_country,
COUNTIF(released_year IS NULL)       AS nulos_released_year,
COUNTIF(released_month IS NULL)      AS nulos_released_month,
COUNTIF(released_day IS NULL)        AS nulos_released_day,
COUNTIF(in_spotify_playlists IS NULL) AS nulos_in_spotify_playlists,
COUNTIF(in_spotify_charts IS NULL)   AS nulos_in_spotify_charts,
COUNTIF(streams IS NULL)             AS nulos_streams
FROM `projeto-spotify-494213.spotify_musicas.Copia_de_track_in_spotify_ativa_BR`

--Consulta da quantidade de valores nulos na tabela Concorrentes
SELECT
COUNTIF(track_id IS NULL)                AS nulos_track_id,
COUNTIF(in_apple_playlists IS NULL)      AS nulos_in_apple_playlists,
COUNTIF(in_apple_charts IS NULL)         AS nulos_in_apple_charts,
COUNTIF(in_deezer_playlists IS NULL)     AS nulos_in_deezer_playlists,
COUNTIF(in_deezer_charts IS NULL)        AS nulos_in_deezer_charts,
COUNTIF(in_shazam_charts IS NULL)       AS nulos_in_shazam_charts
FROM `projeto-spotify-494213.spotify_musicas.Copia de track_in_competition _ativa_BR`

--Consulta da posição dos valores nulos na tabela Spotify
SELECT *
FROM `projeto-spotify-494213.spotify_musicas.Copia_de_track_in_spotify_ativa_BR`
WHERE
  track_id IS NULL
  OR track_name IS NULL
  OR artists_name IS NULL
  OR artist_count IS NULL
  OR main_music_genre IS NULL
  OR main_country IS NULL
  OR released_year IS NULL
  OR released_month IS NULL
  OR released_day IS NULL
  OR in_spotify_playlists IS NULL
  OR in_spotify_charts IS NULL
  OR streams IS NULL

  --Criando uma nova tabela sem os valores nulos encontrados
CREATE TABLE `projeto-spotify-494213.spotify_musicas.sem_nulos_track_in_spotify_ativa_BR` AS
SELECT * EXCEPT(main_music_genre, main_country),
COALESCE(main_music_genre, 'Pop') AS main_music_genre_new,
COALESCE(main_country, 'United States') AS main_country_new
FROM `projeto-spotify-494213.spotify_musicas.Copia_de_track_in_spotify_ativa_BR`


-------------------DUPLICADOS----------------------
--Consulta mais restrita para encontrar os valores duplicados por track_id, track_name, artists_name e released_day na tabela principal do Spotify
SELECT track_id,track_name, artists_name, released_day,  COUNT(*) AS total
FROM `projeto-spotify-494213.spotify_musicas.Copia_de_track_in_spotify_ativa_BR`
GROUP BY track_id, track_name, artists_name, released_day
HAVING total>1

--Consulta mais geral para encontrar os duplicados por track_name e artists_name na tabela principal do Spotify (Essa consulta também retira espaços em branco entre as palavras e torna as letras minúsculas)
SELECT *
FROM (
 SELECT
   t.*,
   COUNT(*) OVER (
     PARTITION BY
       LOWER(TRIM(track_name)),
       LOWER(TRIM(artists_name))
   ) AS qtd
FROM `projeto-spotify-494213.spotify_musicas.sem_nulos_track_in_spotify_ativa_BR` t
) x
WHERE qtd > 1

--Deletou a linha mais recente da música About Damn Time da tabela principal do Spotify
DELETE FROM `projeto-spotify-494213.spotify_musicas.sem_duplicados1_track_in_spotify_ativa_BR`
WHERE track_id = 5080031

--Consultar dados duplicados na tabela da concorrência
SELECT track_id,  COUNT(*) AS total
FROM `projeto-spotify-494213.spotify_musicas.Copia de track_in_competition _ativa_BR`
GROUP BY track_id
HAVING total>1

-------------VALORES ATIPICOS VARIAVEIS CATEGORICAS------------

--Consulta usada para conhecer os valores atípicos da variável categórica main_country da tabela principal do Spotify
SELECT DISTINCT main_country_new
FROM `projeto-spotify-494213.spotify_musicas.sem_duplicados1_track_in_spotify_ativa_BR`
ORDER BY main_country_new

--Consulta para criar uma nova tabela padronizada da tabela principal do Spotify
CREATE TABLE `projeto-spotify-494213.spotify_musicas.padronizado_categoricas_track_in_spotify_ativa_BR` AS


SELECT * EXCEPT (main_country_new),
  CASE main_country_new
    WHEN 'USA' THEN 'United States'
    WHEN 'PR'  THEN 'Puerto Rico'
    WHEN 'MX'  THEN 'Mexico'
    ELSE main_country_new
  END AS main_country_new
FROM `projeto-spotify-494213.spotify_musicas.sem_duplicados1_track_in_spotify_ativa_BR`

-------------VALORES ATIPICOS VARIAVEIS NUMERICAS------------

--Consulta para conhecer os valores atípicos (extremos) da variável numérica streams da tabela principal do Spotify
SELECT
 MAX(streams) AS streams_max,
 AVG(streams) AS streams_avg,
 MIN(streams) AS streams_min
FROM `projeto-spotify-494213.spotify_musicas.padronizado_categoricas_track_in_spotify_ativa_BR`

--Consulta para conhecer valores negativos na variável streams da tabela principal do Spotify
SELECT *
FROM `projeto-spotify-494213.spotify_musicas.padronizado_categoricas_track_in_spotify_ativa_BR`
WHERE streams < 0

--Consulta atualizando o valor negativo da variável streams pelo valor de streams obtido da plataforma do Spotify da tabela principal do Spotify
UPDATE  `projeto-spotify-494213.spotify_musicas.padronizado_categoricas_track_in_spotify_ativa_BR`
SET streams = 377878327
WHERE track_id = 4061483

--Consulta para converter valores numéricos armazenados como texto da tabela principal do Spotify  sem quebrar a consulta (SAFE_CAST)
CREATE TABLE `projeto-spotify-494213.spotify_musicas.padronizado_numericas_track_in_spotify_ativa_BR` AS


SELECT * EXCEPT (streams),
  SAFE_CAST(streams AS INT64) AS streams
FROM `projeto-spotify-494213.spotify_musicas.padronizado_categoricas_track_in_spotify_ativa_BR`

--Consulta para ver valores atípicos numéricos na tabela dos concorrentes
SELECT
 MAX(in_shazam_charts) AS in_shazam_charts_max,
 AVG(in_shazam_charts) AS in_shazam_charts_avg,
 MIN(in_shazam_charts) AS in_shazam_charts_playlists_min
FROM `projeto-spotify-494213.spotify_musicas.Copia de track_in_competition _ativa_BR`

--Consulta para converter valores numéricos armazenados como string na tabela dos concorrentes
CREATE TABLE `projeto-spotify-494213.spotify_musicas.padronizada_track_in_competition _ativa_BR` AS


SELECT * EXCEPT (in_apple_playlists, in_apple_charts, in_deezer_playlists, in_deezer_charts, in_shazam_charts),
SAFE_CAST(in_apple_playlists AS INT64)   AS in_apple_playlists,
SAFE_CAST(in_apple_charts AS INT64)      AS in_apple_charts,
SAFE_CAST(in_deezer_playlists AS INT64)  AS in_deezer_playlists,
SAFE_CAST(in_deezer_charts AS INT64)     AS in_deezer_charts,
SAFE_CAST(in_shazam_charts AS INT64)     AS in_shazam_charts
FROM `projeto-spotify-494213.spotify_musicas.Copia de track_in_competition _ativa_BR`

----------------CONVERTENDO TIPOS DE DADOS----------------

--Convertendo tipo de dados numéricos para categóricos e categóricos para numéricos
CREATE TABLE `projeto-spotify-494213.spotify_musicas.all_track_in_spotify_ativa_BR` AS
SELECT * EXCEPT(track_id, in_spotify_playlists),
SAFE_CAST(track_id AS STRING) AS track_id,
SAFE_CAST(in_spotify_playlists AS INT64) AS in_spotify_playlists
FROM `projeto-spotify-494213.spotify_musicas.padronizado_numericas_track_in_spotify_ativa_BR`

--Consultas para mudar valor nulo gerado na conversão dos dados (foi tomado o valor médio da variável in_spotify_playlists)

------Verificando o valor médio
SELECT  
AVG(in_spotify_playlists) AS media_in_spotify_playlists
FROM `projeto-spotify-494213.spotify_musicas.all_track_in_spotify_ativa_BR`

------Substituindo
UPDATE
  `projeto-spotify-494213.spotify_musicas.all_track_in_spotify_ativa_BR`
SET in_spotify_playlists = 5546
WHERE track_id = '4061483'

------------JOIN-------------
--Consulta para juntar os dados das duas tabelas
CREATE TABLE `projeto-spotify-494213.spotify_musicas.all_tracks` AS
SELECT
 a.*,
 b.* EXCEPT (track_id)
FROM `projeto-spotify-494213.spotify_musicas.all_track_in_spotify_ativa_BR` AS a
LEFT JOIN `projeto-spotify-494213.spotify_musicas.padronizada_track_in_competition _ativa_BR`AS b
ON a.track_id = b.track_id

----------CONVERTENDO AS TRÊS COLUNAS COM INFORMACOES DE DATAS EM UMA ÚNICA FORMATADA-----------
CREATE TABLE `projeto-spotify-494213.spotify_musicas.all_tracks_date` AS
SELECT
  DATE(released_year, released_month, released_day) AS date,
  * EXCEPT(released_year, released_month, released_day)
FROM `projeto-spotify-494213.spotify_musicas.all_tracks`

-------------CORRELACOES CALCULADAS-------------
--Charts Shazam x streams
SELECT 
CORR(in_shazam_charts, streams) AS corr_shazam_charts_streams
FROM `projeto-spotify-494213.spotify_musicas.all_table`

--Playlists Spotify x Streams
SELECT 
CORR(in_spotify_playlists, streams) AS corr_in_spotify_playlists_streams
FROM `projeto-spotify-494213.spotify_musicas.all_tracks` 

--Charts Spotify x Charts Deezer
SELECT 
CORR(in_spotify_charts, in_deezer_charts) AS corr_charts_spotify_deezer
FROM `projeto-spotify-494213.spotify_musicas.all_table`

--Charts Spotify x Charts Apple
SELECT
CORR(in_spotify_charts, in_apple_charts) AS corr_charts_spotify_apple
FROM `projeto-spotify-494213.spotify_musicas.all_table`

--Charts Deezer x Charts Apple
SELECT 
CORR(in_deezer_charts, in_apple_charts) AS corr_charts_deezer_apple
FROM `projeto-spotify-494213.spotify_musicas.all_table`

----------------Quantidade de artistas na música para ter sucesso----------------------
SELECT
 COUNT(track_id) AS qtd_musicas,
 artist_count,
 AVG(streams) AS media_streams,
 AVG(in_spotify_charts) AS media_charts
FROM `projeto-spotify-494213.spotify_musicas.all_table` 
GROUP BY artist_count
ORDER BY media_charts DESC