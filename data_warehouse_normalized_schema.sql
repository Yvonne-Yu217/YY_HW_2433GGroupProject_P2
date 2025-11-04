-- ============================================================================
-- Data Warehouse Schema: 规范化分析数据库
-- 目的：从 Data Lake 清洗后创建规范化的维度表和事实表
-- 创建日期：2025-11-04
-- ============================================================================

-- 确保数据库存在并选择
CREATE DATABASE IF NOT EXISTS chronic_disease_data;
USE chronic_disease_data;

-- ============================================================================
-- 第一部分：维度表 (Dimension Tables)
-- ============================================================================

-- 删除已存在的表（按依赖顺序逆序删除）
DROP TABLE IF EXISTS fact_health_observations;
DROP TABLE IF EXISTS stg_data_cleaning;
DROP TABLE IF EXISTS dim_stratifications;
DROP TABLE IF EXISTS dim_stratification_categories;
DROP TABLE IF EXISTS dim_data_value_types;
DROP TABLE IF EXISTS dim_questions;
DROP TABLE IF EXISTS dim_topics;
DROP TABLE IF EXISTS dim_locations;

-- 维度表 1: 健康主题 (Topics)
CREATE TABLE dim_topics (
    topic_id INT PRIMARY KEY AUTO_INCREMENT,
    topic_name VARCHAR(255) NOT NULL UNIQUE,
    topic_code VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 维度表 2: 具体问题 (Questions/Indicators)
CREATE TABLE dim_questions (
    question_id INT PRIMARY KEY AUTO_INCREMENT,
    question_text VARCHAR(500) NOT NULL UNIQUE,
    question_code VARCHAR(100),
    topic_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (topic_id) REFERENCES dim_topics(topic_id)
);

-- 维度表 3: 地理位置 (Locations)
CREATE TABLE dim_locations (
    location_id INT PRIMARY KEY AUTO_INCREMENT,
    location_abbr VARCHAR(10) NOT NULL UNIQUE,
    location_desc VARCHAR(255) NOT NULL,
    location_type VARCHAR(50),  -- 'State', 'Territory', 'National'
    geolocation VARCHAR(255),   -- 地理坐标信息
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 维度表 4: 分层类别 (Stratification Categories)
CREATE TABLE dim_stratification_categories (
    stratif_category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    category_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 维度表 5: 具体分层值 (Stratification Values)
CREATE TABLE dim_stratifications (
    stratification_id INT PRIMARY KEY AUTO_INCREMENT,
    stratif_category_id INT NOT NULL,
    stratification_value VARCHAR(200) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (stratif_category_id) REFERENCES dim_stratification_categories(stratif_category_id),
    UNIQUE KEY unique_stratif (stratif_category_id, stratification_value)
);

-- 维度表 6: 数据值类型 (Data Value Types)
CREATE TABLE dim_data_value_types (
    data_value_type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(100) NOT NULL UNIQUE,
    unit_of_measure VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 第二部分：事实表 (Fact Tables)
-- ============================================================================

-- 事实表: 健康观察指标 (Health Observations)
CREATE TABLE fact_health_observations (
    observation_id BIGINT AUTO_INCREMENT,
    -- 外键关联维度表
    topic_id INT NOT NULL,
    question_id INT NOT NULL,
    location_id INT NOT NULL,
    stratification_id INT,
    data_value_type_id INT,
    -- 时间维度
    year_start INT NOT NULL,
    year_end INT NOT NULL,
    -- 观察数据
    data_value DECIMAL(18, 4),
    low_confidence_limit DECIMAL(18, 4),
    high_confidence_limit DECIMAL(18, 4),
    -- 元数据
    response_value VARCHAR(255),
    data_value_footnote_symbol VARCHAR(10),
    data_value_footnote TEXT,
    data_source VARCHAR(100),
    -- 原始 ID（用于追踪）
    original_location_id INT,
    original_topic_id VARCHAR(50),
    original_question_id VARCHAR(50),
    original_stratif_category_id_1 VARCHAR(50),
    original_stratif_id_1 VARCHAR(50),
    original_stratif_category_id_2 VARCHAR(50),
    original_stratif_id_2 VARCHAR(50),
    original_stratif_category_id_3 VARCHAR(50),
    original_stratif_id_3 VARCHAR(50),
    -- 审计字段
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    load_date DATE,
    -- 主键和外键
    PRIMARY KEY (observation_id),
    FOREIGN KEY (topic_id) REFERENCES dim_topics(topic_id),
    FOREIGN KEY (question_id) REFERENCES dim_questions(question_id),
    FOREIGN KEY (location_id) REFERENCES dim_locations(location_id),
    FOREIGN KEY (stratification_id) REFERENCES dim_stratifications(stratification_id),
    FOREIGN KEY (data_value_type_id) REFERENCES dim_data_value_types(data_value_type_id)
);

-- ============================================================================
-- 第三部分：查询优化索引
-- ============================================================================

-- 事实表索引
CREATE INDEX idx_fact_topic ON fact_health_observations(topic_id);
CREATE INDEX idx_fact_question ON fact_health_observations(question_id);
CREATE INDEX idx_fact_location ON fact_health_observations(location_id);
CREATE INDEX idx_fact_stratification ON fact_health_observations(stratification_id);
CREATE INDEX idx_fact_year ON fact_health_observations(year_start, year_end);
CREATE INDEX idx_fact_data_value_type ON fact_health_observations(data_value_type_id);
CREATE INDEX idx_fact_created ON fact_health_observations(created_at);
CREATE INDEX idx_fact_composite ON fact_health_observations(location_id, topic_id, year_start);

-- 维度表索引
CREATE INDEX idx_dim_topic_code ON dim_topics(topic_code);
CREATE INDEX idx_dim_question_code ON dim_questions(question_code);
CREATE INDEX idx_dim_question_topic ON dim_questions(topic_id);
CREATE INDEX idx_dim_location_type ON dim_locations(location_type);

-- ============================================================================
-- 第四部分：ETL 处理的临时表
-- ============================================================================

-- 临时表：用于 ETL 数据清洗
CREATE TABLE stg_data_cleaning (
    record_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    original_record_id BIGINT,
    year_start INT,
    year_end INT,
    location_abbr VARCHAR(10),
    location_desc VARCHAR(255),
    topic VARCHAR(255),
    question VARCHAR(500),
    data_value DECIMAL(18, 4),
    data_value_type VARCHAR(100),
    is_valid BOOLEAN DEFAULT TRUE,
    validation_error_msg TEXT,
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_by VARCHAR(100)
);

-- ============================================================================
-- 第五部分：ETL 数据加载流程 - 从 Data Lake 同步数据到 Data Warehouse
-- ============================================================================

-- Step 1: 加载 Topics 维度表
INSERT IGNORE INTO dim_topics (topic_name, topic_code)
SELECT DISTINCT
    Topic,
    CAST(TopicID AS CHAR)
FROM stg_us_chronic_disease_raw
WHERE Topic IS NOT NULL;

-- Step 2: 加载 Locations 维度表
INSERT IGNORE INTO dim_locations (location_abbr, location_desc, geolocation)
SELECT DISTINCT
    LocationAbbr,
    LocationDesc,
    Geolocation
FROM stg_us_chronic_disease_raw
WHERE LocationDesc IS NOT NULL;

-- Step 3: 加载 Data Value Types 维度表
INSERT IGNORE INTO dim_data_value_types (type_name, unit_of_measure)
SELECT DISTINCT
    DataValueType,
    DataValueUnit
FROM stg_us_chronic_disease_raw
WHERE DataValueType IS NOT NULL;

-- Step 4: 加载 Questions 维度表（依赖 Topics）
INSERT IGNORE INTO dim_questions (question_text, question_code, topic_id)
SELECT DISTINCT
    r.Question,
    CAST(r.QuestionID AS CHAR),
    COALESCE(t.topic_id, 1)
FROM stg_us_chronic_disease_raw r
LEFT JOIN dim_topics t ON r.Topic = t.topic_name
WHERE r.Question IS NOT NULL;

-- Step 5: 加载 Stratification Categories 维度表（分开三个 INSERT）
INSERT IGNORE INTO dim_stratification_categories (category_name)
SELECT DISTINCT CAST(StratificationCategory1 AS CHAR)
FROM stg_us_chronic_disease_raw
WHERE StratificationCategory1 IS NOT NULL AND CAST(StratificationCategory1 AS CHAR) != '';

INSERT IGNORE INTO dim_stratification_categories (category_name)
SELECT DISTINCT CAST(StratificationCategory2 AS CHAR)
FROM stg_us_chronic_disease_raw
WHERE StratificationCategory2 IS NOT NULL AND CAST(StratificationCategory2 AS CHAR) != '';

INSERT IGNORE INTO dim_stratification_categories (category_name)
SELECT DISTINCT CAST(StratificationCategory3 AS CHAR)
FROM stg_us_chronic_disease_raw
WHERE StratificationCategory3 IS NOT NULL AND CAST(StratificationCategory3 AS CHAR) != '';

-- Step 6: 加载 Stratifications 维度表（分开三个 INSERT，避免 UNION 和字符集冲突）
INSERT IGNORE INTO dim_stratifications (stratif_category_id, stratification_value)
SELECT DISTINCT
    COALESCE(sc.stratif_category_id, 1),
    CAST(r.Stratification1 AS CHAR)
FROM stg_us_chronic_disease_raw r
LEFT JOIN dim_stratification_categories sc ON CAST(r.StratificationCategory1 AS CHAR) COLLATE utf8mb4_general_ci = sc.category_name COLLATE utf8mb4_general_ci
WHERE r.Stratification1 IS NOT NULL;

INSERT IGNORE INTO dim_stratifications (stratif_category_id, stratification_value)
SELECT DISTINCT
    COALESCE(sc.stratif_category_id, 1),
    CAST(r.Stratification2 AS CHAR)
FROM stg_us_chronic_disease_raw r
LEFT JOIN dim_stratification_categories sc ON CAST(r.StratificationCategory2 AS CHAR) COLLATE utf8mb4_general_ci = sc.category_name COLLATE utf8mb4_general_ci
WHERE r.Stratification2 IS NOT NULL;

INSERT IGNORE INTO dim_stratifications (stratif_category_id, stratification_value)
SELECT DISTINCT
    COALESCE(sc.stratif_category_id, 1),
    CAST(r.Stratification3 AS CHAR)
FROM stg_us_chronic_disease_raw r
LEFT JOIN dim_stratification_categories sc ON CAST(r.StratificationCategory3 AS CHAR) COLLATE utf8mb4_general_ci = sc.category_name COLLATE utf8mb4_general_ci
WHERE r.Stratification3 IS NOT NULL;

-- Step 7: 加载事实表（健康观察指标）
INSERT IGNORE INTO fact_health_observations (
    topic_id, question_id, location_id, stratification_id,
    data_value_type_id, year_start, year_end, data_value,
    low_confidence_limit, high_confidence_limit,
    response_value, data_value_footnote,
    data_source, load_date,
    original_location_id, original_topic_id, original_question_id,
    original_stratif_category_id_1, original_stratif_id_1
)
SELECT
    COALESCE(t.topic_id, 1),
    COALESCE(q.question_id, 1),
    COALESCE(l.location_id, 1),
    COALESCE(s.stratification_id, 1),
    COALESCE(dvt.data_value_type_id, 1),
    r.YearStart,
    r.YearEnd,
    CAST(r.DataValue AS DECIMAL(18,4)),
    CAST(r.LowConfidenceLimit AS DECIMAL(18,4)),
    CAST(r.HighConfidenceLimit AS DECIMAL(18,4)),
    r.Response,
    r.DataValueFootnote,
    r.DataSource,
    CURDATE(),
    r.LocationID,
    CAST(r.TopicID AS CHAR),
    CAST(r.QuestionID AS CHAR),
    CAST(r.StratificationCategoryID1 AS CHAR),
    CAST(r.StratificationID1 AS CHAR)
FROM stg_us_chronic_disease_raw r
LEFT JOIN dim_topics t ON r.Topic = t.topic_name
LEFT JOIN dim_questions q ON r.Question = q.question_text
LEFT JOIN dim_locations l ON r.LocationDesc = l.location_desc
LEFT JOIN dim_data_value_types dvt ON r.DataValueType = dvt.type_name
LEFT JOIN dim_stratifications s ON CAST(r.Stratification1 AS CHAR) COLLATE utf8mb4_general_ci = s.stratification_value COLLATE utf8mb4_general_ci
WHERE r.DataValue IS NOT NULL
  AND r.YearStart IS NOT NULL
  AND r.LocationDesc IS NOT NULL;

-- ============================================================================
-- 第六部分：分析查询示例
-- ============================================================================

/*

-- 查询 1: 按州和年份统计糖尿病患病率
SELECT
    l.location_desc AS 州,
    f.year_start AS 年份,
    ROUND(AVG(f.data_value), 2) AS 平均患病率
FROM fact_health_observations f
JOIN dim_locations l ON f.location_id = l.location_id
JOIN dim_questions q ON f.question_id = q.question_id
WHERE q.question_text LIKE '%Diabetes%'
  AND f.year_start >= 2018
GROUP BY l.location_desc, f.year_start
ORDER BY l.location_desc, f.year_start DESC;

-- 查询 2: 特定地区特定人口群体的健康指标对比
SELECT
    q.question_text,
    s.stratification_value,
    ROUND(AVG(f.data_value), 2) AS 平均值,
    COUNT(*) AS 记录数
FROM fact_health_observations f
JOIN dim_questions q ON f.question_id = q.question_id
JOIN dim_stratifications s ON f.stratification_id = s.stratification_id
JOIN dim_locations l ON f.location_id = l.location_id
WHERE l.location_abbr = 'CA'
  AND f.year_start = 2023
GROUP BY q.question_text, s.stratification_value
ORDER BY AVG(f.data_value) DESC;

*/

-- ============================================================================
-- 表结构创建完成
-- ============================================================================
