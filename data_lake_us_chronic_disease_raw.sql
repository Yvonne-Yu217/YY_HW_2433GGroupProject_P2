-- ============================================================================
-- Data Lake Schema: 美国慢性病指标数据 (U.S. Chronic Disease Indicators)
-- 目的：存储来自 CDC 的原始慢性病指标数据
-- 创建日期：2025-11-04
-- ============================================================================

-- Drop existing table if needed (可选)
-- DROP TABLE IF EXISTS stg_us_chronic_disease_raw;

-- 创建 Data Lake 表：原始慢性病指标数据
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

-- 创建索引以提高查询性能
CREATE INDEX idx_stg_topic ON stg_us_chronic_disease_raw(Topic);
CREATE INDEX idx_stg_question ON stg_us_chronic_disease_raw(Question);
CREATE INDEX idx_stg_location ON stg_us_chronic_disease_raw(LocationDesc);
CREATE INDEX idx_stg_year ON stg_us_chronic_disease_raw(YearStart, YearEnd);
CREATE INDEX idx_stg_data_value ON stg_us_chronic_disease_raw(Data_Value);

-- ============================================================================
-- 加载数据到 Data Lake 表的示例命令（根据数据库类型调整）
-- ============================================================================

-- PostgreSQL 示例：
-- COPY stg_us_chronic_disease_raw FROM '/path/to/U.S._Chronic_Disease_Indicators_20251102.csv' 
--     WITH (FORMAT csv, HEADER true, DELIMITER ',', NULL 'NULL');

-- MySQL 示例：
-- LOAD DATA LOCAL INFILE '/path/to/U.S._Chronic_Disease_Indicators_20251102.csv'
--     INTO TABLE stg_us_chronic_disease_raw
--     FIELDS TERMINATED BY ','
--     ENCLOSED BY '"'
--     LINES TERMINATED BY '\n'
--     IGNORE 1 ROWS;

-- SQLite 示例：
-- .mode csv
-- .import U.S._Chronic_Disease_Indicators_20251102.csv stg_us_chronic_disease_raw
