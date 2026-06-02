# Hurtownia danych i analiza wielowymiarowa danych o filmach

Projekt wykonany w ramach przedmiotu Wielowymiarowa analiza danych. 

## Technologie

- SQL Server
- SSIS
- SSAS Multidimensional
- Data Mining
- Power BI

## Zakres projektu

Projekt obejmuje:
- import danych do tabeli stagingowej,
- procesy ETL w SSIS,
- budowę hurtowni danych,
- przygotowanie tabel KPI,
- utworzenie kostki OLAP,
- wykonanie modeli Data Mining,
- przygotowanie raportu Power BI.

## Model danych

Centralną tabelą hurtowni jest `fact_movies`. W projekcie wykorzystano wymiary:
`dim_date`, `dim_movie`, `dim_language`, `dim_status`, `dim_genre`, `dim_country`.

Relacje wiele-do-wielu obsługują tabele:
`bridge_movie_genre`, `bridge_movie_country`.

## Raport

Dokumentacja projektu znajduje się w folderze `dokumentacja/`.

Ze względu na rozmiar pliku dane źródłowe nie zostały dodane do repozytorium.
