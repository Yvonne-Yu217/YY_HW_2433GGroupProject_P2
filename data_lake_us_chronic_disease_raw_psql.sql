-- === 0) create & switch DB (run once; ignore error if it already exists)
CREATE DATABASE chronic_disease_data;
\c chronic_disease_data

-- === 1) schema (optional but tidy)
CREATE SCHEMA IF NOT EXISTS datalake;
SET search_path TO datalake, public;

-- === 2) table DDL (PostgreSQL-safe)
DROP TABLE IF EXISTS stg_us_chronic_disease_raw;

CREATE TABLE stg_us_chronic_disease_raw (
    YearStart                  integer,
    YearEnd                    integer,
    LocationAbbr               text,
    LocationDesc               text,
    DataSource                 text,
    Topic                      text,
    Question                   text,
    Response                   numeric(18,4),
    DataValueUnit              text,
    DataValueType              text,
    DataValue                  text,
    DataValueAlt               text,
    DataValueFootnoteSymbol    text,
    DataValueFootnote          text,
    LowConfidenceLimit         text,
    HighConfidenceLimit        text,
    StratificationCategory1    text,
    Stratification1            text,
    StratificationCategory2    text,
    Stratification2            text,
    StratificationCategory3    text,
    Stratification3            text,
    Geolocation                text,
    LocationID                 integer,
    TopicID                    text,
    QuestionID                 text,
    ResponseID                 text,
    DataValueTypeID            text,
    StratificationCategoryID1  text,
    StratificationID1          text,
    StratificationCategoryID2  text,
    StratificationID2          text,
    StratificationCategoryID3  text,
    StratificationID3          text
);

-- === 3) (later) load the CSV from CloudShell into the table
-- Replace the file name if yours differs.
-- This runs from *psql* and reads a local file on CloudShell.
\copy datalake.stg_us_chronic_disease_raw
  FROM '/home/cloudshell-user/U.S._Chronic_Disease_Indicators_20251102.csv'
  WITH (FORMAT csv, HEADER true);
