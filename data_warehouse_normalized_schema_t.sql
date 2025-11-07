/* =========================
   Data Warehouse (T-SQL)
   Target DB: HealthDW
   ========================= */

-- 0) Make sure we're in the right DB
SELECT DB_NAME() AS current_db;
GO

/* 1) Schemas */
IF SCHEMA_ID(N'dw') IS NULL EXEC('CREATE SCHEMA dw;');
GO

/* 2) Drop in dependency order */
IF OBJECT_ID('dw.FactHealthObservations','U') IS NOT NULL DROP TABLE dw.FactHealthObservations;
IF OBJECT_ID('dw.StgDataCleaning','U')         IS NOT NULL DROP TABLE dw.StgDataCleaning;
IF OBJECT_ID('dw.DimStratifications','U')      IS NOT NULL DROP TABLE dw.DimStratifications;
IF OBJECT_ID('dw.DimStratificationCategories','U') IS NOT NULL DROP TABLE dw.DimStratificationCategories;
IF OBJECT_ID('dw.DimDataValueTypes','U')       IS NOT NULL DROP TABLE dw.DimDataValueTypes;
IF OBJECT_ID('dw.DimQuestions','U')            IS NOT NULL DROP TABLE dw.DimQuestions;
IF OBJECT_ID('dw.DimTopics','U')               IS NOT NULL DROP TABLE dw.DimTopics;
IF OBJECT_ID('dw.DimLocations','U')            IS NOT NULL DROP TABLE dw.DimLocations;
GO

/* 3) Dimension tables */

-- Topics
CREATE TABLE dw.DimTopics (
  TopicID     INT IDENTITY(1,1) PRIMARY KEY,
  TopicName   NVARCHAR(255) NOT NULL UNIQUE,
  TopicCode   NVARCHAR(50)  NULL,
  CreatedAt   DATETIME2(3)  NOT NULL CONSTRAINT DF_DimTopics_CreatedAt DEFAULT SYSUTCDATETIME()
);

-- Questions
CREATE TABLE dw.DimQuestions (
  QuestionID   INT IDENTITY(1,1) PRIMARY KEY,
  QuestionText NVARCHAR(500) NOT NULL UNIQUE,
  QuestionCode NVARCHAR(100) NULL,
  TopicID      INT NOT NULL,
  CreatedAt    DATETIME2(3) NOT NULL CONSTRAINT DF_DimQuestions_CreatedAt DEFAULT SYSUTCDATETIME(),
  CONSTRAINT FK_DimQuestions_Topic FOREIGN KEY (TopicID) REFERENCES dw.DimTopics(TopicID)
);

-- Locations
CREATE TABLE dw.DimLocations (
  LocationID    INT IDENTITY(1,1) PRIMARY KEY,
  LocationAbbr  NVARCHAR(10) NOT NULL UNIQUE,
  LocationDesc  NVARCHAR(255) NOT NULL,
  LocationType  NVARCHAR(50) NULL,
  Geolocation   NVARCHAR(255) NULL,
  CreatedAt     DATETIME2(3) NOT NULL CONSTRAINT DF_DimLocations_CreatedAt DEFAULT SYSUTCDATETIME()
);

-- Stratification Categories
CREATE TABLE dw.DimStratificationCategories (
  StratifCategoryID INT IDENTITY(1,1) PRIMARY KEY,
  CategoryName      NVARCHAR(100) NOT NULL UNIQUE,
  CategoryDescription NVARCHAR(MAX) NULL,
  CreatedAt         DATETIME2(3) NOT NULL CONSTRAINT DF_DimSC_CreatedAt DEFAULT SYSUTCDATETIME()
);

-- Stratification Values
CREATE TABLE dw.DimStratifications (
  StratificationID   INT IDENTITY(1,1) PRIMARY KEY,
  StratifCategoryID  INT NOT NULL,
  StratificationValue NVARCHAR(200) NOT NULL,
  CreatedAt          DATETIME2(3) NOT NULL CONSTRAINT DF_DimS_CreatedAt DEFAULT SYSUTCDATETIME(),
  CONSTRAINT UQ_DimStrat UNIQUE (StratifCategoryID, StratificationValue),
  CONSTRAINT FK_DimStrat_Cat FOREIGN KEY (StratifCategoryID) REFERENCES dw.DimStratificationCategories(StratifCategoryID)
);

-- Data Value Types
CREATE TABLE dw.DimDataValueTypes (
  DataValueTypeID INT IDENTITY(1,1) PRIMARY KEY,
  TypeName        NVARCHAR(100) NOT NULL UNIQUE,
  UnitOfMeasure   NVARCHAR(50)  NULL,
  CreatedAt       DATETIME2(3)  NOT NULL CONSTRAINT DF_DimDVT_CreatedAt DEFAULT SYSUTCDATETIME()
);

-- Staging/ETL helper
CREATE TABLE dw.StgDataCleaning (
  RecordID           BIGINT IDENTITY(1,1) PRIMARY KEY,
  OriginalRecordID   BIGINT NULL,
  YearStart          INT    NULL,
  YearEnd            INT    NULL,
  LocationAbbr       NVARCHAR(10)  NULL,
  LocationDesc       NVARCHAR(255) NULL,
  Topic              NVARCHAR(255) NULL,
  Question           NVARCHAR(500) NULL,
  DataValue          DECIMAL(18,4) NULL,
  DataValueType      NVARCHAR(100) NULL,
  IsValid            BIT NOT NULL CONSTRAINT DF_Stg_IsValid DEFAULT (1),
  ValidationErrorMsg NVARCHAR(MAX) NULL,
  ProcessedAt        DATETIME2(3) NOT NULL CONSTRAINT DF_Stg_ProcessedAt DEFAULT SYSUTCDATETIME(),
  ProcessedBy        NVARCHAR(100) NULL
);

 /* 4) Fact table */
/* FACT TABLE (create if missing) */
IF OBJECT_ID('dw.FactHealthObservations','U') IS NULL
BEGIN
  CREATE TABLE dw.FactHealthObservations (
    ObservationID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TopicID        INT NOT NULL,
    QuestionID     INT NOT NULL,
    LocationID     INT NOT NULL,
    StratificationID   INT NULL,
    DataValueTypeID    INT NULL,
    YearStart      INT NOT NULL,
    YearEnd        INT NOT NULL,
    DataValue          DECIMAL(18,4) NULL,
    LowConfidenceLimit DECIMAL(18,4) NULL,
    HighConfidenceLimit DECIMAL(18,4) NULL,
    ResponseValue         NVARCHAR(255) NULL,
    DataValueFootnoteSym  NVARCHAR(10)  NULL,
    DataValueFootnote     NVARCHAR(MAX) NULL,
    DataSource            NVARCHAR(100) NULL,
    Original_LocationID   INT NULL,
    Original_TopicID      NVARCHAR(50) NULL,
    Original_QuestionID   NVARCHAR(50) NULL,
    Original_StratCatID1  NVARCHAR(50) NULL,
    Original_StratID1     NVARCHAR(50) NULL,
    Original_StratCatID2  NVARCHAR(50) NULL,
    Original_StratID2     NVARCHAR(50) NULL,
    Original_StratCatID3  NVARCHAR(50) NULL,
    Original_StratID3     NVARCHAR(50) NULL,
    CreatedAt   DATETIME2(3) NOT NULL CONSTRAINT DF_Fact_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt   DATETIME2(3) NOT NULL CONSTRAINT DF_Fact_UpdatedAt DEFAULT SYSUTCDATETIME(),
    LoadDate    DATE        NULL,
    CONSTRAINT FK_Fact_Topic     FOREIGN KEY (TopicID)     REFERENCES dw.DimTopics(TopicID),
    CONSTRAINT FK_Fact_Question  FOREIGN KEY (QuestionID)  REFERENCES dw.DimQuestions(QuestionID),
    CONSTRAINT FK_Fact_Location  FOREIGN KEY (LocationID)  REFERENCES dw.DimLocations(LocationID),
    CONSTRAINT FK_Fact_Strat     FOREIGN KEY (StratificationID) REFERENCES dw.DimStratifications(StratificationID),
    CONSTRAINT FK_Fact_DVT       FOREIGN KEY (DataValueTypeID)   REFERENCES dw.DimDataValueTypes(DataValueTypeID)
  );
END
GO

/* DROP (if exists) then CREATE TRIGGER — must start a new batch */
IF OBJECT_ID('dw.trg_FactHealthObservations_Upd','TR') IS NOT NULL
  DROP TRIGGER dw.trg_FactHealthObservations_Upd;
GO
CREATE TRIGGER dw.trg_FactHealthObservations_Upd
ON dw.FactHealthObservations
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE f
    SET UpdatedAt = SYSUTCDATETIME()
  FROM dw.FactHealthObservations f
  JOIN inserted i ON i.ObservationID = f.ObservationID;
END
GO

/* Indexes (run after the table exists) */
CREATE INDEX IX_Fact_Topic       ON dw.FactHealthObservations(TopicID);
CREATE INDEX IX_Fact_Question    ON dw.FactHealthObservations(QuestionID);
CREATE INDEX IX_Fact_Location    ON dw.FactHealthObservations(LocationID);
CREATE INDEX IX_Fact_Strat       ON dw.FactHealthObservations(StratificationID);
CREATE INDEX IX_Fact_Year        ON dw.FactHealthObservations(YearStart, YearEnd);
CREATE INDEX IX_Fact_DVT         ON dw.FactHealthObservations(DataValueTypeID);
CREATE INDEX IX_Fact_Composite   ON dw.FactHealthObservations(LocationID, TopicID, YearStart);
GO


/* 6) === ETL from staging to dimensions ===
   Source: datalake.stg_us_chronic_disease_raw (already loaded)
*/

-- Topics
INSERT INTO dw.DimTopics (TopicName, TopicCode)
SELECT DISTINCT r.Topic, r.TopicID
FROM datalake.stg_us_chronic_disease_raw r
WHERE r.Topic IS NOT NULL AND r.Topic <> ''
  AND NOT EXISTS (SELECT 1 FROM dw.DimTopics t WHERE t.TopicName = r.Topic);

-- Locations
INSERT INTO dw.DimLocations (LocationAbbr, LocationDesc, Geolocation)
SELECT DISTINCT r.LocationAbbr, r.LocationDesc, r.Geolocation
FROM datalake.stg_us_chronic_disease_raw r
WHERE r.LocationDesc IS NOT NULL AND r.LocationDesc <> ''
  AND r.LocationAbbr IS NOT NULL AND r.LocationAbbr <> ''
  AND NOT EXISTS (SELECT 1 FROM dw.DimLocations l WHERE l.LocationAbbr = r.LocationAbbr);

-- Data Value Types
INSERT INTO dw.DimDataValueTypes (TypeName, UnitOfMeasure)
SELECT DISTINCT r.DataValueType, r.DataValueUnit
FROM datalake.stg_us_chronic_disease_raw r
WHERE r.DataValueType IS NOT NULL AND r.DataValueType <> ''
  AND NOT EXISTS (SELECT 1 FROM dw.DimDataValueTypes d WHERE d.TypeName = r.DataValueType);

-- Questions (after Topics)
INSERT INTO dw.DimQuestions (QuestionText, QuestionCode, TopicID)
SELECT DISTINCT r.Question, r.QuestionID, t.TopicID
FROM datalake.stg_us_chronic_disease_raw r
JOIN dw.DimTopics t ON t.TopicName = r.Topic
WHERE r.Question IS NOT NULL AND r.Question <> ''
  AND NOT EXISTS (SELECT 1 FROM dw.DimQuestions q WHERE q.QuestionText = r.Question);

-- Stratification Categories 1..3
INSERT INTO dw.DimStratificationCategories (CategoryName)
SELECT DISTINCT r.StratificationCategory1
FROM datalake.stg_us_chronic_disease_raw r
WHERE r.StratificationCategory1 IS NOT NULL AND r.StratificationCategory1 <> ''
  AND NOT EXISTS (SELECT 1 FROM dw.DimStratificationCategories sc WHERE sc.CategoryName = r.StratificationCategory1);

INSERT INTO dw.DimStratificationCategories (CategoryName)
SELECT DISTINCT r.StratificationCategory2
FROM datalake.stg_us_chronic_disease_raw r
WHERE r.StratificationCategory2 IS NOT NULL AND r.StratificationCategory2 <> ''
  AND NOT EXISTS (SELECT 1 FROM dw.DimStratificationCategories sc WHERE sc.CategoryName = r.StratificationCategory2);

INSERT INTO dw.DimStratificationCategories (CategoryName)
SELECT DISTINCT r.StratificationCategory3
FROM datalake.stg_us_chronic_disease_raw r
WHERE r.StratificationCategory3 IS NOT NULL AND r.StratificationCategory3 <> ''
  AND NOT EXISTS (SELECT 1 FROM dw.DimStratificationCategories sc WHERE sc.CategoryName = r.StratificationCategory3);

-- Stratification Values 1..3
INSERT INTO dw.DimStratifications (StratifCategoryID, StratificationValue)
SELECT DISTINCT sc.StratifCategoryID, r.Stratification1
FROM datalake.stg_us_chronic_disease_raw r
JOIN dw.DimStratificationCategories sc ON sc.CategoryName = r.StratificationCategory1
WHERE r.Stratification1 IS NOT NULL AND r.Stratification1 <> ''
  AND NOT EXISTS (SELECT 1 FROM dw.DimStratifications s
                  WHERE s.StratifCategoryID = sc.StratifCategoryID AND s.StratificationValue = r.Stratification1);

INSERT INTO dw.DimStratifications (StratifCategoryID, StratificationValue)
SELECT DISTINCT sc.StratifCategoryID, r.Stratification2
FROM datalake.stg_us_chronic_disease_raw r
JOIN dw.DimStratificationCategories sc ON sc.CategoryName = r.StratificationCategory2
WHERE r.Stratification2 IS NOT NULL AND r.Stratification2 <> ''
  AND NOT EXISTS (SELECT 1 FROM dw.DimStratifications s
                  WHERE s.StratifCategoryID = sc.StratifCategoryID AND s.StratificationValue = r.Stratification2);

INSERT INTO dw.DimStratifications (StratifCategoryID, StratificationValue)
SELECT DISTINCT sc.StratifCategoryID, r.Stratification3
FROM datalake.stg_us_chronic_disease_raw r
JOIN dw.DimStratificationCategories sc ON sc.CategoryName = r.StratificationCategory3
WHERE r.Stratification3 IS NOT NULL AND r.Stratification3 <> ''
  AND NOT EXISTS (SELECT 1 FROM dw.DimStratifications s
                  WHERE s.StratifCategoryID = sc.StratifCategoryID AND s.StratificationValue = r.Stratification3);


/* 7) === Fact load === */

INSERT INTO dw.FactHealthObservations
(TopicID, QuestionID, LocationID, StratificationID, DataValueTypeID,
 YearStart, YearEnd, DataValue, LowConfidenceLimit, HighConfidenceLimit,
 ResponseValue, DataValueFootnote, DataSource, LoadDate,
 Original_LocationID, Original_TopicID, Original_QuestionID,
 Original_StratCatID1, Original_StratID1, Original_StratCatID2, Original_StratID2, Original_StratCatID3, Original_StratID3)
SELECT
  t.TopicID,
  q.QuestionID,
  l.LocationID,
  s1.StratificationID,
  dvt.DataValueTypeID,
  TRY_CONVERT(INT, r.YearStart),
  TRY_CONVERT(INT, r.YearEnd),
  TRY_CONVERT(DECIMAL(18,4), r.DataValue),
  TRY_CONVERT(DECIMAL(18,4), r.LowConfidenceLimit),
  TRY_CONVERT(DECIMAL(18,4), r.HighConfidenceLimit),
  r.Response,
  r.DataValueFootnote,
  r.DataSource,
  CAST(SYSUTCDATETIME() AS DATE),
  TRY_CONVERT(INT, r.LocationID),
  r.TopicID,
  r.QuestionID,
  r.StratificationCategoryID1, r.StratificationID1,
  r.StratificationCategoryID2, r.StratificationID2,
  r.StratificationCategoryID3, r.StratificationID3
FROM datalake.stg_us_chronic_disease_raw r
JOIN dw.DimTopics     t  ON t.TopicName    = r.Topic
JOIN dw.DimQuestions  q  ON q.QuestionText = r.Question
JOIN dw.DimLocations  l  ON l.LocationAbbr = r.LocationAbbr
LEFT JOIN dw.DimDataValueTypes dvt ON dvt.TypeName = r.DataValueType
LEFT JOIN dw.DimStratificationCategories sc1 ON sc1.CategoryName = r.StratificationCategory1
LEFT JOIN dw.DimStratifications s1 ON s1.StratifCategoryID = sc1.StratifCategoryID
                                   AND s1.StratificationValue = r.Stratification1
WHERE r.DataValue IS NOT NULL
  AND r.YearStart IS NOT NULL
  AND r.LocationAbbr IS NOT NULL;
GO

/* 8) Sanity checks */
SELECT
  (SELECT COUNT(*) FROM dw.DimTopics)                    AS dim_topics,
  (SELECT COUNT(*) FROM dw.DimQuestions)                 AS dim_questions,
  (SELECT COUNT(*) FROM dw.DimLocations)                 AS dim_locations,
  (SELECT COUNT(*) FROM dw.DimDataValueTypes)            AS dim_value_types,
  (SELECT COUNT(*) FROM dw.DimStratificationCategories)  AS dim_strat_cats,
  (SELECT COUNT(*) FROM dw.DimStratifications)           AS dim_strats,
  (SELECT COUNT(*) FROM dw.FactHealthObservations)       AS fact_rows;


-- peek some rows
SELECT TOP (5) * FROM dw.DimTopics;
SELECT TOP (5) * FROM dw.DimQuestions;
SELECT TOP (5) * FROM dw.DimLocations;
SELECT TOP (5) * FROM dw.FactHealthObservations;
GO

-- Quick Query Examples
-- Diabetes by state & year
SELECT l.LocationAbbr, f.YearStart, AVG(f.DataValue) AS AvgRate
FROM dw.FactHealthObservations f
JOIN dw.DimLocations l ON f.LocationID = l.LocationID
JOIN dw.DimQuestions q ON f.QuestionID = q.QuestionID
WHERE q.QuestionText LIKE '%Diabetes%'
GROUP BY l.LocationAbbr, f.YearStart
ORDER BY l.LocationAbbr, f.YearStart;

-- 2023 CA breakdown by stratification (if available)
SELECT q.QuestionText, s.StratificationValue, AVG(f.DataValue) AS AvgVal, COUNT(*) AS N
FROM dw.FactHealthObservations f
JOIN dw.DimQuestions q ON f.QuestionID = q.QuestionID
JOIN dw.DimStratifications s ON f.StratificationID = s.StratificationID
JOIN dw.DimLocations l ON f.LocationID = l.LocationID
WHERE l.LocationAbbr = 'CA' AND f.YearStart = 2023
GROUP BY q.QuestionText, s.StratificationValue
ORDER BY AvgVal DESC;
GO