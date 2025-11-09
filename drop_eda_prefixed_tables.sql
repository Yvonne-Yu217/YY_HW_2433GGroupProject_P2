-- drop_eda_prefixed_tables.sql
-- WARNING: destructive. Drops FOREIGN KEY constraints referencing or on tables whose name starts with 'eda' OR tables in schema 'eda', then drops those tables.
SET NOCOUNT ON;
PRINT 'Finding tables with name LIKE ''eda%'' or in schema ''eda''...';

-- Build a list of target tables
IF OBJECT_ID('tempdb..#targets') IS NOT NULL DROP TABLE #targets;
CREATE TABLE #targets(
  schema_name SYSNAME,
  table_name SYSNAME,
  full_name NVARCHAR(512),
  object_id INT
);

INSERT INTO #targets(schema_name, table_name, full_name, object_id)
SELECT s.name, t.name, s.name + '.' + t.name, t.object_id
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.name LIKE 'eda%'
   OR s.name = 'eda';

PRINT 'Targets to drop:';
SELECT full_name FROM #targets;

-- If no targets, exit
IF NOT EXISTS (SELECT 1 FROM #targets)
BEGIN
    PRINT 'No matching tables found. Nothing to do.';
    RETURN;
END

-- Drop foreign keys where either the parent or the referenced table is in targets
PRINT 'Dropping foreign keys that reference or belong to target tables...';
DECLARE @sql NVARCHAR(MAX);

DECLARE fk_cursor CURSOR FOR
SELECT DISTINCT QUOTENAME(s.name) + '.' + QUOTENAME(t.name) AS parent_table,
       QUOTENAME(fk.name) AS fk_name
FROM sys.foreign_keys fk
JOIN sys.tables t ON fk.parent_object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE fk.parent_object_id IN (SELECT object_id FROM #targets)
   OR fk.referenced_object_id IN (SELECT object_id FROM #targets);

OPEN fk_cursor;
DECLARE @parent_table NVARCHAR(512), @fk_name NVARCHAR(512);
FETCH NEXT FROM fk_cursor INTO @parent_table, @fk_name;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'ALTER TABLE ' + @parent_table + N' DROP CONSTRAINT ' + @fk_name + N';';
    PRINT @sql;
    BEGIN TRY
        EXEC sp_executesql @sql;
    END TRY
    BEGIN CATCH
        PRINT 'ERROR dropping FK: ' + ERROR_MESSAGE();
    END CATCH
    FETCH NEXT FROM fk_cursor INTO @parent_table, @fk_name;
END
CLOSE fk_cursor;
DEALLOCATE fk_cursor;

-- Drop the target tables
PRINT 'Dropping target tables...';
DECLARE tbl_cursor CURSOR FOR
SELECT QUOTENAME(schema_name) + '.' + QUOTENAME(table_name) AS full_name
FROM #targets
ORDER BY full_name;

OPEN tbl_cursor;
DECLARE @tbl NVARCHAR(512);
FETCH NEXT FROM tbl_cursor INTO @tbl;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'DROP TABLE ' + @tbl + N';';
    PRINT @sql;
    BEGIN TRY
        EXEC sp_executesql @sql;
    END TRY
    BEGIN CATCH
        PRINT 'ERROR dropping table ' + @tbl + ': ' + ERROR_MESSAGE();
    END CATCH
    FETCH NEXT FROM tbl_cursor INTO @tbl;
END
CLOSE tbl_cursor;
DEALLOCATE tbl_cursor;

PRINT 'Done dropping eda-prefixed tables.';
SELECT 'Completed' AS status, COUNT(*) AS dropped_count FROM #targets;
