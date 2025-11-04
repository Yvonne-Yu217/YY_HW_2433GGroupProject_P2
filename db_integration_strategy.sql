-- =================================================================
-- 数据库整合策略：连接 EDA 业务数据与美国慢性病分析数据
-- 文件名: db_integration_strategy.sql
-- 作者: GitHub Copilot
-- 日期: 2025-11-04
--
-- 核心思路:
-- 通过地理位置（州）作为桥梁，将客户/账户数据与慢性病指标数据进行连接。
--
-- 策略步骤:
-- 1. 创建一个 "桥梁表" (dim_customer_location_bridge)，用于存储与分析相关的客户/账户位置信息。
-- 2. 创建一个 "统一地理视图" (v_unified_location_dim)，简化地理维度的关联。
-- 3. 创建一个 "最终分析视图" (v_customer_health_risk_analysis)，形成一个可供BI工具使用的大宽表。
--
-- 优点:
-- - 非侵入式设计：不修改任何现有的业务表或分析表。
-- - 性能优化：通过预计算的桥梁表和索引来加速查询。
-- - 易于使用：最终视图隐藏了复杂的连接逻辑，分析师可以直接使用。
-- =================================================================


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

-- 查询 1: 查看加州 (CA) 的客户中，与“心血管疾病”相关的平均健康指标是多少？
SELECT
    state_name,
    topic_name,
    AVG(data_value) AS average_indicator_value
FROM
    v_customer_health_risk_analysis
WHERE
    state_abbr = 'CA'
    AND topic_name = 'Cardiovascular Disease'
    AND record_type = 'Customer'
GROUP BY
    state_name, topic_name;


-- 查询 2: 找出在“糖尿病”指标最高的五个州中，我们有多少个企业账户 (Accounts)？
SELECT
    state_name,
    COUNT(DISTINCT account_key) AS number_of_accounts,
    AVG(avg_diabetes_rate) AS avg_state_diabetes_rate
FROM (
    SELECT
        state_name,
        account_key,
        AVG(data_value) OVER(PARTITION BY state_name) as avg_diabetes_rate
    FROM
        v_customer_health_risk_analysis
    WHERE
        topic_name = 'Diabetes'
        AND record_type = 'Account'
) AS subquery
GROUP BY
    state_name
ORDER BY
    avg_state_diabetes_rate DESC
LIMIT 5;

-- 查询 3: 对于每个州，列出我们的客户总数，以及该州“肥胖”问题的平均指标。
SELECT
    state_name,
    COUNT(DISTINCT customer_key) AS total_customers,
    AVG(CASE WHEN topic_name = 'Obesity' THEN data_value ELSE NULL END) AS avg_obesity_indicator
FROM
    v_customer_health_risk_analysis
WHERE
    record_type = 'Customer'
GROUP BY
    state_name
ORDER BY
    total_customers DESC;

-- =================================================================
-- 实施建议
--
-- 1. 数据库用户权限: 确保执行此脚本的用户有权限在两个数据库之间进行 SELECT、CREATE TABLE 和 CREATE VIEW 操作。
-- 2. 数据库名称: 在执行前，请将脚本中的 `analytics_db` 和 `business_db` 替换为你的实际数据库名称。
-- 3. ETL 调度: `步骤 1.1` 中的 INSERT 语句应该被配置成一个定期的 ETL 作业（例如，每天或每周运行一次），以保持桥梁表的数据与业务数据同步。
-- =================================================================
