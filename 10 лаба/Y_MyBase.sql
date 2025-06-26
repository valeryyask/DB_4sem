USE Y_MyBase;
GO

PRINT '������� 1: ������ �������� � ���� Y_MyBase';
SELECT 
    t.name AS TableName, 
    i.name AS IndexName, 
    i.type_desc AS IndexType
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
WHERE t.schema_id = SCHEMA_ID('dbo') AND i.name IS NOT NULL;
GO

CREATE TABLE #EXPLRE (
    TIND INT,
    TF VARCHAR(100)
);
GO

SET NOCOUNT ON;
DECLARE @i INT = 0;
WHILE @i < 1000
BEGIN
    INSERT INTO #EXPLRE (TIND, TF) VALUES (@i, REPLICATE('��������� ', 10));
    SET @i = @i + 1;
END;
GO

SELECT COUNT(*) AS [���������� �����] FROM #EXPLRE;
GO

PRINT '������� 1: ��������� ������� ��� �������';
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT * FROM #EXPLRE WHERE TIND BETWEEN 1500 AND 2500 ORDER BY TIND;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

CREATE CLUSTERED INDEX #EXPLRE_CL ON #EXPLRE(TIND ASC);
GO

PRINT '������� 1: ��������� ������� � ���������������� ��������';
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT * FROM #EXPLRE WHERE TIND BETWEEN 1500 AND 2500 ORDER BY TIND;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

CREATE TABLE #EX (
    TKEY INT,
    CC INT IDENTITY(1,1),
    TF VARCHAR(100)
);
GO

SET NOCOUNT ON;
DECLARE @j INT = 0;
WHILE @j < 20000
BEGIN
    INSERT INTO #EX (TKEY, TF) VALUES (FLOOR(30000*RAND()), REPLICATE('��������� ', 10));
    SET @j = @j + 1;
END;
GO

SELECT COUNT(*) AS [���������� �����] FROM #EX;
GO

PRINT '������� 2: ����� �������� ��� ���������� �������';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT * FROM #EX WHERE TKEY > 1500 AND CC < 4500;
SELECT * FROM #EX ORDER BY TKEY, CC;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

CREATE INDEX #EX_NONCLU ON #EX(TKEY, CC);
GO

PRINT '������� 2: ������ � ������������� TKEY (������ �����������)';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT * FROM #EX WHERE TKEY = 556 AND CC > 3;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO


PRINT '������� 3: ��������� ������� ��� ������������ �������';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT CC FROM #EX WHERE TKEY > 15000;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

CREATE INDEX #EX_TKEY_X ON #EX(TKEY) INCLUDE (CC);
GO

PRINT '������� 3: ��������� ������� � ����������� ��������';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT CC FROM #EX WHERE TKEY > 15000;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

PRINT '������� 4: ����� �������� ��� ������������ �������';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT TKEY FROM #EX WHERE TKEY BETWEEN 5000 AND 19999;
SELECT TKEY FROM #EX WHERE TKEY > 15000 AND TKEY < 20000;
SELECT TKEY FROM #EX WHERE TKEY = 17000;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

CREATE INDEX #EX_WHERE ON #EX(TKEY) WHERE (TKEY >= 15000 AND TKEY < 20000);
GO

PRINT '������� 4: ��������� �������� � ����������� ��������';
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT TKEY FROM #EX WHERE TKEY BETWEEN 5000 AND 19999;
SELECT TKEY FROM #EX WHERE TKEY > 15000 AND TKEY < 20000;
SELECT TKEY FROM #EX WHERE TKEY = 17000;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

CREATE INDEX #EX_TKEY ON #EX(TKEY);
GO

PRINT '������� 5: ������� ������������ ������� �� �������';
SELECT 
    name AS [������], 
    avg_fragmentation_in_percent AS [������������ (%)]
FROM sys.dm_db_index_physical_stats(DB_ID(N'TEMPDB'), OBJECT_ID(N'#EX'), NULL, NULL, NULL) ss 
JOIN sys.indexes ii ON ss.object_id = ii.object_id AND ss.index_id = ii.index_id 
WHERE name IS NOT NULL;
GO

INSERT TOP(10000) INTO #EX (TKEY, TF) 
SELECT TKEY, TF FROM #EX;
GO

PRINT '������� 5: ������� ������������ ����� �������';
SELECT 
    name AS [������], 
    avg_fragmentation_in_percent AS [������������ (%)]
FROM sys.dm_db_index_physical_stats(DB_ID(N'TEMPDB'), OBJECT_ID(N'#EX'), NULL, NULL, NULL) ss 
JOIN sys.indexes ii ON ss.object_id = ii.object_id AND ss.index_id = ii.index_id 
WHERE name IS NOT NULL;
GO

ALTER INDEX #EX_TKEY ON #EX REORGANIZE;
GO

PRINT '������� 5: ������� ������������ ����� �������������';
SELECT 
    name AS [������], 
    avg_fragmentation_in_percent AS [������������ (%)]
FROM sys.dm_db_index_physical_stats(DB_ID(N'TEMPDB'), OBJECT_ID(N'#EX'), NULL, NULL, NULL) ss 
JOIN sys.indexes ii ON ss.object_id = ii.object_id AND ss.index_id = ii.index_id 
WHERE name IS NOT NULL;
GO

ALTER INDEX #EX_TKEY ON #EX REBUILD WITH (ONLINE = OFF);
GO

PRINT '������� 5: ������� ������������ ����� �����������';
SELECT 
    name AS [������], 
    avg_fragmentation_in_percent AS [������������ (%)]
FROM sys.dm_db_index_physical_stats(DB_ID(N'TEMPDB'), OBJECT_ID(N'#EX'), NULL, NULL, NULL) ss 
JOIN sys.indexes ii ON ss.object_id = ii.object_id AND ss.index_id = ii.index_id 
WHERE name IS NOT NULL;
GO

DROP INDEX #EX_TKEY ON #EX;
GO

CREATE INDEX #EX_TKEY ON #EX(TKEY) WITH (FILLFACTOR = 65);
GO

INSERT TOP(50) PERCENT INTO #EX (TKEY, TF) 
SELECT TKEY, TF FROM #EX;
GO

PRINT '������� 6: ������� ������������ � FILLFACTOR = 65';
SELECT 
    name AS [������], 
    avg_fragmentation_in_percent AS [������������ (%)]
FROM sys.dm_db_index_physical_stats(DB_ID(N'TEMPDB'), OBJECT_ID(N'#EX'), NULL, NULL, NULL) ss 
JOIN sys.indexes ii ON ss.object_id = ii.object_id AND ss.index_id = ii.index_id 
WHERE name IS NOT NULL;
GO

DROP TABLE #EXPLRE;
DROP TABLE #EX;
GO