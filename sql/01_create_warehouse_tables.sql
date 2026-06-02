USE imdb;
GO

-- Tabele bridge i faktów usuwamy jako pierwsze, bo mają klucze obce
DROP TABLE IF EXISTS bridge_movie_country;
DROP TABLE IF EXISTS bridge_movie_genre;
DROP TABLE IF EXISTS fact_movies;

DROP TABLE IF EXISTS dim_country;
DROP TABLE IF EXISTS dim_genre;
DROP TABLE IF EXISTS dim_status;
DROP TABLE IF EXISTS dim_language;
DROP TABLE IF EXISTS dim_movie;
DROP TABLE IF EXISTS dim_date;
GO

-- Wymiar daty
CREATE TABLE dim_date (
    date_id   INT IDENTITY(1,1) PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    [year]    INT,
    [month]   INT,
    [day]     INT,
    [quarter] INT
);

-- Wymiar filmu
CREATE TABLE dim_movie (
    movie_id       INT IDENTITY(1,1) PRIMARY KEY,
    source_id      INT NOT NULL,
    title          NVARCHAR(500),
    original_title NVARCHAR(500),
    runtime        FLOAT,
    overview       NVARCHAR(MAX),
    tagline        NVARCHAR(MAX),

    CONSTRAINT uq_dim_movie_source_id UNIQUE (source_id)
);

-- Wymiar języka
CREATE TABLE dim_language (
    language_id   INT IDENTITY(1,1) PRIMARY KEY,
    language_code NVARCHAR(10),
    language_name NVARCHAR(100),

    CONSTRAINT uq_dim_language_code UNIQUE (language_code)
);

-- Wymiar statusu filmu
CREATE TABLE dim_status (
    status_id   INT IDENTITY(1,1) PRIMARY KEY,
    status_name NVARCHAR(100) NOT NULL,

    CONSTRAINT uq_dim_status_name UNIQUE (status_name)
);

-- Wymiar gatunku
CREATE TABLE dim_genre (
    genre_id   INT IDENTITY(1,1) PRIMARY KEY,
    genre_name NVARCHAR(100) NOT NULL,

    CONSTRAINT uq_dim_genre_name UNIQUE (genre_name)
);

-- Wymiar kraju produkcji
CREATE TABLE dim_country (
    country_id   INT IDENTITY(1,1) PRIMARY KEY,
    country_name NVARCHAR(200) NOT NULL,

    CONSTRAINT uq_dim_country_name UNIQUE (country_name)
);

-- Tabela faktów
CREATE TABLE fact_movies (
    fact_id      INT IDENTITY(1,1) PRIMARY KEY,
    movie_id     INT NOT NULL,
    date_id      INT NOT NULL,
    language_id  INT NOT NULL,
    status_id    INT NOT NULL,

    budget       BIGINT,
    revenue      BIGINT,
    profit       AS (revenue - budget) PERSISTED,

    vote_average FLOAT,
    vote_count   INT,
    popularity   FLOAT,

    CONSTRAINT fk_fact_movie
        FOREIGN KEY (movie_id) REFERENCES dim_movie(movie_id),

    CONSTRAINT fk_fact_date
        FOREIGN KEY (date_id) REFERENCES dim_date(date_id),

    CONSTRAINT fk_fact_language
        FOREIGN KEY (language_id) REFERENCES dim_language(language_id),

    CONSTRAINT fk_fact_status
        FOREIGN KEY (status_id) REFERENCES dim_status(status_id)
);

-- Tabela bridge: film - gatunek
CREATE TABLE bridge_movie_genre (
    movie_id INT NOT NULL,
    genre_id INT NOT NULL,

    CONSTRAINT pk_bridge_movie_genre
        PRIMARY KEY (movie_id, genre_id),

    CONSTRAINT fk_bridge_movie_genre_movie
        FOREIGN KEY (movie_id) REFERENCES dim_movie(movie_id),

    CONSTRAINT fk_bridge_movie_genre_genre
        FOREIGN KEY (genre_id) REFERENCES dim_genre(genre_id)
);

-- Tabela bridge: film - kraj produkcji
CREATE TABLE bridge_movie_country (
    movie_id   INT NOT NULL,
    country_id INT NOT NULL,

    CONSTRAINT pk_bridge_movie_country
        PRIMARY KEY (movie_id, country_id),

    CONSTRAINT fk_bridge_movie_country_movie
        FOREIGN KEY (movie_id) REFERENCES dim_movie(movie_id),

    CONSTRAINT fk_bridge_movie_country_country
        FOREIGN KEY (country_id) REFERENCES dim_country(country_id)
);
GO