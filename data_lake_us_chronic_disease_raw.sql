-- Ensure schema exists and is selected
CREATE DATABASE IF NOT EXISTS chronic_disease_data;
USE chronic_disease_data;

-- Drop existing table if needed (可选)
-- DROP TABLE IF EXISTS stg_us_chronic_disease_raw;
-- Drop table if it already exists to avoid error
DROP TABLE IF EXISTS stg_us_chronic_disease_raw;

CREATE TABLE stg_us_chronic_disease_raw (
    YearStart                                INT,
    YearEnd                                  INT,
    LocationAbbr                             VARCHAR(255),
    LocationDesc                             VARCHAR(255),
    DataSource                               VARCHAR(255),
    Topic                                    VARCHAR(255),
    Question                                 VARCHAR(255),
    Response                                 DECIMAL(18, 4),
    DataValueUnit                            VARCHAR(255),
    DataValueType                            VARCHAR(255),
    DataValue                                VARCHAR(255),
    DataValueAlt                             VARCHAR(255),
    DataValueFootnoteSymbol                  VARCHAR(255),
    DataValueFootnote                        VARCHAR(255),
    LowConfidenceLimit                       VARCHAR(255),
    HighConfidenceLimit                      VARCHAR(255),
    StratificationCategory1                  VARCHAR(255),
    Stratification1                          VARCHAR(255),
    StratificationCategory2                  DECIMAL(18, 4),
    Stratification2                          DECIMAL(18, 4),
    StratificationCategory3                  DECIMAL(18, 4),
    Stratification3                          DECIMAL(18, 4),
    Geolocation                              VARCHAR(255),
    LocationID                               INT,
    TopicID                                  VARCHAR(255),
    QuestionID                               VARCHAR(255),
    ResponseID                               DECIMAL(18, 4),
    DataValueTypeID                          VARCHAR(255),
    StratificationCategoryID1                VARCHAR(255),
    StratificationID1                        VARCHAR(255),
    StratificationCategoryID2                DECIMAL(18, 4),
    StratificationID2                        DECIMAL(18, 4),
    StratificationCategoryID3                DECIMAL(18, 4),
    StratificationID3                        DECIMAL(18, 4)
);



-- ============================================================================
-- 加载数据到 Data Lake 表的示例命令（根据数据库类型调整）
-- ============================================================================

-- PostgreSQL 示例：
-- COPY stg_us_chronic_disease_raw FROM '/path/to/U.S._Chronic_Disease_Indicators_20251102.csv' 
--     WITH (FORMAT csv, HEADER true, DELIMITER ',', NULL 'NULL');
-- MySQL 示例：
LOAD DATA LOCAL INFILE '/Users/mac/Desktop/Lecture_2433/group_project_111325/data/U.S._Chronic_Disease_Indicators_20251102.csv'
    INTO TABLE stg_us_chronic_disease_raw
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;

-- SQLite 示例：
-- .mode csv
-- .import U.S._Chronic_Disease_Indicators_20251102.csv stg_us_chronic_disease_raw
