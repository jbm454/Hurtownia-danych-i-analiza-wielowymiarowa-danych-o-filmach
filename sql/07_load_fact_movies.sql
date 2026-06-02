```sql
USE imdb;
GO

/* ============================================================
   07_load_fact_movies.sql
   Ładowanie tabeli faktów fact_movies

   Tabela faktów jest zasilana danymi z tabeli staging_movies
   po połączeniu z wymiarami:
   - dim_movie
   - dim_date
   - dim_language
   - dim_status

   W ładowaniu zastosowano deduplikację po id filmu.
   ============================================================ */

---------------------------------------------------------------
-- 1. Czyszczenie tabeli faktów
---------------------------------------------------------------

DELETE FROM fact_movies;
GO

DBCC CHECKIDENT ('fact_movies', RESEED, 0);
GO

---------------------------------------------------------------
-- 2. Ładowanie tabeli faktów fact_movies
--    Deduplikacja: ROW_NUMBER() po id filmu
---------------------------------------------------------------

WITH movies_unique AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY id
            ORDER BY release_date DESC, title
        ) AS rn
    FROM staging_movies
    WHERE id IS NOT NULL
)
INSERT INTO fact_movies (
    movie_id,
    date_id,
    language_id,
    status_id,
    budget,
    revenue,
    vote_average,
    vote_count,
    popularity
)
SELECT
    dm.movie_id,
    dd.date_id,
    dl.language_id,
    ds.status_id,
    sm.budget,
    sm.revenue,
    sm.vote_average,
    sm.vote_count,
    sm.popularity
FROM movies_unique sm
JOIN dim_movie dm
    ON sm.id = dm.source_id
JOIN dim_date dd
    ON CAST(sm.release_date AS DATE) = dd.full_date
JOIN dim_language dl
    ON LTRIM(RTRIM(sm.original_language)) = dl.language_code
JOIN dim_status ds
    ON LTRIM(RTRIM(sm.status)) = ds.status_name
WHERE sm.rn = 1;
GO

---------------------------------------------------------------
-- 3. Kontrola liczby rekordów w tabeli faktów
---------------------------------------------------------------

SELECT
    COUNT(*) AS liczba_rekordow_fact_movies
FROM fact_movies;
GO

---------------------------------------------------------------
-- 4. Podgląd przykładowych rekordów tabeli faktów
---------------------------------------------------------------

SELECT TOP 50
    fm.fact_id,
    dm.source_id,
    dm.title,
    dd.full_date,
    dd.[year],
    dl.language_code,
    ds.status_name,
    fm.budget,
    fm.revenue,
    fm.profit,
    fm.vote_average,
    fm.vote_count,
    fm.popularity
FROM fact_movies fm
JOIN dim_movie dm
    ON fm.movie_id = dm.movie_id
JOIN dim_date dd
    ON fm.date_id = dd.date_id
JOIN dim_language dl
    ON fm.language_id = dl.language_id
JOIN dim_status ds
    ON fm.status_id = ds.status_id
ORDER BY fm.fact_id;
GO

---------------------------------------------------------------
-- 5. Kontrola podstawowych wartości finansowych
---------------------------------------------------------------

SELECT
    COUNT(*) AS liczba_filmow,
    SUM(budget) AS suma_budzetu,
    SUM(revenue) AS suma_przychodu,
    SUM(profit) AS suma_zysku,
    AVG(CASE 
            WHEN vote_count > 0 THEN vote_average 
        END) AS srednia_ocena_dla_ocenionych_filmow
FROM fact_movies;
GO
```
