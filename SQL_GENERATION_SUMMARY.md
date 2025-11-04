# 📊 数据架构 SQL 生成总结

## 已生成的 SQL 文件

### 1️⃣ **`data_lake_us_chronic_disease_raw.sql`**
- **用途**：Data Lake 层 - 存储原始 CDC 慢性病指标数据
- **表名**：`stg_us_chronic_disease_raw`
- **特点**：
  - 与 CSV 完全一致的列结构（36 列）
  - 最小化数据转换，保留源数据完整性
  - 包含所有原始 ID 和字段用于审计追踪
  - 创建了 5 个查询优化索引

### 2️⃣ **`data_warehouse_normalized_schema.sql`**
- **用途**：Data Warehouse 层 - 规范化分析数据库
- **包含内容**：
  - 6 个维度表（Topics, Questions, Locations, Stratifications 等）
  - 1 个主要事实表（Health Observations）
  - 1 个临时 ETL 处理表
  - 8 个性能优化索引
  - ETL 处理的 SQL 伪代码示例
  - 分析查询示例

---

## 📐 数据流架构

```
CSV 数据源
     ↓
┌─────────────────────────────────────┐
│      Data Lake (STG)                │
│  stg_us_chronic_disease_raw         │
│  - 36 列，保留原始数据              │
│  - 最小转换                         │
└────────────┬────────────────────────┘
             ↓ ETL 清洗转换
┌─────────────────────────────────────┐
│    Data Warehouse (Normalized)      │
│  - dim_topics                       │
│  - dim_questions                    │
│  - dim_locations                    │
│  - dim_stratifications              │
│  - fact_health_observations         │
└────────────┬────────────────────────┘
             ↓ 分析查询
┌─────────────────────────────────────┐
│   分析与报表 (Analytics)             │
│  - 疾病趋势分析                     │
│  - 地区对比分析                     │
│  - 人口群体分析                     │
└─────────────────────────────────────┘
```

---

## 📋 主要表结构

### Data Lake 层 - 36 列原始数据
```
YearStart, YearEnd, LocationAbbr, LocationDesc
DataSource, Topic, Question, Response
DataValueUnit, DataValueType, DataValue, DataValueAlt
DataValueFootnoteSymbol, DataValueFootnote
LowConfidenceLimit, HighConfidenceLimit
StratificationCategory1-3, Stratification1-3
Geolocation, LocationID, TopicID, QuestionID, ResponseID
DataValueTypeID
StratificationCategoryID1-3, StratificationID1-3
```

### Data Warehouse 层 - 规范化表

#### 维度表
| 表名 | 用途 | 主键 |
|------|------|------|
| `dim_topics` | 健康主题 | topic_id |
| `dim_questions` | 具体问题/指标 | question_id |
| `dim_locations` | 地理位置（州/地区） | location_id |
| `dim_stratification_categories` | 分层类别（性别、年龄等） | stratif_category_id |
| `dim_stratifications` | 具体分层值 | stratification_id |
| `dim_data_value_types` | 数据值类型（%、count 等） | data_value_type_id |

#### 事实表
| 表名 | 用途 | 粒度 |
|------|------|------|
| `fact_health_observations` | 核心观察指标 | 每条观察记录 |

---

## 🔧 使用说明

### Step 1: 创建 Data Lake 表
```bash
# 使用对应的数据库工具执行
mysql < data_lake_us_chronic_disease_raw.sql
# 或
psql < data_lake_us_chronic_disease_raw.sql
```

### Step 2: 加载原始数据
```sql
-- MySQL
LOAD DATA LOCAL INFILE '/path/to/U.S._Chronic_Disease_Indicators_20251102.csv'
INTO TABLE stg_us_chronic_disease_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

### Step 3: 创建规范化表
```bash
mysql < data_warehouse_normalized_schema.sql
```

### Step 4: 执行 ETL（从 Data Lake 到 Data Warehouse）
在 `data_warehouse_normalized_schema.sql` 中有详细的 ETL SQL 伪代码，可根据实际需求调整并执行。

---

## 📊 数据质量指标

- **总记录数**：原始 CSV 中的所有行
- **列数**：36 列（对应 CSV 的所有字段）
- **主键**：每个表都有明确的主键以保证数据完整性
- **外键**：事实表与所有维度表都有外键关联
- **索引**：优化查询性能的 13+ 个索引

---

## 💡 最佳实践

1. **Data Lake** 保持原始数据，不做修改
2. **ETL 过程**中进行数据清洗和验证
3. **Data Warehouse** 采用星型模式便于分析
4. 定期检查数据完整性和准确性
5. 为常见查询创建视图或汇总表

---

## 📝 相关文件

- `data_lake_us_chronic_disease_raw.sql` - Data Lake DDL
- `data_warehouse_normalized_schema.sql` - Data Warehouse DDL
- `us_chronic_disease_data_analysis.ipynb` - 数据分析和 SQL 生成代码
- `chronic_disease_db_schema.sql` - 原始设计（参考）

---

**生成日期**: 2025-11-04  
**数据源**: U.S. CDC Chronic Disease Indicators
