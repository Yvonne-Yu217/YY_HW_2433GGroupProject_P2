-- 0) sanity: confirm DB
SELECT DB_NAME() AS current_db; -- should be HealthDW
GO

-- 1) Ensure schema + staging table exist
IF SCHEMA_ID(N'datalake') IS NULL
    EXEC('CREATE SCHEMA datalake;');
GO

IF OBJECT_ID(N'datalake.stg_us_chronic_disease_raw','U') IS NULL
BEGIN
    CREATE TABLE datalake.stg_us_chronic_disease_raw (
        YearStart                 NVARCHAR(50)    NULL,
        YearEnd                   NVARCHAR(50)    NULL,
        LocationAbbr              NVARCHAR(255)   NULL,
        LocationDesc              NVARCHAR(255)   NULL,
        DataSource                NVARCHAR(255)   NULL,
        Topic                     NVARCHAR(255)   NULL,
        Question                  NVARCHAR(2000)  NULL,
        Response                  NVARCHAR(255)   NULL,
        DataValueUnit             NVARCHAR(255)   NULL,
        DataValueType             NVARCHAR(255)   NULL,
        DataValue                 NVARCHAR(255)   NULL,
        DataValueAlt              NVARCHAR(255)   NULL,
        DataValueFootnoteSymbol   NVARCHAR(50)    NULL,
        DataValueFootnote         NVARCHAR(2000)  NULL,
        LowConfidenceLimit        NVARCHAR(255)   NULL,
        HighConfidenceLimit       NVARCHAR(255)   NULL,
        StratificationCategory1   NVARCHAR(255)   NULL,
        Stratification1           NVARCHAR(255)   NULL,
        StratificationCategory2   NVARCHAR(255)   NULL,
        Stratification2           NVARCHAR(255)   NULL,
        StratificationCategory3   NVARCHAR(255)   NULL,
        Stratification3           NVARCHAR(255)   NULL,
        Geolocation               NVARCHAR(255)   NULL,
        LocationID                NVARCHAR(50)    NULL,
        TopicID                   NVARCHAR(100)   NULL,
        QuestionID                NVARCHAR(100)   NULL,
        ResponseID                NVARCHAR(100)   NULL,
        DataValueTypeID           NVARCHAR(100)   NULL,
        StratificationCategoryID1 NVARCHAR(100)   NULL,
        StratificationID1         NVARCHAR(100)   NULL,
        StratificationCategoryID2 NVARCHAR(100)   NULL,
        StratificationID2         NVARCHAR(100)   NULL,
        StratificationCategoryID3 NVARCHAR(100)   NULL,
        StratificationID3         NVARCHAR(100)   NULL
    );
END
GO

-- 2) Master key (only once per DB)
IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = '123abc!!!';
END
GO

-- 3) Scoped credential (recreate to be safe)
IF EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = 'BlobSasCred')
    DROP DATABASE SCOPED CREDENTIAL BlobSasCred;
GO
CREATE DATABASE SCOPED CREDENTIAL BlobSasCred
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=r&st=2025-11-07T02:26:21Z&se=2025-11-27T10:41:21Z&spr=https&sv=2024-11-04&sr=b&sig=zB63QGKL9vx0EN5oFbjQxxNZOZ6grBpOCBJZwiAM9R4%3D';
GO

-- 4) External data source for your container
IF EXISTS (SELECT 1 FROM sys.external_data_sources WHERE name = 'MyBlob')
    DROP EXTERNAL DATA SOURCE MyBlob;
GO
CREATE EXTERNAL DATA SOURCE MyBlob
WITH (
    TYPE = BLOB_STORAGE,
    LOCATION = 'https://healthstorage2433.blob.core.windows.net/data', -- container URL
    CREDENTIAL = BlobSasCred
);
GO

-- 5) Bulk load from the blob (the file name must match exactly)
BULK INSERT datalake.stg_us_chronic_disease_raw
FROM 'U.S._Chronic_Disease_Indicators_20251105.csv'  -- path inside the container
WITH (
    DATA_SOURCE = 'MyBlob',
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    TABLOCK
);
GO

-- 6) Verify
SELECT COUNT(*) AS rows_loaded FROM datalake.stg_us_chronic_disease_raw;
SELECT TOP (5) * FROM datalake.stg_us_chronic_disease_raw;
