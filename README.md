# Hurtownia danych i analiza wielowymiarowa danych o filmach

Projekt wykonany w ramach przedmiotu **Wielowymiarowa analiza danych**.

## Opis projektu

Celem projektu było przygotowanie hurtowni danych oraz przeprowadzenie analizy wielowymiarowej danych o filmach. Projekt obejmuje pełny proces analityczny: od importu danych źródłowych, przez procesy ETL i budowę hurtowni danych, aż po kostkę OLAP, modele Data Mining oraz raport końcowy w Power BI.

Dane źródłowe zostały zaimportowane do bazy `imdb` do tabeli `staging_movies`. Po przygotowaniu danych utworzono model hurtowni danych oparty na tabeli faktów `fact_movies`, wymiarach oraz tabelach pośrednich obsługujących relacje wiele-do-wielu.

## Technologie

W projekcie wykorzystano:

* Microsoft SQL Server,
* SQL Server Management Studio,
* SQL Server Integration Services,
* SQL Server Analysis Services Multidimensional,
* SQL Server Data Mining,
* Visual Studio / SSDT,
* Power BI.

## Zakres projektu

Projekt obejmuje:

* import danych do tabeli stagingowej,
* deduplikację danych filmowych,
* budowę hurtowni danych,
* przygotowanie procesów ETL w SSIS,
* normalizację gatunków filmowych,
* standaryzację krajów produkcji z użyciem Lookup i Fuzzy Lookup,
* przygotowanie tabel KPI,
* utworzenie kostki OLAP w SSAS,
* przygotowanie formalnych wskaźników KPI w kostce,
* wykonanie modeli Data Mining,
* przygotowanie raportu Power BI.

## Model hurtowni danych

Centralną tabelą modelu jest:

* `fact_movies`

W projekcie wykorzystano następujące wymiary:

* `dim_date`,
* `dim_movie`,
* `dim_language`,
* `dim_status`,
* `dim_genre`,
* `dim_country`.

Relacje wiele-do-wielu zostały obsłużone przez tabele bridge:

* `bridge_movie_genre`,
* `bridge_movie_country`.

## Procesy ETL

W projekcie przygotowano pięć paczek SSIS:

* `Package1_Staging.dtsx` — import danych do tabeli stagingowej i ładowanie podstawowych wymiarów,
* `Package3_Genres.dtsx` — normalizacja gatunków filmowych,
* `Package4_Countries_FuzzyLookup.dtsx` — standaryzacja krajów produkcji z użyciem Lookup i Fuzzy Lookup,
* `Package5_FactMovies.dtsx` — ładowanie tabeli faktów,
* `Package6_KPI.dtsx` — przygotowanie tabel KPI.

## Kostka OLAP

W projekcie utworzono kostkę:

* `OLAP_176774_Movies`

Kostka zawierała m.in. następujące miary:

* `Budget`,
* `Revenue`,
* `Profit`,
* `Vote Average`,
* `Vote Count`,
* `Popularity`,
* `Fact Movies Count`.

Dodatkowo utworzono hierarchię daty:

```text
Year → Quarter → Month → Day → Full Date
```

W kostce przygotowano także miary obliczane, m.in. średni przychód na film oraz rentowność.

## KPI

W projekcie przygotowano tabele KPI oraz formalne wskaźniki KPI w kostce SSAS.

Przykładowe KPI:

* `KPI_Przychody_vs_Budzet`,
* `KPI_Zysk_Filmow`,
* `KPI_Rentownosc`,
* `KPI_Sredni_Przychod_Na_Film`.

## Data Mining

W projekcie wykonano cztery modele Data Mining:

* Microsoft Clustering,
* Microsoft Decision Trees,
* Microsoft Linear Regression,
* Microsoft Naive Bayes.

Modele zostały wykorzystane m.in. do grupowania filmów, klasyfikacji popularności, predykcji przychodów oraz klasyfikacji kategorii ocen.

## Raport Power BI

Raport Power BI składa się z czterech stron:

1. Dashboard filmów IMDb,
2. Analiza finansowa filmów w latach 1980–2025,
3. Analiza filmów według gatunków i krajów,
4. Trend, prognoza i dekompozycja danych filmowych.

Raport wykorzystuje dane z kostki OLAP oraz z tabel KPI przygotowanych w bazie `imdb`.

## Dane źródłowe

Pełny plik CSV z danymi źródłowymi nie został dodany do repozytorium ze względu na duży rozmiar. Dane źródłowe obejmowały około **1 087 995 rekordów**.

Po deduplikacji liczba unikalnych filmów wynosiła **1 087 812**.

Aby odtworzyć projekt lokalnie, należy samodzielnie dodać plik źródłowy CSV i zaimportować go do tabeli `staging_movies` w bazie `imdb`.

## Struktura repozytorium

```text
.
├── dokumentacja/
│   └── WAD_Projekt.pdf
│
├── sql/
│   ├── 01_create_warehouse_tables.sql
│   ├── 02_source_data_checks.sql
│   ├── 03_deduplication.sql
│   ├── 04_load_dimensions.sql
│   ├── 05_load_genres.sql
│   ├── 06_load_countries.sql
│   ├── 07_load_fact_movies.sql
│   ├── 08_kpi_tables.sql
│   ├── 09_data_mining_views.sql
│   └── 10_powerbi_views.sql
│
├── ssis/
│   └── packages/
│
├── ssas/
│   └── 176774_OLAP_Multi/
│
├── powerbi/
│   └── raport_powerbi.pbix
│
└── screenshots/
```

## Uwaga dotycząca środowiska

Projekt był realizowany w lokalnym środowisku SQL Server. Pliki SSIS i SSAS mogą zawierać lokalne ścieżki oraz nazwę lokalnego serwera, np.:

```text
DESKTOP-IFD8LT5\WAD
```

Przed uruchomieniem projektu na innym komputerze należy dostosować connection stringi, ścieżki do plików oraz nazwę serwera do własnego środowiska.

## Dokumentacja

Pełny opis projektu wraz ze screenami znajduje się w pliku:

```text
dokumentacja/WAD_Projekt.pdf
```
