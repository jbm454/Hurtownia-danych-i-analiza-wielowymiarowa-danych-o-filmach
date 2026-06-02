```sql
USE imdb;
GO

/* ============================================================
   04_load_dimensions.sql
   Ładowanie podstawowych wymiarów hurtowni danych
   ============================================================ */

---------------------------------------------------------------
-- 1. Ładowanie wymiaru daty: dim_date
---------------------------------------------------------------

INSERT INTO dim_date (
    full_date,
    [year],
    [month],
    [day],
    [quarter]
)
SELECT DISTINCT
    CAST(release_date AS DATE) AS full_date,
    YEAR(release_date) AS [year],
    MONTH(release_date) AS [month],
    DAY(release_date) AS [day],
    DATEPART(QUARTER, release_date) AS [quarter]
FROM staging_movies
WHERE release_date IS NOT NULL
  AND NOT EXISTS (
        SELECT 1
        FROM dim_date dd
        WHERE dd.full_date = CAST(staging_movies.release_date AS DATE)
  );
GO

---------------------------------------------------------------
-- 2. Ładowanie wymiaru języka: dim_language
---------------------------------------------------------------

INSERT INTO dim_language (
    language_code,
    language_name
)
SELECT DISTINCT
    LTRIM(RTRIM(original_language)) AS language_code,
    LTRIM(RTRIM(original_language)) AS language_name
FROM staging_movies sm
WHERE original_language IS NOT NULL
  AND LTRIM(RTRIM(original_language)) <> ''
  AND NOT EXISTS (
        SELECT 1
        FROM dim_language dl
        WHERE dl.language_code = LTRIM(RTRIM(sm.original_language))
  );
GO

---------------------------------------------------------------
-- 3. Ładowanie wymiaru statusu filmu: dim_status
---------------------------------------------------------------

INSERT INTO dim_status (
    status_name
)
SELECT DISTINCT
    LTRIM(RTRIM(status)) AS status_name
FROM staging_movies sm
WHERE status IS NOT NULL
  AND LTRIM(RTRIM(status)) <> ''
  AND NOT EXISTS (
        SELECT 1
        FROM dim_status ds
        WHERE ds.status_name = LTRIM(RTRIM(sm.status))
  );
GO

---------------------------------------------------------------
-- 4. Ładowanie wymiaru filmu: dim_movie
--    Deduplikacja po oryginalnym id filmu
---------------------------------------------------------------

WITH movies_unique AS (
    SELECT
        id AS source_id,
        title,
        original_title,
        runtime,
        overview,
        tagline,
        ROW_NUMBER() OVER (
            PARTITION BY id
            ORDER BY release_date DESC, title
        ) AS rn
    FROM staging_movies
    WHERE id IS NOT NULL
)
INSERT INTO dim_movie (
    source_id,
    title,
    original_title,
    runtime,
    overview,
    tagline
)
SELECT
    source_id,
    title,
    original_title,
    runtime,
    overview,
    tagline
FROM movies_unique mu
WHERE rn = 1
  AND NOT EXISTS (
        SELECT 1
        FROM dim_movie dm
        WHERE dm.source_id = mu.source_id
  );
GO

---------------------------------------------------------------
-- 5. Kontrola liczby rekordów w wymiarach
---------------------------------------------------------------

SELECT 'dim_date' AS tabela, COUNT(*) AS liczba_rekordow
FROM dim_date

UNION ALL

SELECT 'dim_language' AS tabela, COUNT(*) AS liczba_rekordow
FROM dim_language

UNION ALL

SELECT 'dim_status' AS tabela, COUNT(*) AS liczba_rekordow
FROM dim_status

UNION ALL

SELECT 'dim_movie' AS tabela, COUNT(*) AS liczba_rekordow
FROM dim_movie;
GO
```
