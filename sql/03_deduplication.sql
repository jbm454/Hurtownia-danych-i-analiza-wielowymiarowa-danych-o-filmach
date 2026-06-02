```sql
USE imdb;
GO

/* ============================================================
   03_deduplication.sql
   Deduplikacja filmów na podstawie kolumny id
   ============================================================ */

-- 1. Sprawdzenie liczby wszystkich rekordów i unikalnych filmów
SELECT 
    COUNT(*) AS liczba_rekordow,
    COUNT(DISTINCT id) AS liczba_unikalnych_filmow,
    COUNT(*) - COUNT(DISTINCT id) AS liczba_duplikatow
FROM staging_movies;
GO

-- 2. Przykład zastosowania ROW_NUMBER() do deduplikacji
WITH movies_unique AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY id
            ORDER BY release_date DESC, title
        ) AS rn
    FROM staging_movies
)
SELECT TOP 100 *
FROM movies_unique
WHERE rn = 1
ORDER BY id;
GO

-- 3. Podgląd rekordów, które zostałyby potraktowane jako duplikaty
WITH movies_unique AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY id
            ORDER BY release_date DESC, title
        ) AS rn
    FROM staging_movies
)
SELECT *
FROM movies_unique
WHERE rn > 1
ORDER BY id, rn;
GO

-- 4. Liczba rekordów po deduplikacji
WITH movies_unique AS (
    SELECT
        id,
        ROW_NUMBER() OVER (
            PARTITION BY id
            ORDER BY release_date DESC, title
        ) AS rn
    FROM staging_movies
)
SELECT 
    COUNT(*) AS liczba_rekordow_po_deduplikacji
FROM movies_unique
WHERE rn = 1;
GO

-- 5. Logika deduplikacji używana przy ładowaniu wymiaru dim_movie
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
)
SELECT
    source_id,
    title,
    original_title,
    runtime,
    overview,
    tagline
FROM movies_unique
WHERE rn = 1;
GO

-- 6. Logika deduplikacji używana przy ładowaniu tabeli faktów fact_movies
WITH movies_unique AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY id
            ORDER BY release_date DESC, title
        ) AS rn
    FROM staging_movies
)
SELECT
    id,
    title,
    release_date,
    original_language,
    status,
    budget,
    revenue,
    vote_average,
    vote_count,
    popularity
FROM movies_unique
WHERE rn = 1;
GO
```
