# Database Integration Project: EDA Business Data & US Chronic Disease Analytics

## Project Overview

This project implements a comprehensive database integration solution that connects enterprise business data (EDA schema) with public health analytics data (US Chronic Disease Indicators). The implementation is designed for **Azure SQL Database** and follows a three-tier architecture: operational data (OLTP), analytical data warehouse (OLAP), and an integration layer that bridges both systems for advanced business intelligence.

**Key Achievement:** Successfully integrates disparate data sources using geographic location (US states) as the common dimension, enabling health risk analysis for customers and business accounts across different states.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure SQL Database                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  eda schema  │  │  dw schema   │  │ integration  │      │
│  │   (OLTP)     │  │   (OLAP)     │  │   schema     │      │
│  │              │  │              │  │              │      │
│  │ • Customer   │  │ • DimTopics  │  │ • Bridge     │      │
│  │ • Account    │  │ • DimLocations│ │   Table      │      │
│  │ • Contract   │  │ • FactHealth │  │ • Unified    │      │
│  │ • 100+ tables│  │   Observations│ │   Views      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                  │              │
│         └──────────────────┴──────────────────┘              │
│                            │                                 │
│                    Geographic Bridge                         │
│                   (State-level linking)                      │
└─────────────────────────────────────────────────────────────┘
```

---

## SQL Files and Execution Order

### 1. **`EDA_AzureSQL.sql`** ⭐ (Primary Business Schema)

**Purpose:**
- Complete DDL (Data Definition Language) for the EDA operational database
- Defines 100+ tables covering the entire business domain:
  - **Customer Management**: Customer, CustomerAddress, CustomerAlias, CustomerRelation
  - **Account Management**: Account, AccountRelation, BillingAccount
  - **Product Catalog**: Product, ProductSeries, ProductPlan, ProductRider
  - **Contracts & Policies**: Contract, LifePolicy, AHPolicy, FLEXAgreement
  - **Claims Processing**: Claim, Claimant, ClaimNote, ClaimImage
  - **Financial Operations**: Invoice, InvoiceDetail, Remittance, Premium
  - **Organizational Structure**: Territory, State, District, Region, Associate
  - **Supporting Entities**: Contest, Material, License, WritingNumber

**Key Features:**
- Azure SQL compatible syntax (T-SQL)
- Uses `IDENTITY(1,1)` for auto-increment columns
- All text fields use `NVARCHAR(MAX)` for Unicode support
- Comprehensive foreign key relationships with proper referential integrity
- Unified field lengths across all tables (e.g., all person names are `VARCHAR(100)`)

**When to Execute:**
- **First** - This is the foundation of the entire system
- Creates the `eda` schema with all business tables

**Command:**
```bash
sqlcmd -S <server>.database.windows.net -U <username> -P <password> \
  -d <database> -i EDA_AzureSQL.sql -b -l 300
```

---

### 2. **`data_warehouse_normalized_schema_t.sql`** (Analytics Schema)

**Purpose:**
- Implements a **star schema** data warehouse for US Chronic Disease Indicators
- Transforms raw CSV data into a normalized, query-optimized structure

**Schema Components:**

**Dimension Tables:**
- `dw.DimTopics` - Health topics (Diabetes, Cardiovascular Disease, Obesity, etc.)
- `dw.DimQuestions` - Specific health indicators and metrics
- `dw.DimLocations` - Geographic locations (US states and territories)
- `dw.DimStratifications` - Data stratification categories (Age, Gender, Race, etc.)
- `dw.DimStratificationCategories` - Stratification groupings
- `dw.DimDataValueTypes` - Types of measurements (Percentage, Rate, Number, etc.)

**Fact Table:**
- `dw.FactHealthObservations` - Central fact table containing:
  - Health indicator measurements
  - Time dimensions (YearStart, YearEnd)
  - Foreign keys to all dimension tables
  - Statistical measures (DataValue, ConfidenceIntervals)

**ETL Process:**
1. Loads raw data from staging table
2. Populates dimension tables with distinct values
3. Creates surrogate keys for efficient joins
4. Loads fact table with foreign key references

**When to Execute:**
- **Second** - After EDA schema is created
- Creates the `dw` schema for analytics

**Command:**
```bash
sqlcmd -S <server>.database.windows.net -U <username> -P <password> \
  -d <database> -i data_warehouse_normalized_schema_t.sql -b -l 300
```

---

### 3. **`db_integration_strategy.sql`** 🔗 (Integration Layer)

**Purpose:**
- **Core Innovation**: Bridges operational business data with public health analytics
- Enables cross-domain analysis by linking customers/accounts to health risk indicators

**Integration Architecture:**

#### **Step 1: Bridge Table Creation**
```sql
integration.CustomerLocationBridge
├── BridgeID (Primary Key)
├── CustomerKey (Composite: LastName|FirstName|MI|Suffix|DOB)
├── AccountKey (Composite: AccountName|Address|City|State|Zip|Code)
├── StateCode (2-letter state abbreviation: 'CA', 'NY', etc.)
└── RecordType ('Customer' or 'Account')
```

**Design Rationale:**
- **Non-invasive**: Doesn't modify existing business or analytics tables
- **Performance**: Pre-computed bridge eliminates expensive joins at query time
- **Scalability**: Indexed on all key columns for fast lookups
- **Flexibility**: Supports both customer-level and account-level analysis

**ETL Logic:**
```sql
-- Extract customer locations from CustomerAddress
INSERT INTO integration.CustomerLocationBridge
SELECT 
    CONCAT(LastName, '|', FirstName, '|', MI, '|', Suffix, '|', DOB),
    NULL,
    CustState,
    'Customer'
FROM eda.Customer c
JOIN eda.CustomerAddress ca ON [composite key match]

-- Extract account locations from Account table
INSERT INTO integration.CustomerLocationBridge
SELECT 
    NULL,
    CONCAT(AccountName, '|', Address, '|', City, '|', State, '|', Zip, '|', Code),
    LocationState,
    'Account'
FROM eda.Account
```

#### **Step 2: Unified Location View**
```sql
integration.vw_UnifiedLocationDim
```
- Joins `dw.DimLocations` with `CustomerLocationBridge`
- Creates a unified geographic dimension with customer/account associations
- Enables seamless navigation between business entities and health data

#### **Step 3: Final Analysis View (BI Wide Table)**
```sql
integration.vw_CustomerHealthRiskAnalysis
```

**Comprehensive View Structure:**
- **Business Context**: Customer demographics, account details
- **Geographic Context**: State information, geolocation
- **Health Indicators**: Disease prevalence, risk factors, trends
- **Temporal Context**: Multi-year health data trends
- **Stratification**: Age groups, gender, race/ethnicity breakdowns

**Sample Columns:**
```
Customer Info:
- CustFirstName, CustLastName, CustDOB, CustomerGender

Account Info:
- AccountName, AccountCity, NumberOfEmployees, CompanyCode

Health Metrics:
- TopicName (e.g., "Diabetes", "Cardiovascular Disease")
- QuestionText (e.g., "Prevalence of diagnosed diabetes")
- DataValue (numeric indicator value)
- YearStart, YearEnd (temporal dimension)
- StratificationValue (e.g., "Male", "Female", "Age 18-24")

Geographic:
- StateName, StateCode, Geolocation
```

#### **Integration Use Cases:**

**1. Customer Health Risk Profiling**
```sql
-- Identify customers in high-risk states
SELECT 
    StateName,
    COUNT(DISTINCT CustomerKey) AS TotalCustomers,
    AVG(CASE WHEN TopicName = 'Diabetes' THEN DataValue END) AS AvgDiabetesRate
FROM integration.vw_CustomerHealthRiskAnalysis
WHERE RecordType = 'Customer'
GROUP BY StateName
ORDER BY AvgDiabetesRate DESC;
```

**2. Account-Level Risk Assessment**
```sql
-- Analyze health risks for employer accounts
SELECT 
    AccountName,
    StateName,
    NumberOfEmployees,
    AVG(DataValue) AS AvgHealthRisk
FROM integration.vw_CustomerHealthRiskAnalysis
WHERE RecordType = 'Account'
  AND TopicName IN ('Cardiovascular Disease', 'Diabetes', 'Obesity')
GROUP BY AccountName, StateName, NumberOfEmployees;
```

**3. Geographic Market Analysis**
```sql
-- Top 5 states with highest disease burden and our market presence
WITH StateRisk AS (
    SELECT 
        StateCode,
        StateName,
        AVG(DataValue) AS AvgRiskScore,
        COUNT(DISTINCT AccountKey) AS AccountCount
    FROM integration.vw_CustomerHealthRiskAnalysis
    WHERE TopicName = 'Cardiovascular Disease'
    GROUP BY StateCode, StateName
)
SELECT TOP 5 *
FROM StateRisk
ORDER BY AvgRiskScore DESC;
```

**When to Execute:**
- **Third** - After both `eda` and `dw` schemas are populated
- Creates the `integration` schema

**Command:**
```bash
sqlcmd -S <server>.database.windows.net -U <username> -P <password> \
  -d <database> -i db_integration_strategy.sql -b -l 300
```

---

### 4. **`create_data_lake_us_chronic_disease.sql`** (Data Staging)

**Purpose:**
- Creates staging table for raw CSV data import
- Preserves all 36 original columns from the CDC dataset
- Serves as the source for ETL into the data warehouse

**When to Execute:**
- Before loading CSV data
- Can be executed before or after EDA schema creation

---

### 5. **`etl_chronic_disease.py`** (Optional Automation)

**Purpose:**
- Python script for automated ETL operations
- Handles data cleaning, validation, and transformation
- Useful for scheduled data refreshes

---

## Complete Deployment Workflow

### Prerequisites
- Azure SQL Database instance
- SQL Server command-line tools (`sqlcmd`)
- Database credentials with appropriate permissions

### Step-by-Step Execution

```bash
# Set connection variables
SERVER="your-server.database.windows.net"
USER="your-username"
PASS="your-password"
DB="your-database"

# Step 1: Create EDA business schema (100+ tables)
sqlcmd -S $SERVER -U $USER -P $PASS -d $DB \
  -i EDA_AzureSQL.sql -b -l 300

# Step 2: Create data warehouse schema
sqlcmd -S $SERVER -U $USER -P $PASS -d $DB \
  -i data_warehouse_normalized_schema_t.sql -b -l 300

# Step 3: Load CSV data (use Azure Data Studio or bulk insert)
# ... import U.S._Chronic_Disease_Indicators_20251105.csv ...

# Step 4: Create integration layer
sqlcmd -S $SERVER -U $USER -P $PASS -d $DB \
  -i db_integration_strategy.sql -b -l 300

# Step 5: Verify integration
sqlcmd -S $SERVER -U $USER -P $PASS -d $DB \
  -Q "SELECT COUNT(*) FROM integration.CustomerLocationBridge"
```

---

## Key Technical Achievements

### 1. **Azure SQL Compatibility**
- All MySQL-specific syntax converted to T-SQL
- `AUTO_INCREMENT` → `IDENTITY(1,1)`
- `TEXT` → `NVARCHAR(MAX)`
- `BOOLEAN` → `BIT`
- Proper use of `GO` batch separators

### 2. **Data Integrity**
- Comprehensive foreign key constraints
- Unified field lengths across all tables
- Proper handling of composite primary keys
- Referential integrity maintained throughout

### 3. **Performance Optimization**
- Strategic indexing on bridge table (5 indexes)
- Filtered indexes for NULL-handling
- Composite index for uniqueness checks
- Pre-computed bridge table reduces query complexity

### 4. **Scalability**
- Schema-based organization (`eda`, `dw`, `integration`)
- Modular design allows independent updates
- View-based abstraction layer
- ETL-friendly architecture

---

## Business Value

### **For Healthcare Providers:**
- Identify high-risk customer populations by geographic region
- Target preventive care programs based on state-level health trends
- Optimize resource allocation for disease management

### **For Insurance Companies:**
- Risk assessment at customer and account levels
- Geographic market analysis for expansion decisions
- Actuarial modeling with integrated health indicators

### **For Employers (Accounts):**
- Understand employee health risks based on location
- Benchmark against state-level health statistics
- Design targeted wellness programs

---

## Project Compliance

This implementation fulfills the requirements of **Session 7 - Project Part 2 Specification**:

✅ **Data Integration**: Successfully bridges operational and analytical data  
✅ **Geographic Linking**: Uses state-level geography as integration key  
✅ **Star Schema**: Implements proper dimensional modeling  
✅ **ETL Process**: Includes data transformation and loading logic  
✅ **Query Examples**: Provides practical BI queries  
✅ **Azure SQL**: Fully compatible with cloud database platform  
✅ **Documentation**: Comprehensive inline comments and README  

---

## Troubleshooting

### Common Issues:

**1. Foreign Key Constraint Errors**
- Ensure field lengths match between referencing and referenced tables
- All person names: `VARCHAR(100)`
- All account names: `VARCHAR(80)`
- All location fields: consistent lengths

**2. Index Creation Failures**
- Verify `SET QUOTED_IDENTIFIER ON` for filtered indexes
- Check index key length doesn't exceed 1700 bytes

**3. Cross-Schema Queries**
- Ensure all schemas exist in the same database
- Use proper schema prefixes: `eda.TableName`, `dw.TableName`

---

## Additional Resources

## Repository updates (Nov 2025)

Recent commits added several helper and deployment scripts to streamline schema conversion and Azure deployment. Key new files and purpose:

- `eda_mssql_safe.sql` / `eda_mssql_tables_only.sql` / `eda_mssql_fks.sql` - Safe, schema-specific T-SQL variants split so you can create tables first and apply foreign keys later.
- `EDA_AzureSQL.sql` - Primary converted DDL (full EDA schema) targeted at Azure SQL.
- `drop_dbo_tables.sql`, `drop_eda_prefixed_tables.sql`, `drop_integration_prefixed_tables.sql` - Destructive, audited scripts to drop sets of tables (drops foreign keys first). Use with caution; intended for controlled cleanup in test environments.
- `db_integration_strategy_mysql_backup.sql` - Backup of MySQL-style DDL before conversion.
- `CONVERSION_SUMMARY.md` and `CONVERSION_SUMMARY` files - Notes on conversion decisions (types, AUTO_INCREMENT -> IDENTITY, TEXT -> NVARCHAR(MAX), boolean -> BIT, etc.).

Usage notes:
- Always review the "safe" variants before running on production. The `*_tables_only.sql` files will create table skeletons without FK constraints; run `*_fks.sql` afterwards.
- For Azure SQL execution use `sqlcmd -S <server> -U <user> -P <pwd> -d <db> -i <file> -b -l 300`.
- Scripts that drop tables are destructive. Keep backups and/or export data before running.

If you want, I can create a short release note or a dedicated `DEPLOYMENT.md` summarizing the exact steps and commands used during the recent deployment activity.

- **EDA Schema**: 100+ tables, ~3,200 lines of DDL
- **Data Warehouse**: Star schema with 6 dimensions + 1 fact table
- **Integration Layer**: 1 bridge table + 2 views
- **Sample Queries**: 4 comprehensive BI examples included

---

## Contact & Support

For questions about this implementation, refer to:
- Inline SQL comments (comprehensive documentation)
- Example queries in `db_integration_strategy.sql`
- Session 7 project specification document

---

**Last Updated**: November 9, 2025  
**Platform**: Azure SQL Database  
**Schema Version**: 2.0 (Azure SQL Compatible)
