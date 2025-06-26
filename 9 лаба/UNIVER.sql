
DECLARE @charVar CHAR(10) = '���������',
        @varcharVar VARCHAR(50) = '��',
        @datetimeVar DATETIME,
        @timeVar TIME,
        @intVar INT,
        @smallintVar SMALLINT,
        @tinyintVar TINYINT,
        @numericVar NUMERIC(12,5);

SET @datetimeVar = GETDATE();
SET @timeVar = CONVERT(TIME, GETDATE());
SET @intVar = 100;

SELECT @smallintVar = 50,
       @tinyintVar = 10,
       @numericVar = 12345.67890;

SELECT @charVar AS CharValue, 
       @varcharVar AS VarcharValue,
       @datetimeVar AS DatetimeValue,
       @timeVar AS TimeValue;

PRINT '������� 1:';
PRINT 'Int: ' + CAST(@intVar AS VARCHAR);
PRINT 'Smallint: ' + CAST(@smallintVar AS VARCHAR);
PRINT 'Tinyint: ' + CAST(@tinyintVar AS VARCHAR);
PRINT 'Numeric: ' + CAST(@numericVar AS VARCHAR);

DECLARE @totalCapacity INT,
        @avgCapacity NUMERIC(10,2),
        @countAuditoriums INT,
        @belowAvgCount INT,
        @belowAvgPercent NUMERIC(5,2);

SELECT @totalCapacity = SUM(AUDITORIUM_CAPACITY),
       @countAuditoriums = COUNT(*),
       @avgCapacity = AVG(CAST(AUDITORIUM_CAPACITY AS NUMERIC(10,2)))
FROM AUDITORIUM;

IF @totalCapacity > 200
BEGIN
    SELECT @belowAvgCount = COUNT(*)
    FROM AUDITORIUM
    WHERE AUDITORIUM_CAPACITY < @avgCapacity;
    SET @belowAvgPercent = (@belowAvgCount * 100.0) / @countAuditoriums;
    SELECT @countAuditoriums AS '���������� ���������',
           @avgCapacity AS '������� �����������',
           @belowAvgCount AS '��������� ������ �������',
           @belowAvgPercent AS '������� ��������� ������ �������';
END
ELSE
BEGIN
    PRINT '����� ����������� ���������: ' + CAST(@totalCapacity AS VARCHAR);
END

SELECT 
    @@ROWCOUNT AS '���������� �����',
    @@VERSION AS '������ SQL Server',
    @@SPID AS 'ID ��������',
    @@ERROR AS '��� ��������� ������',
    @@SERVERNAME AS '��� �������',
    @@TRANCOUNT AS '������� ����������� ����������',
    @@FETCH_STATUS AS '������ �������',
    @@NESTLEVEL AS '������� ����������� ���������';

SELECT * FROM AUDITORIUM WHERE AUDITORIUM_CAPACITY > 1000; 
SELECT 
    @@ROWCOUNT AS '���������� ����� ����� �������',
    @@ERROR AS '��� ������ ����� �������';

DECLARE @x FLOAT, @y FLOAT, @z FLOAT;
DECLARE @counter INT = 1;
PRINT '������� 4.1: ���������� z = x^2 + sin(y):';
WHILE @counter <= 3
BEGIN
    SET @x = @counter;
    SET @y = @counter * 2;
    SET @z = POWER(@x, 2) + SIN(@y);
    PRINT '�������� ' + CAST(@counter AS VARCHAR) + ': x = ' + CAST(@x AS VARCHAR) + ', y = ' + CAST(@y AS VARCHAR) + ', z = ' + CAST(@z AS VARCHAR);
    SET @counter = @counter + 1;
END;

DECLARE @fullName NVARCHAR(100) = (SELECT TOP 1 [NAME] FROM STUDENT);
DECLARE @shortName NVARCHAR(100);
SET @shortName = (SELECT 
    SUBSTRING(@fullName, 1, CHARINDEX(' ', @fullName)) + 
    SUBSTRING(@fullName, CHARINDEX(' ', @fullName) + 1, 1) + '.' +
    SUBSTRING(@fullName, CHARINDEX(' ', @fullName, CHARINDEX(' ', @fullName) + 1) + 1, 1) + '.');
PRINT '������� 4.2:';
PRINT '������ ���: ' + @fullName;
PRINT '����������� ���: ' + @shortName;

DECLARE @nextMonth INT = MONTH(DATEADD(MONTH, 1, GETDATE()));
SELECT 
    [NAME],
    BDAY,
    DATEDIFF(YEAR, BDAY, GETDATE()) AS Age
FROM STUDENT
WHERE MONTH(BDAY) = @nextMonth;

SELECT 
    G.IDGROUP,
    P.PDATE,
    DATENAME(WEEKDAY, P.PDATE) AS ExamDay
FROM PROGRESS P
JOIN STUDENT S ON P.IDSTUDENT = S.IDSTUDENT
JOIN [GROUP] G ON S.IDGROUP = G.IDGROUP
WHERE P.SUBJECT = '����';

DECLARE @avgNote NUMERIC(5,2);
SELECT @avgNote = AVG(CAST(NOTE AS NUMERIC(5,2))) FROM PROGRESS;
IF @avgNote > 5
BEGIN
    SELECT 
        S.[NAME],
        P.NOTE,
        '���� �������' AS Status
    FROM PROGRESS P
    JOIN STUDENT S ON P.IDSTUDENT = S.IDSTUDENT
    WHERE P.NOTE > @avgNote;
END
ELSE
BEGIN
    PRINT '������� ������: ' + CAST(@avgNote AS VARCHAR) + ' (�� ���� 5)';
END

SELECT 
    S.[NAME],
    P.NOTE,
    CASE 
        WHEN P.NOTE >= 8 THEN '�������'
        WHEN P.NOTE >= 6 THEN '������'
        WHEN P.NOTE >= 4 THEN '�����������������'
        ELSE '�������������������'
    END AS GradeDescription
FROM PROGRESS P
JOIN STUDENT S ON P.IDSTUDENT = S.IDSTUDENT
WHERE P.SUBJECT = '��';

CREATE TABLE #TEMP_TABLE (
    ID INT,
    Name NVARCHAR(50),
    Value INT
);
DECLARE @i INT = 1;
WHILE @i <= 10
BEGIN
    INSERT INTO #TEMP_TABLE (ID, Name, Value)
    VALUES (@i, '������ ' + CAST(@i AS NVARCHAR), CAST(RAND() * 100 AS INT));
    SET @i = @i + 1;
END;
SELECT * FROM #TEMP_TABLE;

DECLARE @countStudents INT;
SELECT @countStudents = COUNT(*) FROM STUDENT;
IF @countStudents < 10
BEGIN
    PRINT '������ 10 ���������: ' + CAST(@countStudents AS VARCHAR);
    RETURN;
END;
PRINT '������ ��� ����� 10 ���������';

BEGIN TRY
    INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY, AUDITORIUM_NAME)
    VALUES ('999-9', '��', 500, '����'); 
END TRY
BEGIN CATCH
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_LINE() AS ErrorLine,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState;
END CATCH;
GO
