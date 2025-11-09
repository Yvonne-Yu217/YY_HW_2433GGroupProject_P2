-- =====================================================================
-- Database Integration Strategy (T-SQL for Azure SQL)
-- 数据库整合策略：连接 EDA 业务数据与美国慢性病分析数据
-- File: db_integration_strategy.sql
-- Updated: 2025-11-08 for Azure SQL Database
--
-- CORE CONCEPT / 核心思路:
-- Connect EDA business data with US Chronic Disease analytics data 
-- using geographic location (State) as the bridge.
-- 通过地理位置（州）作为桥梁，将客户/账户数据与慢性病指标数据进行连接。
--
-- STRATEGY STEPS / 策略步骤:
-- 1. Create Bridge Table (integration.CustomerLocationBridge) 
--    to store customer/account location info
-- 2. Create Unified Location View (integration.vw_UnifiedLocationDim)
--    to simplify geographic dimension joins
-- 3. Create Final Analysis View (integration.vw_CustomerHealthRiskAnalysis)
--    as a wide table for BI tools
--
-- ADVANTAGES / 优点:
-- - Non-invasive: doesn't modify existing business or analytics tables
-- - Performance: pre-computed bridge table with indexes
-- - Easy to use: final view hides complex join logic
-- =====================================================================

-- =====================================================================
-- PREREQUISITES / 前提条件:
-- 1. Database: business_eda (contains Customer, CustomerAddress, Account, State tables)
-- 2. Database: HealthDW (contains dw.DimLocations, dw.DimTopics, dw.DimQuestions, dw.FactHealthObservations)
-- 3. Current database context should be business_eda when running steps 1-2
-- =====================================================================

USE business_eda;
GO

-- =====================================================================
-- STEP 1: Create Integration Schema and Bridge Table
-- 步骤 1: 创建集成架构和桥梁表
--
-- PURPOSE / 目的:
-- Extract key customer/account location information from complex business tables
-- to avoid expensive joins every query.
-- 从复杂的业务表中提取关键的客户/账户位置信息，避免每次查询都做昂贵的连接。
--
-- DESIGN / 设计:
-- - customer_key: Customer unique ID (LastName|FirstName|MiddleInitial|Suffix|DOB)
-- - account_key: Account unique ID (AccountName|LocationAddress1|LocationCity|LocationState|LocationZip|CompanyCode)
-- - state_code: State code (2-letter abbreviation, e.g., 'CA', 'NY')
-- - record_type: 'Customer' or 'Account'
-- =====================================================================

-- Create integration schema
IF SCHEMA_ID(N'integration') IS NULL
    EXEC('CREATE SCHEMA integration;');
GO

-- Drop and recreate bridge table
IF OBJECT_ID('integration.CustomerLocationBridge', 'U') IS NOT NULL
    DROP TABLE integration.CustomerLocationBridge;
GO

CREATE TABLE integration.CustomerLocationBridge (
    BridgeID        INT IDENTITY(1,1) PRIMARY KEY,
    CustomerKey     NVARCHAR(500) NULL,  -- Format: LastName|FirstName|MiddleInitial|Suffix|DOB
    AccountKey      NVARCHAR(500) NULL,  -- Format: AccountName|LocationAddress1|LocationCity|LocationState|LocationZip|CompanyCode
    StateCode       NVARCHAR(2) NOT NULL,  -- 2-letter state code (matches State.StateCode)
    RecordType      NVARCHAR(20) NOT NULL,  -- 'Customer' or 'Account'
    LastUpdated     DATETIME2(3) NOT NULL CONSTRAINT DF_Bridge_LastUpdated DEFAULT SYSUTCDATETIME(),
    CONSTRAINT UQ_Bridge_Record UNIQUE (CustomerKey, AccountKey, StateCode, RecordType)
);
GO

-- Create indexes for performance
CREATE NONCLUSTERED INDEX IX_Bridge_StateCode ON integration.CustomerLocationBridge(StateCode);
CREATE NONCLUSTERED INDEX IX_Bridge_CustomerKey ON integration.CustomerLocationBridge(CustomerKey) WHERE CustomerKey IS NOT NULL;
CREATE NONCLUSTERED INDEX IX_Bridge_AccountKey ON integration.CustomerLocationBridge(AccountKey) WHERE AccountKey IS NOT NULL;
CREATE NONCLUSTERED INDEX IX_Bridge_RecordType ON integration.CustomerLocationBridge(RecordType);
GO


-- =====================================================================
-- STEP 1.1: Populate Bridge Table (ETL Process)
-- 步骤 1.1: 填充桥梁表 (ETL 过程)
--
-- PURPOSE / 目的:
-- Load customer and account location data from business tables into bridge table.
-- This should be a scheduled ETL job (e.g., daily or weekly).
-- 将业务表的客户和账户位置数据加载到桥梁表中。这应该是定期的 ETL 作业。
-- =====================================================================

-- Load Customer location data from CustomerAddress
-- Note: EDA.sql uses CustState in CustomerAddress, which should map to State.StateCode
INSERT INTO integration.CustomerLocationBridge (CustomerKey, AccountKey, StateCode, RecordType)
SELECT DISTINCT
    CONCAT(c.CustLastName, '|', c.CustFirstName, '|', c.CustMiddleInitial, '|', c.CustSuffix, '|', CONVERT(NVARCHAR(10), c.CustDOB, 120)) AS CustomerKey,
    NULL AS AccountKey,
    ca.CustState AS StateCode,  -- This should be 2-letter state code
    N'Customer' AS RecordType
FROM Customer c
INNER JOIN CustomerAddress ca 
    ON c.CustLastName = ca.CustLastName
    AND c.CustFirstName = ca.CustFirstName
    AND c.CustMiddleInitial = ca.CustMiddleInitial
    AND c.CustSuffix = ca.CustSuffix
    AND c.CustDOB = ca.CustDOB
WHERE ca.CustState IS NOT NULL 
  AND LEN(ca.CustState) = 2  -- Ensure it's a valid 2-letter state code
  AND NOT EXISTS (
      SELECT 1 FROM integration.CustomerLocationBridge b
      WHERE b.CustomerKey = CONCAT(c.CustLastName, '|', c.CustFirstName, '|', c.CustMiddleInitial, '|', c.CustSuffix, '|', CONVERT(NVARCHAR(10), c.CustDOB, 120))
        AND b.StateCode = ca.CustState
        AND b.RecordType = N'Customer'
  );
GO

-- Load Account location data
-- Note: EDA.sql Account table has LocationState field
INSERT INTO integration.CustomerLocationBridge (CustomerKey, AccountKey, StateCode, RecordType)
SELECT DISTINCT
    NULL AS CustomerKey,
    CONCAT(a.AccountName, '|', a.LocationAddress1, '|', a.LocationCity, '|', a.LocationState, '|', a.LocationZip, '|', a.CompanyCode) AS AccountKey,
    a.LocationState AS StateCode,  -- This should be 2-letter state code
    N'Account' AS RecordType
FROM Account a
WHERE a.LocationState IS NOT NULL 
  AND LEN(a.LocationState) = 2  -- Ensure it's a valid 2-letter state code
  AND NOT EXISTS (
      SELECT 1 FROM integration.CustomerLocationBridge b
      WHERE b.AccountKey = CONCAT(a.AccountName, '|', a.LocationAddress1, '|', a.LocationCity, '|', a.LocationState, '|', a.LocationZip, '|', a.CompanyCode)
        AND b.StateCode = a.LocationState
        AND b.RecordType = N'Account'
  );
GO

-- Verify bridge table population
SELECT 
    RecordType,
    COUNT(*) AS RecordCount,
    COUNT(DISTINCT StateCode) AS UniqueStates
FROM integration.CustomerLocationBridge
GROUP BY RecordType;
GO


-- =====================================================================
-- STEP 2: Create Unified Location Dimension View
-- 步骤 2: 创建统一的地理维度视图
--
-- PURPOSE / 目的:
-- Join the HealthDW.dw.DimLocations with our bridge table to create
-- a unified geographic dimension with customer/account associations.
-- 将 HealthDW.dw.DimLocations 与桥梁表连接，创建包含客户/账户关联的统一地理维度。
--
-- NOTE: This uses three-part naming to reference HealthDW database
-- 注意：使用三段式命名引用 HealthDW 数据库
-- =====================================================================

-- Drop and recreate view
IF OBJECT_ID('integration.vw_UnifiedLocationDim', 'V') IS NOT NULL
    DROP VIEW integration.vw_UnifiedLocationDim;
GO

CREATE VIEW integration.vw_UnifiedLocationDim AS
SELECT
    dl.LocationID,
    dl.LocationAbbr,
    dl.LocationDesc,
    dl.LocationType,
    dl.Geolocation,
    b.BridgeID,
    b.CustomerKey,
    b.AccountKey,
    b.StateCode,
    b.RecordType,
    b.LastUpdated
FROM HealthDW.dw.DimLocations dl
INNER JOIN integration.CustomerLocationBridge b 
    ON dl.LocationAbbr = b.StateCode;  -- Join on state abbreviation
GO


-- =====================================================================
-- STEP 3: Create Final Analysis View (Wide Table for BI)
-- 步骤 3: 创建最终分析视图 (BI 大宽表)
--
-- PURPOSE / 目的:
-- Create a comprehensive view that combines customer/account data
-- with chronic disease health indicators for easy BI analysis.
-- 创建综合视图，将客户/账户数据与慢性病健康指标结合，便于 BI 分析。
-- =====================================================================

IF OBJECT_ID('integration.vw_CustomerHealthRiskAnalysis', 'V') IS NOT NULL
    DROP VIEW integration.vw_CustomerHealthRiskAnalysis;
GO

CREATE VIEW integration.vw_CustomerHealthRiskAnalysis AS
SELECT
    -- Bridge/Location Info
    loc.BridgeID,
    loc.RecordType,
    loc.StateCode,
    loc.LocationAbbr,
    loc.LocationDesc AS StateName,
    loc.Geolocation,
    
    -- Customer Info (if RecordType = 'Customer')
    loc.CustomerKey,
    cust.CustFirstName,
    cust.CustLastName,
    cust.CustMiddleInitial,
    cust.CustSuffix,
    cust.CustDOB,
    cust.Gender AS CustomerGender,
    
    -- Account Info (if RecordType = 'Account')
    loc.AccountKey,
    acct.AccountName,
    acct.LocationCity AS AccountCity,
    acct.LocationZip AS AccountZip,
    acct.NumberOfEmployees,
    acct.CompanyCode,
    
    -- Health Observation Info
    obs.ObservationID,
    obs.YearStart,
    obs.YearEnd,
    obs.DataValue,
    obs.LowConfidenceLimit,
    obs.HighConfidenceLimit,
    obs.DataValueFootnote,
    obs.DataSource,
    
    -- Topic Info
    t.TopicID,
    t.TopicName,
    t.TopicCode,
    
    -- Question Info
    q.QuestionID,
    q.QuestionText,
    q.QuestionCode,
    
    -- Stratification Info
    s.StratificationID,
    s.StratificationValue,
    sc.StratifCategoryID,
    sc.CategoryName AS StratificationCategory,
    
    -- Data Value Type Info
    dvt.DataValueTypeID,
    dvt.TypeName AS DataValueType,
    dvt.UnitOfMeasure

FROM integration.vw_UnifiedLocationDim loc

-- Join with Health Observations (Fact Table)
INNER JOIN HealthDW.dw.FactHealthObservations obs
    ON loc.LocationID = obs.LocationID

-- Join with Dimension Tables
LEFT JOIN HealthDW.dw.DimTopics t
    ON obs.TopicID = t.TopicID
LEFT JOIN HealthDW.dw.DimQuestions q
    ON obs.QuestionID = q.QuestionID
LEFT JOIN HealthDW.dw.DimStratifications s
    ON obs.StratificationID = s.StratificationID
LEFT JOIN HealthDW.dw.DimStratificationCategories sc
    ON s.StratifCategoryID = sc.StratifCategoryID
LEFT JOIN HealthDW.dw.DimDataValueTypes dvt
    ON obs.DataValueTypeID = dvt.DataValueTypeID

-- Join with Customer (only when RecordType = 'Customer')
LEFT JOIN Customer cust
    ON loc.RecordType = N'Customer'
    AND loc.CustomerKey = CONCAT(cust.CustLastName, '|', cust.CustFirstName, '|', cust.CustMiddleInitial, '|', cust.CustSuffix, '|', CONVERT(NVARCHAR(10), cust.CustDOB, 120))

-- Join with Account (only when RecordType = 'Account')
LEFT JOIN Account acct
    ON loc.RecordType = N'Account'
    AND loc.AccountKey = CONCAT(acct.AccountName, '|', acct.LocationAddress1, '|', acct.LocationCity, '|', acct.LocationState, '|', acct.LocationZip, '|', acct.CompanyCode);
GO


-- =====================================================================
-- STEP 4: Example Queries / 查询示例
-- =====================================================================

-- Query 1: Average health indicators for customers in California (CA)
-- 查询 1: 查看加州 (CA) 客户的平均健康指标
SELECT
    StateName,
    TopicName,
    AVG(DataValue) AS AverageIndicatorValue,
    COUNT(*) AS ObservationCount
FROM integration.vw_CustomerHealthRiskAnalysis
WHERE StateCode = 'CA'
  AND RecordType = N'Customer'
  AND DataValue IS NOT NULL
GROUP BY StateName, TopicName
ORDER BY TopicName;
GO

-- Query 2: Top 5 states with highest diabetes rates and our account counts
-- 查询 2: 糖尿病指标最高的五个州及我们的企业账户数量
WITH DiabetesStats AS (
    SELECT
        StateCode,
        StateName,
        AccountKey,
        AVG(DataValue) AS AvgDiabetesRate
    FROM integration.vw_CustomerHealthRiskAnalysis
    WHERE TopicName LIKE '%Diabetes%'
      AND RecordType = N'Account'
      AND DataValue IS NOT NULL
    GROUP BY StateCode, StateName, AccountKey
)
SELECT TOP 5
    StateName,
    COUNT(DISTINCT AccountKey) AS NumberOfAccounts,
    AVG(AvgDiabetesRate) AS AvgStateDiabetesRate
FROM DiabetesStats
GROUP BY StateName
ORDER BY AvgStateDiabetesRate DESC;
GO

-- Query 3: Customer count and obesity indicators by state
-- 查询 3: 各州客户总数及肥胖问题平均指标
SELECT
    StateName,
    COUNT(DISTINCT CustomerKey) AS TotalCustomers,
    AVG(CASE WHEN TopicName LIKE '%Obesity%' THEN DataValue ELSE NULL END) AS AvgObesityIndicator,
    MIN(YearStart) AS EarliestYear,
    MAX(YearEnd) AS LatestYear
FROM integration.vw_CustomerHealthRiskAnalysis
WHERE RecordType = N'Customer'
GROUP BY StateName
HAVING COUNT(DISTINCT CustomerKey) > 0
ORDER BY TotalCustomers DESC;
GO

-- Query 4: Detailed health risk profile for a specific state
-- 查询 4: 特定州的详细健康风险概况
SELECT
    TopicName,
    QuestionText,
    DataValueType,
    AVG(DataValue) AS AvgValue,
    MIN(DataValue) AS MinValue,
    MAX(DataValue) AS MaxValue,
    COUNT(*) AS MeasurementCount
FROM integration.vw_CustomerHealthRiskAnalysis
WHERE StateCode = 'NY'
  AND YearStart >= 2020
  AND DataValue IS NOT NULL
GROUP BY TopicName, QuestionText, DataValueType
ORDER BY TopicName, AvgValue DESC;
GO


-- =====================================================================
-- IMPLEMENTATION NOTES / 实施说明
-- =====================================================================
-- 
-- 1. DATABASE PERMISSIONS / 数据库权限:
--    Ensure the executing user has permissions to:
--    - CREATE SCHEMA, CREATE TABLE, CREATE VIEW in business_eda
--    - SELECT on HealthDW.dw.* tables
--    确保执行用户有权限在 business_eda 中创建架构/表/视图，以及查询 HealthDW.dw.* 表
--
-- 2. CROSS-DATABASE QUERIES / 跨数据库查询:
--    This script uses three-part naming (DatabaseName.SchemaName.ObjectName)
--    which works in Azure SQL Database if both databases are on the same server.
--    For cross-server queries, consider using Elastic Query or External Tables.
--    此脚本使用三段式命名，在 Azure SQL Database 中同一服务器的数据库间有效。
--    跨服务器查询请考虑使用 Elastic Query 或 External Tables。
--
-- 3. ETL SCHEDULING / ETL 调度:
--    The INSERT statements in Step 1.1 should be scheduled as a regular
--    ETL job (e.g., daily or weekly using Azure Data Factory, SQL Agent, 
--    or Azure Functions) to keep the bridge table synchronized with
--    source data changes.
--    步骤 1.1 的 INSERT 语句应配置为定期 ETL 作业（使用 Azure Data Factory、
--    SQL Agent 或 Azure Functions），以保持桥梁表与源数据同步。
--
-- 4. STATE CODE MAPPING / 州代码映射:
--    Ensure that:
--    - CustomerAddress.CustState contains 2-letter state codes (e.g., 'CA', 'NY')
--    - Account.LocationState contains 2-letter state codes
--    - HealthDW.dw.DimLocations.LocationAbbr contains matching state codes
--    - business_eda.State.StateCode contains the authoritative state code list
--    确保客户地址、账户位置、健康数据位置维度都使用一致的两字母州代码。
--
-- 5. PERFORMANCE OPTIMIZATION / 性能优化:
--    - Bridge table indexes are created for common join columns
--    - Consider partitioning FactHealthObservations by YearStart for large datasets
--    - Monitor query performance and add additional indexes as needed
--    已为常用连接列创建索引；对于大数据集考虑对事实表按年份分区；
--    监控查询性能并根据需要添加索引。
--
-- =====================================================================


-- =================================================================
-- 步骤 1: 创建客户/账户的地理位置桥梁表 (Bridge Table)
--
-- 目的:
-- 从庞大的业务数据库中，提取出用于分析的关键信息：客户/账户与其地理位置的关联。
-- 这避免了在每次查询时都去连接复杂的业务表。
--
-- 设计:
-- - `customer_key`: 客户的唯一标识。这里我们简化，使用姓、名、生日的组合。
-- - `account_key`: 账户的唯一标识。
-- - `location_state_abbr`: 客户或账户所在的州缩写 (例如 'CA', 'NY')。这是连接的关键。
-- - `record_type`: 'Customer' 或 'Account'，用于区分记录来源。
-- =================================================================

CREATE TABLE dim_customer_location_bridge (
    bridge_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_key VARCHAR(255), -- 格式: LastName|FirstName|DOB
    account_key VARCHAR(255),  -- 格式: AccountName|CompanyCode|LocationZip
    location_state_abbr VARCHAR(10) NOT NULL,
    record_type VARCHAR(20) NOT NULL COMMENT '记录来源: Customer 或 Account',
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_bridge_record UNIQUE (customer_key, account_key, location_state_abbr, record_type)
);

-- 为桥梁表的关键连接字段创建索引，以优化查询性能
CREATE INDEX idx_bridge_state_abbr ON dim_customer_location_bridge(location_state_abbr);
CREATE INDEX idx_bridge_customer_key ON dim_customer_location_bridge(customer_key);
CREATE INDEX idx_bridge_account_key ON dim_customer_location_bridge(account_key);


-- =================================================================
-- 步骤 1.1: 填充桥梁表 (ETL 过程)
--
-- 目的:
-- 将业务数据源 (`CustomerAddress` 和 `Account`) 的数据加载到新的桥梁表中。
-- 这应该是一个定期的 ETL (提取、转换、加载) 任务。
-- =================================================================

-- 从 CustomerAddress 表加载客户位置数据
INSERT INTO dim_customer_location_bridge (customer_key, account_key, location_state_abbr, record_type)
SELECT
    DISTINCT
    CONCAT(c.CustLastName, '|', c.CustFirstName, '|', c.CustDOB) AS customer_key,
    NULL AS account_key,
    ca.CustState AS location_state_abbr,
    'Customer' AS record_type
FROM
    Customer c
JOIN
    CustomerAddress ca ON c.CustLastName = ca.CustLastName
                      AND c.CustFirstName = ca.CustFirstName
                      AND c.CustDOB = ca.CustDOB
WHERE
    ca.CustState IS NOT NULL AND ca.CustState != ''
ON DUPLICATE KEY UPDATE
    last_updated = CURRENT_TIMESTAMP;


-- 从 Account 表加载账户位置数据
INSERT INTO dim_customer_location_bridge (customer_key, account_key, location_state_abbr, record_type)
SELECT
    DISTINCT
    NULL AS customer_key,
    CONCAT(a.AccountName, '|', a.CompanyCode, '|', a.LocationZip) AS account_key,
    a.LocationState AS location_state_abbr,
    'Account' AS record_type
FROM
    Account a
WHERE
    a.LocationState IS NOT NULL AND a.LocationState != ''
ON DUPLICATE KEY UPDATE
    last_updated = CURRENT_TIMESTAMP;


-- =================================================================
-- 步骤 2: 创建统一的地理维度视图 (Unified Location View)
--
-- 目的:
-- 创建一个视图，将慢性病数据库的 `dim_locations` 与我们新创建的桥梁表连接起来。
-- 这样，我们就有了一个统一的、包含所有州和相关客户/账户的地理维度。
-- =================================================================

CREATE OR REPLACE VIEW v_unified_location_dim AS
SELECT
    dl.location_id,
    dl.location_abbr,
    dl.location_desc,
    dclb.bridge_id,
    dclb.customer_key,
    dclb.account_key,
    dclb.record_type
FROM
    -- `us_chronic_disease` 数据库中的 locations 表
    analytics_db.dim_locations dl
JOIN
    -- 刚刚创建的桥梁表
    business_db.dim_customer_location_bridge dclb ON dl.location_abbr = dclb.location_state_abbr;

-- 注意: 上述查询中的 `analytics_db` 和 `business_db` 应替换为你的实际数据库名。


-- =================================================================
-- 步骤 3: 创建最终的分析视图 (Final Analysis View)
--
-- 目的:
-- 这是整合的最终成果。一个大宽表视图，将客户、账户、地理位置和慢性病指标全部连接在一起。
-- 分析师或 BI 工具可以直接查询这个视图，而无需关心背后复杂的数据库连接。
-- =================================================================

CREATE OR REPLACE VIEW v_customer_health_risk_analysis AS
SELECT
    -- 客户/账户信息
    loc.bridge_id,
    loc.record_type,
    COALESCE(cust.CustFirstName, acct.AccountName) AS primary_name,
    COALESCE(cust.CustLastName, acct.CompanyCode) AS secondary_name,
    cust.CustDOB,
    acct.NumberOfEmployees,

    -- 地理信息
    loc.location_id,
    loc.location_abbr AS state_abbr,
    loc.location_desc AS state_name,

    -- 慢性病指标信息
    obs.observation_id,
    obs.year_start,
    topic.topic_name,
    question.question_text,
    obs.data_value,
    obs.data_value_unit,
    strat.stratification_category,
    strat.stratification_name

FROM
    -- 统一地理视图
    v_unified_location_dim loc
JOIN
    -- 慢性病事实表
    analytics_db.fact_health_observations obs ON loc.location_id = obs.location_id
LEFT JOIN
    -- 客户表 (通过 customer_key 连接)
    business_db.Customer cust ON loc.customer_key = CONCAT(cust.CustLastName, '|', cust.CustFirstName, '|', cust.CustDOB) AND loc.record_type = 'Customer'
LEFT JOIN
    -- 账户表 (通过 account_key 连接)
    business_db.Account acct ON loc.account_key = CONCAT(acct.AccountName, '|', acct.CompanyCode, '|', acct.LocationZip) AND loc.record_type = 'Account'
LEFT JOIN
    -- 慢性病维度表
    analytics_db.dim_topics topic ON obs.topic_id = topic.topic_id
LEFT JOIN
    analytics_db.dim_questions question ON obs.question_id = question.question_id
LEFT JOIN
    analytics_db.dim_stratifications strat ON obs.stratification_id = strat.stratification_id;


-- =================================================================
-- 步骤 4: 查询示例 (Example Queries)
--
-- 目的:
-- 展示如何使用最终的分析视图来回答复杂的业务问题。
-- =================================================================

-- -- 查询 1: 查看加州 (CA) 的客户中，与“心血管疾病”相关的平均健康指标是多少？
-- SELECT
--     state_name,
--     topic_name,
--     AVG(data_value) AS average_indicator_value
-- FROM
--     v_customer_health_risk_analysis
-- WHERE
--     state_abbr = 'CA'
--     AND topic_name = 'Cardiovascular Disease'
--     AND record_type = 'Customer'
-- GROUP BY
--     state_name, topic_name;


-- -- 查询 2: 找出在“糖尿病”指标最高的五个州中，我们有多少个企业账户 (Accounts)？
-- SELECT
--     state_name,
--     COUNT(DISTINCT account_key) AS number_of_accounts,
--     AVG(avg_diabetes_rate) AS avg_state_diabetes_rate
-- FROM (
--     SELECT
--         state_name,
--         account_key,
--         AVG(data_value) OVER(PARTITION BY state_name) as avg_diabetes_rate
--     FROM
--         v_customer_health_risk_analysis
--     WHERE
--         topic_name = 'Diabetes'
--         AND record_type = 'Account'
-- ) AS subquery
-- GROUP BY
--     state_name
-- ORDER BY
--     avg_state_diabetes_rate DESC
-- LIMIT 5;

-- -- 查询 3: 对于每个州，列出我们的客户总数，以及该州“肥胖”问题的平均指标。
-- SELECT
--     state_name,
--     COUNT(DISTINCT customer_key) AS total_customers,
--     AVG(CASE WHEN topic_name = 'Obesity' THEN data_value ELSE NULL END) AS avg_obesity_indicator
-- FROM
--     v_customer_health_risk_analysis
-- WHERE
--     record_type = 'Customer'
-- GROUP BY
--     state_name
-- ORDER BY
--     total_customers DESC;

-- =================================================================
-- 实施建议
--
-- 1. 数据库用户权限: 确保执行此脚本的用户有权限在两个数据库之间进行 SELECT、CREATE TABLE 和 CREATE VIEW 操作。
-- 2. 数据库名称: 在执行前，请将脚本中的 `analytics_db` 和 `business_db` 替换为你的实际数据库名称。
-- 3. ETL 调度: `步骤 1.1` 中的 INSERT 语句应该被配置成一个定期的 ETL 作业（例如，每天或每周运行一次），以保持桥梁表的数据与业务数据同步。
-- =================================================================
