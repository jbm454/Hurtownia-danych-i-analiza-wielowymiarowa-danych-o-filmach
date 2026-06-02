```sql
USE imdb;
GO

/* ============================================================
   08_kpi_tables.sql
   Tworzenie i ładowanie tabel KPI

   Tabele KPI:
   - kpi_movies_by_year
   - kpi_finance_by_year
   - kpi_movies_by_genre
   - kpi_movies_by_country

   Uwaga:
   Rok 2026 został pominięty, ponieważ jest rokiem niepełnym
   i mógłby zaburzać analizy czasowe oraz prognozy.
   
   Średnia ocena jest liczona tylko dla filmów z vote_count > 0,
   żeby filmy bez ocen nie zaniżały wyniku.
   ============================================================ */

---------------------------------------------------------------
-- 1. Usunięcie wcześniejszych tabel KPI
---------------------------------------------------------------

DROP TABLE IF EXISTS kpi_movies_by_year;
DROP TABLE IF EXISTS kpi_finance_by_year;
DROP TABLE IF EXISTS kpi_movies_by_genre;
DROP TABLE IF EXISTS kpi_movies_by_country;
GO

---------------------------------------------------------------
-- 2. Parametry zakresu lat
---------------------------------------------------------------

DECLARE @min_year INT = 1888;
DECLARE @max_year INT = 2025;

---------------------------------------------------------------
-- 3. KPI: liczba filmów, średnia ocena i popularność według roku
---------------------------------------------------------------

SELECT
    dd.[year] AS rok,
    COUNT(DISTINCT fm.movie_id) AS liczba_filmow,
    AVG(CASE 
            WHEN fm.vote_count > 0 THEN fm.vote_average 
        END) AS srednia_ocena,
    COUNT(CASE 
            WHEN fm.vote_count > 0 THEN 1 
        END) AS liczba_ocenionych_filmow,
    AVG(fm.popularity) AS srednia_popularnosc
INTO kpi_movies_by_year
FROM fact_movies fm
JOIN dim_date dd
    ON fm.date_id = dd.date_id
JOIN dim_status ds
    ON fm.status_id = ds.status_id
WHERE ds.status_name = 'Released'
  AND dd.[year] BETWEEN @min_year AND @max_year
GROUP BY dd.[year];

---------------------------------------------------------------
-- 4. KPI: budżet, przychód i zysk według roku
---------------------------------------------------------------

SELECT
    dd.[year] AS rok,
    COUNT(DISTINCT fm.movie_id) AS liczba_filmow,
    SUM(fm.budget) AS suma_budzetu,
    SUM(fm.revenue) AS suma_przychodu,
    SUM(fm.profit) AS suma_zysku,
    AVG(fm.profit) AS sredni_zysk
INTO kpi_finance_by_year
FROM fact_movies fm
JOIN dim_date dd
    ON fm.date_id = dd.date_id
JOIN dim_status ds
    ON fm.status_id = ds.status_id
WHERE ds.status_name = 'Released'
  AND dd.[year] BETWEEN @min_year AND @max_year
  AND fm.budget > 0
  AND fm.revenue > 0
GROUP BY dd.[year];

---------------------------------------------------------------
-- 5. KPI: analiza filmów według gatunku
---------------------------------------------------------------

SELECT
    dg.genre_name,
    COUNT(DISTINCT fm.movie_id) AS liczba_filmow,
    AVG(CASE 
            WHEN fm.vote_count > 0 THEN fm.vote_average 
        END) AS srednia_ocena,
    COUNT(CASE 
            WHEN fm.vote_count > 0 THEN 1 
        END) AS liczba_ocenionych_filmow,
    AVG(fm.popularity) AS srednia_popularnosc,
    COUNT(CASE 
            WHEN fm.revenue > 0 THEN 1 
        END) AS liczba_filmow_z_przychodem
INTO kpi_movies_by_genre
FROM fact_movies fm
JOIN bridge_movie_genre bmg
    ON fm.movie_id = bmg.movie_id
JOIN dim_genre dg
    ON bmg.genre_id = dg.genre_id
JOIN dim_status ds
    ON fm.status_id = ds.status_id
JOIN dim_date dd
    ON fm.date_id = dd.date_id
WHERE ds.status_name = 'Released'
  AND dd.[year] BETWEEN @min_year AND @max_year
GROUP BY dg.genre_name;

---------------------------------------------------------------
-- 6. KPI: analiza filmów według kraju produkcji
---------------------------------------------------------------

SELECT
    dc.country_name,
    COUNT(DISTINCT fm.movie_id) AS liczba_filmow,
    AVG(CASE 
            WHEN fm.vote_count > 0 THEN fm.vote_average 
        END) AS srednia_ocena,
    COUNT(CASE 
            WHEN fm.vote_count > 0 THEN 1 
        END) AS liczba_ocenionych_filmow,
    AVG(fm.popularity) AS srednia_popularnosc,
    SUM(fm.revenue) AS suma_przychodu
INTO kpi_movies_by_country
FROM fact_movies fm
JOIN bridge_movie_country bmc
    ON fm.movie_id = bmc.movie_id
JOIN dim_country dc
    ON bmc.country_id = dc.country_id
JOIN dim_status ds
    ON fm.status_id = ds.status_id
JOIN dim_date dd
    ON fm.date_id = dd.date_id
WHERE ds.status_name = 'Released'
  AND dd.[year] BETWEEN @min_year AND @max_year
GROUP BY dc.country_name
HAVING SUM(fm.revenue) > 0;

---------------------------------------------------------------
-- 7. Kontrola liczby rekordów w tabelach KPI
---------------------------------------------------------------

SELECT 'kpi_movies_by_year' AS tabela, COUNT(*) AS liczba_rekordow
FROM kpi_movies_by_year

UNION ALL

SELECT 'kpi_finance_by_year' AS tabela, COUNT(*) AS liczba_rekordow
FROM kpi_finance_by_year

UNION ALL

SELECT 'kpi_movies_by_genre' AS tabela, COUNT(*) AS liczba_rekordow
FROM kpi_movies_by_genre

UNION ALL

SELECT 'kpi_movies_by_country' AS tabela, COUNT(*) AS liczba_rekordow
FROM kpi_movies_by_country;

---------------------------------------------------------------
-- 8. Podgląd przykładowych wyników KPI
---------------------------------------------------------------

SELECT TOP 20 *
FROM kpi_movies_by_year
ORDER BY rok;

SELECT TOP 20 *
FROM kpi_finance_by_year
ORDER BY rok;

SELECT TOP 20 *
FROM kpi_movies_by_genre
ORDER BY liczba_filmow DESC;

SELECT TOP 20 *
FROM kpi_movies_by_country
ORDER BY suma_przychodu DESC;
GO
```
