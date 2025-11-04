# Project SQL Files Overview

This README provides an overview and recommended reading order for the key SQL files in this project. The structure and workflow are designed to meet the requirements of Session 7 - Project Part 2 Specification.

## SQL Files and Their Purpose

### 1. `EDAFromP1.sql`
- **Purpose:**
  - Contains the full DDL for the EDA (OLTP/business) database, including all customer, account, address, product, and geographic tables.
  - This is the foundational schema for your business data and will be referenced by all subsequent integration and analytics steps.
- **When to Read/Use:**
  - Start here. Review this file to understand the business data model and to create the EDA database in your RDBMS.

### 2. `data_lake_us_chronic_disease_raw.sql`
- **Purpose:**
  - Defines the staging (data lake) table for the US Chronic Disease Indicators dataset.
  - The table structure matches the raw CSV file, preserving all 36 columns for audit and traceability.
- **When to Read/Use:**
  - After setting up the EDA schema, use this file to create the data lake table for loading the chronic disease CSV data.

### 3. `data_warehouse_normalized_schema.sql`
- **Purpose:**
  - Defines the star schema for the analytical data warehouse.
  - Includes dimension tables (topics, questions, locations, stratifications, data value types) and the main fact table for health observations.
  - Contains ETL SQL examples for transforming and loading data from the data lake into the warehouse.
- **When to Read/Use:**
  - After loading the raw data, use this file to create the analytical schema and to understand the transformation logic.

### 4. `db_integration_strategy.sql`
- **Purpose:**
  - Provides the integration strategy and SQL code to connect the EDA (business) database with the chronic disease analytics database.
  - Introduces a bridge table and unified views to enable cross-database analysis, using geographic (state) information as the key link.
  - Includes example queries for business intelligence and reporting.
- **When to Read/Use:**
  - After both the EDA and analytics schemas are in place, use this file to implement the integration and enable advanced analytics.

### 5. (Optional) `etl_chronic_disease.py`
- **Purpose:**
  - Python script for automating the ETL process: loading, cleaning, and transforming the chronic disease data.
  - Not a SQL file, but referenced in the workflow for data preparation.
- **When to Read/Use:**
  - Use as needed to automate or validate the ETL steps described in the SQL files.

## Recommended Reading and Execution Order

1. **`EDAFromP1.sql`**  
   _→ Review and execute to create the business (OLTP) database._
2. **`data_lake_us_chronic_disease_raw.sql`**  
   _→ Create the data lake table and load the raw chronic disease CSV data._
3. **`data_warehouse_normalized_schema.sql`**  
   _→ Create the analytical warehouse schema and perform ETL from the data lake._
4. **`db_integration_strategy.sql`**  
   _→ Implement the integration bridge and unified views for cross-database analytics._
5. **(Optional) `etl_chronic_disease.py`**  
   _→ Use for automated ETL and data validation._

## Notes
- Make sure to adjust database and schema names in the SQL files as needed for your environment.
- Follow the example queries in `db_integration_strategy.sql` to validate your integration and begin analysis.
- For detailed requirements and deliverables, refer to the Session 7 - Project Part 2 Specification PDF.

---

**This workflow ensures a clean separation between business data, raw external data, analytical models, and integration logic, supporting robust and scalable analytics as required by the project specification.**
