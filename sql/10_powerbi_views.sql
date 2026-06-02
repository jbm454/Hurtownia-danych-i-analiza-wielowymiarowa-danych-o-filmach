```sql
USE imdb;
GO

/* ============================================================
   10_powerbi_views.sql
   Widoki pomocnicze przygotowane do raportu Power BI

   W projekcie widok v_pbi_decomposition_movies został użyty
   do drzewa dekompozycji przychodów i zysku.

   Zakres analizy:
   - tylko filmy Released,
   - lata 1980–2025,
   - rok 2026 pominięty jako rok niepełny.
   ============================================================ */

---------------------------------------------------------------
-- 1. Widok do drzewa dekompozycji w Power BI
---------------------------------------------------------------

CREATE OR ALTER VIEW v_pbi_decomposition_movies AS
SELECT
    dd.[year],
    dl.language_code,
    ds.status_name,

    ISNULL(dg.genre_name, 'Brak danych') AS genre_name,
    ISNULL(dc.country_name, 'Brak danych') AS country_name,

    SUM(fm.revenue) AS suma_przychodu,
    SUM(fm.profit) AS suma_zysku,
    COUNT(DISTINCT fm.movie_id) AS liczba_filmow,

    AVG(CASE
            WHEN fm.vote_count > 0 THEN fm.vote_average
        END) AS srednia_ocena,

    COUNT(CASE
            WHEN fm.vote_count > 0 THEN 1
        END) AS liczba_ocenionych_filmow,

    AVG(fm.popularity) AS srednia_popularnosc

FROM fact_movies fm
JOIN dim_date dd
    ON fm.date_id = dd.date_id
JOIN dim_language dl
    ON fm.language_id = dl.language_id
JOIN dim_status ds
    ON fm.status_id = ds.status_id

LEFT JOIN bridge_movie_genre bmg
    ON fm.movie_id = bmg.movie_id
LEFT JOIN dim_genre dg
    ON bmg.genre_id = dg.genre_id

LEFT JOIN bridge_movie_country bmc
    ON fm.movie_id = bmc.movie_id
LEFT JOIN dim_country dc
    ON bmc.country_id = dc.country_id

WHERE ds.status_name = 'Released'
  AND dd.[year] BETWEEN 1980 AND 2025

GROUP BY
    dd.[year],
    dl.language_code,
    ds.status_name,
    ISNULL(dg.genre_name, 'Brak danych'),
    ISNULL(dc.country_name, 'Brak danych');
GO

---------------------------------------------------------------
-- 2. Kontrola liczby rekordów w widoku
---------------------------------------------------------------

SELECT
    COUNT(*) AS liczba_rekordow
FROM v_pbi_decomposition_movies;
GO

---------------------------------------------------------------
-- 3. Podgląd danych do dekompozycji przychodów
---------------------------------------------------------------

SELECT TOP 50
    [year],
    genre_name,
    language_code,
    country_name,
    suma_przychodu,
    suma_zysku,
    liczba_filmow,
    srednia_ocena,
    srednia_popularnosc
FROM v_pbi_decomposition_movies
ORDER BY suma_przychodu DESC;
GO

---------------------------------------------------------------
-- 4. Kontrola pustych wartości po zamianie na "Brak danych"
---------------------------------------------------------------

SELECT
    genre_name,
    country_name,
    COUNT(*) AS liczba_rekordow
FROM v_pbi_decomposition_movies
WHERE genre_name = 'Brak danych'
   OR country_name = 'Brak danych'
GROUP BY
    genre_name,
    country_name
ORDER BY liczba_rekordow DESC;
GO

---------------------------------------------------------------
-- 5. Agregacja kontrolna według roku
---------------------------------------------------------------

SELECT
    [year],
    SUM(suma_przychodu) AS suma_przychodu,
    SUM(suma_zysku) AS suma_zysku,
    SUM(liczba_filmow) AS liczba_filmow
FROM v_pbi_decomposition_movies
GROUP BY [year]
ORDER BY [year];
GO
```
