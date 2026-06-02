```sql
USE imdb;
GO

/* ============================================================
   02_source_data_checks.sql
   Sprawdzenie danych źródłowych w tabeli staging_movies
   ============================================================ */

-- 1. Podstawowy podgląd danych źródłowych
SELECT TOP 10 *
FROM staging_movies;
GO

-- 2. Liczba wszystkich rekordów oraz liczba unikalnych filmów po id
SELECT 
    COUNT(*) AS liczba_rekordow,
    COUNT(DISTINCT id) AS liczba_unikalnych_filmow
FROM staging_movies;
GO

-- 3. Liczba potencjalnych duplikatów
SELECT 
    COUNT(*) - COUNT(DISTINCT id) AS liczba_duplikatow
FROM staging_movies;
GO

-- 4. Identyfikatory filmów występujące więcej niż jeden raz
SELECT
    id,
    COUNT(*) AS liczba_wystapien
FROM staging_movies
GROUP BY id
HAVING COUNT(*) > 1
ORDER BY liczba_wystapien DESC, id;
GO

-- 5. Przykładowe rekordy dla zduplikowanych filmów
SELECT sm.*
FROM staging_movies sm
WHERE sm.id IN (
    SELECT id
    FROM staging_movies
    GROUP BY id
    HAVING COUNT(*) > 1
)
ORDER BY sm.id, sm.release_date DESC, sm.title;
GO

-- 6. Sprawdzenie braków w najważniejszych kolumnach
SELECT
    SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS brak_id,
    SUM(CASE WHEN title IS NULL OR LTRIM(RTRIM(title)) = '' THEN 1 ELSE 0 END) AS brak_title,
    SUM(CASE WHEN release_date IS NULL THEN 1 ELSE 0 END) AS brak_release_date,
    SUM(CASE WHEN original_language IS NULL OR LTRIM(RTRIM(original_language)) = '' THEN 1 ELSE 0 END) AS brak_original_language,
    SUM(CASE WHEN status IS NULL OR LTRIM(RTRIM(status)) = '' THEN 1 ELSE 0 END) AS brak_status,
    SUM(CASE WHEN genres IS NULL OR LTRIM(RTRIM(genres)) = '' THEN 1 ELSE 0 END) AS brak_genres,
    SUM(CASE WHEN production_countries IS NULL OR LTRIM(RTRIM(production_countries)) = '' THEN 1 ELSE 0 END) AS brak_production_countries
FROM staging_movies;
GO

-- 7. Zakres dat premier filmów
SELECT
    MIN(release_date) AS najstarsza_data,
    MAX(release_date) AS najnowsza_data
FROM staging_movies;
GO

-- 8. Liczba filmów według statusu
SELECT
    status,
    COUNT(*) AS liczba_filmow
FROM staging_movies
GROUP BY status
ORDER BY liczba_filmow DESC;
GO

-- 9. Liczba filmów według języka oryginalnego
SELECT TOP 20
    original_language,
    COUNT(*) AS liczba_filmow
FROM staging_movies
GROUP BY original_language
ORDER BY liczba_filmow DESC;
GO
```
