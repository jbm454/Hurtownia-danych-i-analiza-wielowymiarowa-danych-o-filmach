```sql
USE imdb;
GO

/* ============================================================
   05_load_genres.sql
   Normalizacja gatunków filmowych
   Ładowanie dim_genre oraz bridge_movie_genre
   ============================================================ */

---------------------------------------------------------------
-- 1. Czyszczenie tabel związanych z gatunkami
--    Najpierw tabela bridge, ponieważ ma klucze obce
---------------------------------------------------------------

DELETE FROM bridge_movie_genre;
GO

DELETE FROM dim_genre;
GO

DBCC CHECKIDENT ('dim_genre', RESEED, 0);
GO

---------------------------------------------------------------
-- 2. Ładowanie wymiaru gatunku: dim_genre
--    Kolumna genres zawiera wartości wielowartościowe,
--    np. "Drama, Comedy, Romance"
---------------------------------------------------------------

INSERT INTO dim_genre (
    genre_name
)
SELECT DISTINCT
    LTRIM(RTRIM(value)) AS genre_name
FROM staging_movies
CROSS APPLY STRING_SPLIT(
    CASE
        WHEN genres IS NULL OR LTRIM(RTRIM(genres)) = ''
            THEN 'Unknown'
        ELSE genres
    END,
    ','
)
WHERE LTRIM(RTRIM(value)) <> '';
GO

---------------------------------------------------------------
-- 3. Ładowanie tabeli bridge: bridge_movie_genre
--    Relacja wiele-do-wielu: jeden film może mieć wiele gatunków
---------------------------------------------------------------

WITH movies_unique AS (
    SELECT
        id,
        genres,
        ROW_NUMBER() OVER (
            PARTITION BY id
            ORDER BY release_date DESC, title
        ) AS rn
    FROM staging_movies
    WHERE id IS NOT NULL
),
movie_genres AS (
    SELECT DISTINCT
        dm.movie_id,
        dg.genre_id
    FROM movies_unique mu
    JOIN dim_movie dm
        ON mu.id = dm.source_id
    CROSS APPLY STRING_SPLIT(
        CASE
            WHEN mu.genres IS NULL OR LTRIM(RTRIM(mu.genres)) = ''
                THEN 'Unknown'
            ELSE mu.genres
        END,
        ','
    ) AS split_genres
    JOIN dim_genre dg
        ON dg.genre_name = LTRIM(RTRIM(split_genres.value))
    WHERE mu.rn = 1
      AND LTRIM(RTRIM(split_genres.value)) <> ''
)
INSERT INTO bridge_movie_genre (
    movie_id,
    genre_id
)
SELECT
    movie_id,
    genre_id
FROM movie_genres;
GO

---------------------------------------------------------------
-- 4. Kontrola liczby rekordów
---------------------------------------------------------------

SELECT
    'dim_genre' AS tabela,
    COUNT(*) AS liczba_rekordow
FROM dim_genre

UNION ALL

SELECT
    'bridge_movie_genre' AS tabela,
    COUNT(*) AS liczba_rekordow
FROM bridge_movie_genre;
GO

---------------------------------------------------------------
-- 5. Podgląd przykładowych powiązań film - gatunek
---------------------------------------------------------------

SELECT TOP 50
    dm.source_id,
    dm.title,
    dg.genre_name
FROM bridge_movie_genre bmg
JOIN dim_movie dm
    ON bmg.movie_id = dm.movie_id
JOIN dim_genre dg
    ON bmg.genre_id = dg.genre_id
ORDER BY dm.source_id, dg.genre_name;
GO
```
