-- ============================================================================
-- Data Warehouse Schema: 规范化分析数据库
-- 目的：从 Data Lake 清洗后创建规范化的维度表和事实表
-- 创建日期：2025-11-04
-- ============================================================================

-- ============================================================================
-- 第一部分：维度表 (Dimension Tables)
-- ============================================================================

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
    observation_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    
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
    
    -- 清洗后的主要字段
    year_start INT,
    year_end INT,
    location_abbr VARCHAR(10),
    location_desc VARCHAR(255),
    topic VARCHAR(255),
    question VARCHAR(500),
    data_value DECIMAL(18, 4),
    data_value_type VARCHAR(100),
    
    -- 数据质量标记
    is_valid BOOLEAN DEFAULT TRUE,
    validation_error_msg TEXT,
    
    -- 处理信息
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_by VARCHAR(100)
);

-- ============================================================================
-- 第五部分：数据加载和查询示例
-- ============================================================================

/*

-- 示例 1: 从 Data Lake 加载数据到维度表和事实表的 ETL 流程伪代码

-- Step 1: 加载 Topics 维度
INSERT INTO dim_topics (topic_name, topic_code)
SELECT DISTINCT
    Topic,
    TopicID
FROM stg_us_chronic_disease_raw
WHERE Topic IS NOT NULL;

-- Step 2: 加载 Questions 维度
INSERT INTO dim_questions (question_text, question_code, topic_id)
SELECT DISTINCT
    q.Question,
    q.QuestionID,
    t.topic_id
FROM stg_us_chronic_disease_raw q
JOIN dim_topics t ON q.Topic = t.topic_name
WHERE q.Question IS NOT NULL;

-- Step 3: 加载 Locations 维度
INSERT INTO dim_locations (location_abbr, location_desc, geolocation)
SELECT DISTINCT
    LocationAbbr,
    LocationDesc,
    Geolocation
FROM stg_us_chronic_disease_raw
WHERE LocationDesc IS NOT NULL;

-- Step 4: 加载 Data Value Types 维度
INSERT INTO dim_data_value_types (type_name, unit_of_measure)
SELECT DISTINCT
    DataValueType,
    DataValueUnit
FROM stg_us_chronic_disease_raw
WHERE DataValueType IS NOT NULL;

-- Step 5: 加载 Stratifications 维度
INSERT INTO dim_stratification_categories (category_name)
SELECT DISTINCT StratificationCategory1
FROM stg_us_chronic_disease_raw
WHERE StratificationCategory1 IS NOT NULL
UNION
SELECT DISTINCT StratificationCategory2
FROM stg_us_chronic_disease_raw
WHERE StratificationCategory2 IS NOT NULL
UNION
SELECT DISTINCT StratificationCategory3
FROM stg_us_chronic_disease_raw
WHERE StratificationCategory3 IS NOT NULL;

-- Step 6: 加载事实表
INSERT INTO fact_health_observations (
    topic_id, question_id, location_id, stratification_id,
    data_value_type_id, year_start, year_end, data_value,
    low_confidence_limit, high_confidence_limit,
    response_value, data_value_footnote,
    data_source, load_date,
    original_location_id, original_topic_id, original_question_id,
    original_stratif_category_id_1, original_stratif_id_1
)
SELECT
    t.topic_id,
    q.question_id,
    l.location_id,
    s.stratification_id,
    dvt.data_value_type_id,
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
    r.TopicID,
    r.QuestionID,
    r.StratificationCategoryID1,
    r.StratificationID1
FROM stg_us_chronic_disease_raw r
LEFT JOIN dim_topics t ON r.Topic = t.topic_name
LEFT JOIN dim_questions q ON r.Question = q.question_text
LEFT JOIN dim_locations l ON r.LocationDesc = l.location_desc
LEFT JOIN dim_data_value_types dvt ON r.DataValueType = dvt.type_name
LEFT JOIN dim_stratifications s ON r.Stratification1 = s.stratification_value
WHERE r.DataValue IS NOT NULL;

*/

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
