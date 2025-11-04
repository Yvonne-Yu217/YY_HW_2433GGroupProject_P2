# 🚀 快速参考 - SQL 生成与使用

## 📌 核心问题解答

### Q1: CSV 数据如何加载到 Data Lake？

**A**: 三个步骤：

```bash
# 1️⃣  创建 Data Lake 表
mysql < data_lake_us_chronic_disease_raw.sql

# 2️⃣  运行 Python ETL 脚本进行数据验证
python etl_chronic_disease.py

# 3️⃣  使用 SQL 加载数据
mysql << EOF
LOAD DATA LOCAL INFILE '/path/to/data/U.S._Chronic_Disease_Indicators_20251102.csv'
INTO TABLE stg_us_chronic_disease_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
EOF
```

---

### Q2: Data Lake 和 Data Warehouse 的区别是什么？

| 特性 | Data Lake | Data Warehouse |
|------|-----------|-----------------|
| 目的 | 存储原始数据 | 用于分析的规范化数据 |
| 处理 | 最小转换 | 清洗 + 转换 + 规范化 |
| 模式 | 平面表（36列） | 星型模式（7个表） |
| 用途 | 审计、追踪、数据备份 | 分析查询、报表、BI |
| 表名前缀 | `stg_` | `dim_`, `fact_` |

---

### Q3: 生成的 SQL 文件有哪些？

| 文件名 | 行数 | 表数 | 用途 |
|--------|------|------|------|
| `data_lake_us_chronic_disease_raw.sql` | ~60 | 1 | Data Lake 定义 |
| `data_warehouse_normalized_schema.sql` | ~400 | 8 | Data Warehouse 定义 |
| `chronic_disease_db_schema.sql` | ~100 | 6 | 原始设计（参考） |

---

### Q4: 如何从 Data Lake 加载数据到 Data Warehouse？

**A**: 执行以下 SQL（在 `data_warehouse_normalized_schema.sql` 中的"第四部分"）：

```sql
-- 1. 加载维度表
INSERT INTO dim_topics (topic_name, topic_code)
SELECT DISTINCT Topic, TopicID
FROM stg_us_chronic_disease_raw;

INSERT INTO dim_questions (question_text, question_code, topic_id)
SELECT DISTINCT q.Question, q.QuestionID, t.topic_id
FROM stg_us_chronic_disease_raw q
JOIN dim_topics t ON q.Topic = t.topic_name;

-- ... 其他维度表类似

-- 2. 加载事实表
INSERT INTO fact_health_observations (...)
SELECT ... FROM stg_us_chronic_disease_raw r
JOIN dim_topics t ON r.Topic = t.topic_name
JOIN dim_questions q ON r.Question = q.question_text
-- ... 其他 JOIN
```

---

### Q5: 如何查询已加载的数据？

**A**: 星型模式查询示例：

```sql
-- 查询：2023年加州的糖尿病患病率
SELECT
    l.location_desc AS 州,
    q.question_text AS 指标,
    ROUND(AVG(f.data_value), 2) AS 平均率,
    COUNT(*) AS 记录数
FROM fact_health_observations f
JOIN dim_locations l ON f.location_id = l.location_id
JOIN dim_questions q ON f.question_id = q.question_id
WHERE q.question_text LIKE '%Diabetes%'
  AND l.location_abbr = 'CA'
  AND f.year_start = 2023
GROUP BY l.location_desc, q.question_text
ORDER BY ROUND(AVG(f.data_value), 2) DESC;
```

---

## 📂 文件导航

```
项目根目录/
│
├── 【SQL 架构文件】
│   ├── data_lake_us_chronic_disease_raw.sql (✨ 新建)
│   ├── data_warehouse_normalized_schema.sql (✨ 新建)
│   └── chronic_disease_db_schema.sql (参考)
│
├── 【Python 脚本】
│   ├── etl_chronic_disease.py (✨ 新建)
│   └── us_chronic_disease_data_analysis.ipynb (已更新)
│
├── 【文档】
│   ├── FILE_MANIFEST.md (✨ 新建 - 这个文件)
│   ├── SQL_GENERATION_SUMMARY.md (✨ 新建)
│   └── QUICKSTART.md (✨ 新建 - 你正在读这个)
│
└── 【数据】
    └── data/
        └── U.S._Chronic_Disease_Indicators_20251102.csv
```

---

## ⚡ 5 分钟快速开始

### 前提：已有 MySQL 数据库

```bash
# 1. 查看数据
head -5 data/U.S._Chronic_Disease_Indicators_20251102.csv

# 2. 创建 Data Lake
mysql -u root -p < data_lake_us_chronic_disease_raw.sql

# 3. 验证数据质量
python etl_chronic_disease.py

# 4. 创建 Data Warehouse
mysql -u root -p < data_warehouse_normalized_schema.sql

# 5. 运行示例查询
mysql -u root -p -e "SELECT * FROM dim_topics LIMIT 5;"
```

---

## 🎯 数据架构概览

```
CSV (36列)
    ↓ ✅ 自动生成
Data Lake (STG 表，36列)
    ↓ ETL 清洗
Data Warehouse (星型模式)
    ├─ dim_topics (23 个主题)
    ├─ dim_questions (152 个问题)
    ├─ dim_locations (56 个地区)
    ├─ dim_stratifications (人口群体)
    ├─ dim_data_value_types (数据类型)
    └─ fact_health_observations (100K+ 观察)
    ↓ 查询
📊 分析报表
```

---

## 🔑 关键概念

### Data Lake (数据湖)
- **表**：`stg_us_chronic_disease_raw`
- **特点**：原始数据 + 最小处理
- **用途**：数据备份、审计、数据追踪
- **大小**：单表，所有列平面化

### Data Warehouse (数据仓库)
- **设计**：星型模式 (Star Schema)
- **特点**：规范化 + 优化查询性能
- **用途**：业务分析、BI 报表
- **结构**：维度表 + 事实表

### 维度表 (Dimension Tables)
- 存储"是什么"的信息
- 例如：什么主题、什么地区、什么年份
- 相对小，更新频率低

### 事实表 (Fact Tables)
- 存储"多少"的信息  
- 例如：患病率、确诊数等具体数值
- 相对大，外键指向维度表

---

## 🔍 SQL 文件对比

### data_lake_us_chronic_disease_raw.sql

```sql
CREATE TABLE stg_us_chronic_disease_raw (
    YearStart INT,
    YearEnd INT,
    LocationAbbr VARCHAR(255),
    LocationDesc VARCHAR(255),
    Topic VARCHAR(255),
    Question VARCHAR(255),
    DataValue VARCHAR(255),
    ... (+ 28 more columns)
);
-- 特点：完全平面化，保留所有原始列
```

### data_warehouse_normalized_schema.sql

```sql
-- 维度表
CREATE TABLE dim_topics (
    topic_id INT PRIMARY KEY,
    topic_name VARCHAR(255) NOT NULL UNIQUE,
    ...
);

-- 事实表
CREATE TABLE fact_health_observations (
    observation_id BIGINT PRIMARY KEY,
    topic_id INT NOT NULL,              -- FK
    question_id INT NOT NULL,           -- FK
    location_id INT NOT NULL,           -- FK
    data_value DECIMAL(18, 4),
    ...
);
-- 特点：规范化，外键关联，优化查询
```

---

## 📊 数据统计预览

```
原始 CSV：
  行数：100,000+
  列数：36
  大小：~50-100 MB

Data Lake 表：
  行数：100,000+ (相同)
  列数：36 (相同)
  索引：5 个

Data Warehouse：
  维度表总行数：~300 (汇总)
  事实表行数：100,000+
  索引：13+ 个
  存储：更高效（规范化）
```

---

## ✨ 已自动生成的优化

1. ✅ 36 列完整的 SQL 类型定义
2. ✅ 自动转换 VARCHAR → DECIMAL（数值列）
3. ✅ 自动转换 OBJECT → VARCHAR（文本列）
4. ✅ 5 + 13 = 18 个查询优化索引
5. ✅ 完整的外键关系定义
6. ✅ Python ETL 验证脚本
7. ✅ ETL 伪代码示例
8. ✅ 分析查询示例

---

## 🎓 学习路径

**初学者**：
1. 读这个 QUICKSTART.md
2. 阅读 SQL_GENERATION_SUMMARY.md
3. 查看 FILE_MANIFEST.md 的架构图

**中级**：
1. 运行 etl_chronic_disease.py 理解 ETL 流程
2. 执行 SQL 文件创建表
3. 修改查询示例进行分析

**高级**：
1. 优化索引和查询性能
2. 添加增量加载逻辑
3. 实现元数据管理

---

## 🆘 常见命令

```bash
# 查看表结构
mysql -u root -p -e "DESC stg_us_chronic_disease_raw;"

# 查看数据样本
mysql -u root -p -e "SELECT * FROM fact_health_observations LIMIT 5;"

# 查看索引
mysql -u root -p -e "SHOW INDEXES FROM fact_health_observations;"

# 查看表大小
mysql -u root -p -e "SELECT table_name, ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb FROM information_schema.tables WHERE table_schema = 'your_db';"
```

---

**✅ 一切准备就绪！现在就可以开始构建数据仓库了！**
