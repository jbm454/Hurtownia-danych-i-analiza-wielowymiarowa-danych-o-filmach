```sql
USE imdb;
GO

/* ============================================================
   09_data_mining_views.sql
   Widoki danych przygotowane do modeli Data Mining

   Modele:
   - Microsoft Clustering
   - Microsoft Decision Trees
   - Microsoft Linear Regression
   - Microsoft Naive Bayes

   Uwaga:
   Rok 2026 został pominięty, ponieważ jest rokiem niepełnym
   i mógłby zaburzać analizy.
   ============================================================ */

---------------------------------------------------------------
-- 1. Widok do Microsoft Clustering
--    Cel: grupowanie filmów na podstawie podobnych cech
---------------------------------------------------------------

CREATE OR ALTER VIEW v_mining_movies_clustering AS
SELECT
    fm.fact_id,
    ISNULL(fm.budget, 0) AS budget,
    ISNULL(fm.revenue, 0) AS revenue,
    ISNULL(fm.profit, 0) AS profit,
    ISNULL(fm.vote_average, 0) AS vote_average,
    ISNULL(fm.vote_count, 0) AS vote_count,
    ISNULL(fm.popularity, 0) AS popularity,
    dd.[year],
    dl.language_code
FROM fact_movies fm
JOIN dim_date dd
    ON fm.date_id = dd.date_id
JOIN dim_language dl
    ON fm.language_id = dl.language_id
JOIN dim_status ds
    ON fm.status_id = ds.status_id
WHERE ds.status_name = 'Released'
  AND dd.[year] BETWEEN 1888 AND 2025;
GO

---------------------------------------------------------------
-- 2. Widok do Microsoft Decision Trees
--    Cel: klasyfikacja kategorii popularności filmu
--
--    Zmienna wynikowa:
--    popularity_category = Niska / Srednia / Wysoka
--
--    Uwaga:
--    Kolumna popularity służy wyłącznie do utworzenia kategorii.
--    Nie powinna być ustawiana jako Input w modelu,
--    żeby model nie otrzymał gotowej odpowiedzi.
---------------------------------------------------------------

CREATE OR ALTER VIEW v_mining_movies_popularity_tree AS
SELECT
    fm.fact_id,
    ISNULL(fm.budget, 0) AS budget,
    ISNULL(fm.revenue, 0) AS revenue,
    ISNULL(fm.profit, 0) AS profit,
    ISNULL(fm.vote_average, 0) AS vote_average,
    ISNULL(fm.vote_count, 0) AS vote_count,
    dd.[year],
    dl.language_code,
    CASE
        WHEN ISNULL(fm.popularity, 0) < 5 THEN 'Niska'
        WHEN ISNULL(fm.popularity, 0) < 20 THEN 'Srednia'
        ELSE 'Wysoka'
    END AS popularity_category
FROM fact_movies fm
JOIN dim_date dd
    ON fm.date_id = dd.date_id
JOIN dim_language dl
    ON fm.language_id = dl.language_id
JOIN dim_status ds
    ON fm.status_id = ds.status_id
WHERE ds.status_name = 'Released'
  AND dd.[year] BETWEEN 1888 AND 2025;
GO

---------------------------------------------------------------
-- 3. Widok do Microsoft Linear Regression
--    Cel: predykcja przychodu filmu
--
--    Dane ograniczono do filmów z dodatnim budżetem i przychodem,
--    aby model był budowany na pełniejszych danych finansowych.
---------------------------------------------------------------

CREATE OR ALTER VIEW v_mining_movies_revenue_regression AS
SELECT
    fm.fact_id,
    fm.budget,
    fm.revenue,
    fm.vote_average,
    fm.vote_count,
    fm.popularity,
    dm.runtime,
    dd.[year]
FROM fact_movies fm
JOIN dim_movie dm
    ON fm.movie_id = dm.movie_id
JOIN dim_date dd
    ON fm.date_id = dd.date_id
JOIN dim_status ds
    ON fm.status_id = ds.status_id
WHERE ds.status_name = 'Released'
  AND dd.[year] BETWEEN 1888 AND 2025
  AND fm.budget > 0
  AND fm.revenue > 0;
GO

---------------------------------------------------------------
-- 4. Widok do Microsoft Naive Bayes
--    Cel: klasyfikacja kategorii oceny filmu
--
--    Zmienna wynikowa:
--    rating_category = Niska / Srednia / Wysoka
--
--    Uwaga:
--    Kolumna vote_average służy wyłącznie do utworzenia kategorii.
--    Nie powinna być ustawiana jako Input w modelu,
--    żeby model nie otrzymał gotowej odpowiedzi.
---------------------------------------------------------------

CREATE OR ALTER VIEW v_mining_movies_rating_bayes AS
SELECT
    fm.fact_id,
    ISNULL(fm.budget, 0) AS budget,
    ISNULL(fm.revenue, 0) AS revenue,
    ISNULL(fm.profit, 0) AS profit,
    ISNULL(fm.vote_count, 0) AS vote_count,
    ISNULL(fm.popularity, 0) AS popularity,
    dd.[year],
    dl.language_code,
    CASE
        WHEN ISNULL(fm.vote_average, 0) < 4 THEN 'Niska'
        WHEN ISNULL(fm.vote_average, 0) < 7 THEN 'Srednia'
        ELSE 'Wysoka'
    END AS rating_category
FROM fact_movies fm
JOIN dim_date dd
    ON fm.date_id = dd.date_id
JOIN dim_language dl
    ON fm.language_id = dl.language_id
JOIN dim_status ds
    ON fm.status_id = ds.status_id
WHERE ds.status_name = 'Released'
  AND dd.[year] BETWEEN 1888 AND 2025
  AND fm.vote_count > 0;
GO

---------------------------------------------------------------
-- 5. Kontrola liczby rekordów w widokach Data Mining
---------------------------------------------------------------

SELECT 'v_mining_movies_clustering' AS widok, COUNT(*) AS liczba_rekordow
FROM v_mining_movies_clustering

UNION ALL

SELECT 'v_mining_movies_popularity_tree' AS widok, COUNT(*) AS liczba_rekordow
FROM v_mining_movies_popularity_tree

UNION ALL

SELECT 'v_mining_movies_revenue_regression' AS widok, COUNT(*) AS liczba_rekordow
FROM v_mining_movies_revenue_regression

UNION ALL

SELECT 'v_mining_movies_rating_bayes' AS widok, COUNT(*) AS liczba_rekordow
FROM v_mining_movies_rating_bayes;
GO

---------------------------------------------------------------
-- 6. Kontrola rozkładu kategorii popularności
---------------------------------------------------------------

SELECT
    popularity_category,
    COUNT(*) AS liczba_filmow
FROM v_mining_movies_popularity_tree
GROUP BY popularity_category
ORDER BY liczba_filmow DESC;
GO

---------------------------------------------------------------
-- 7. Kontrola rozkładu kategorii ocen
---------------------------------------------------------------

SELECT
    rating_category,
    COUNT(*) AS liczba_filmow
FROM v_mining_movies_rating_bayes
GROUP BY rating_category
ORDER BY liczba_filmow DESC;
GO
```
