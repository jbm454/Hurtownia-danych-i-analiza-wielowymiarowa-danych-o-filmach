```sql
USE imdb;
GO

/* ============================================================
   06_load_countries.sql
   Przygotowanie krajów produkcji oraz ładowanie bridge_movie_country

   Uwaga:
   Standaryzacja błędnych nazw krajów była wykonywana w SSIS
   przy użyciu Lookup oraz Fuzzy Lookup.
   ============================================================ */

---------------------------------------------------------------
-- 1. Czyszczenie tabeli bridge
---------------------------------------------------------------

DELETE FROM bridge_movie_country;
GO

---------------------------------------------------------------
-- 2. Ładowanie wymiaru kraju: dim_country
--    Kolumna production_countries może zawierać wiele krajów
--    oddzielonych przecinkami.
---------------------------------------------------------------

INSERT INTO dim_country (
    country_name
)
SELECT DISTINCT
    LTRIM(RTRIM(value)) AS country_name
FROM staging_movies
CROSS APPLY STRING_SPLIT(
    CASE
        WHEN production_countries IS NULL 
          OR LTRIM(RTRIM(production_countries)) = ''
            THEN 'Brak danych'
        ELSE production_countries
    END,
    ','
)
WHERE LTRIM(RTRIM(value)) <> ''
  AND NOT EXISTS (
        SELECT 1
        FROM dim_country dc
        WHERE dc.country_name = LTRIM(RTRIM(value))
  );
GO

---------------------------------------------------------------
-- 3. Ładowanie tabeli bridge: bridge_movie_country
--    Relacja wiele-do-wielu: jeden film może mieć wiele krajów
--    produkcji.
---------------------------------------------------------------

WITH movies_unique AS (
    SELECT
        id,
        production_countries,
        ROW_NUMBER() OVER (
            PARTITION BY id
            ORDER BY release_date DESC, title
        ) AS rn
    FROM staging_movies
    WHERE id IS NOT NULL
),
movie_countries AS (
    SELECT DISTINCT
        dm.movie_id,
        dc.country_id
    FROM movies_unique mu
    JOIN dim_movie dm
        ON mu.id = dm.source_id
    CROSS APPLY STRING_SPLIT(
        CASE
            WHEN mu.production_countries IS NULL 
              OR LTRIM(RTRIM(mu.production_countries)) = ''
                THEN 'Brak danych'
            ELSE mu.production_countries
        END,
        ','
    ) AS split_countries
    JOIN dim_country dc
        ON dc.country_name = LTRIM(RTRIM(split_countries.value))
    WHERE mu.rn = 1
      AND LTRIM(RTRIM(split_countries.value)) <> ''
)
INSERT INTO bridge_movie_country (
    movie_id,
    country_id
)
SELECT
    movie_id,
    country_id
FROM movie_countries;
GO

---------------------------------------------------------------
-- 4. Przykładowa tabela testowa do Fuzzy Lookup w SSIS
--    W projekcie nie psuto głównej tabeli krajów, tylko użyto
--    pomocniczych błędnych nazw do testu dopasowania.
---------------------------------------------------------------

DROP TABLE IF EXISTS country_dirty_test;
GO

CREATE TABLE country_dirty_test (
    dirty_country_name NVARCHAR(200)
);
GO

INSERT INTO country_dirty_test (dirty_country_name)
VALUES
    ('United Stats of America'),
    ('United Kingdm'),
    ('Soth Korea'),
    ('Canda');
GO

---------------------------------------------------------------
-- 5. Kontrola liczby rekordów
---------------------------------------------------------------

SELECT
    'dim_country' AS tabela,
    COUNT(*) AS liczba_rekordow
FROM dim_country

UNION ALL

SELECT
    'bridge_movie_country' AS tabela,
    COUNT(*) AS liczba_rekordow
FROM bridge_movie_country;
GO

---------------------------------------------------------------
-- 6. Podgląd przykładowych powiązań film - kraj
---------------------------------------------------------------

SELECT TOP 50
    dm.source_id,
    dm.title,
    dc.country_name
FROM bridge_movie_country bmc
JOIN dim_movie dm
    ON bmc.movie_id = dm.movie_id
JOIN dim_country dc
    ON bmc.country_id = dc.country_id
ORDER BY dm.source_id, dc.country_name;
GO
```
