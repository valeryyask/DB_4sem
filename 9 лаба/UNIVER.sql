
DECLARE @charVar CHAR(10) = 'Факультет',
        @varcharVar VARCHAR(50) = 'ИТ',
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

PRINT 'Задание 1:';
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
    SELECT @countAuditoriums AS 'Количество аудиторий',
           @avgCapacity AS 'Средняя вместимость',
           @belowAvgCount AS 'Аудиторий меньше средней',
           @belowAvgPercent AS 'Процент аудиторий меньше средней';
END
ELSE
BEGIN
    PRINT 'Общая вместимость аудиторий: ' + CAST(@totalCapacity AS VARCHAR);
END

SELECT 
    @@ROWCOUNT AS 'Обработано строк',
    @@VERSION AS 'Версия SQL Server',
    @@SPID AS 'ID процесса',
    @@ERROR AS 'Код последней ошибки',
    @@SERVERNAME AS 'Имя сервера',
    @@TRANCOUNT AS 'Уровень вложенности транзакций',
    @@FETCH_STATUS AS 'Статус выборки',
    @@NESTLEVEL AS 'Уровень вложенности процедуры';

SELECT * FROM AUDITORIUM WHERE AUDITORIUM_CAPACITY > 1000; 
SELECT 
    @@ROWCOUNT AS 'Обработано строк после запроса',
    @@ERROR AS 'Код ошибки после запроса';

DECLARE @x FLOAT, @y FLOAT, @z FLOAT;
DECLARE @counter INT = 1;
PRINT 'Задание 4.1: Вычисление z = x^2 + sin(y):';
WHILE @counter <= 3
BEGIN
    SET @x = @counter;
    SET @y = @counter * 2;
    SET @z = POWER(@x, 2) + SIN(@y);
    PRINT 'Итерация ' + CAST(@counter AS VARCHAR) + ': x = ' + CAST(@x AS VARCHAR) + ', y = ' + CAST(@y AS VARCHAR) + ', z = ' + CAST(@z AS VARCHAR);
    SET @counter = @counter + 1;
END;

DECLARE @fullName NVARCHAR(100) = (SELECT TOP 1 [NAME] FROM STUDENT);
DECLARE @shortName NVARCHAR(100);
SET @shortName = (SELECT 
    SUBSTRING(@fullName, 1, CHARINDEX(' ', @fullName)) + 
    SUBSTRING(@fullName, CHARINDEX(' ', @fullName) + 1, 1) + '.' +
    SUBSTRING(@fullName, CHARINDEX(' ', @fullName, CHARINDEX(' ', @fullName) + 1) + 1, 1) + '.');
PRINT 'Задание 4.2:';
PRINT 'Полное ФИО: ' + @fullName;
PRINT 'Сокращённое ФИО: ' + @shortName;

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
WHERE P.SUBJECT = 'СУБД';

DECLARE @avgNote NUMERIC(5,2);
SELECT @avgNote = AVG(CAST(NOTE AS NUMERIC(5,2))) FROM PROGRESS;
IF @avgNote > 5
BEGIN
    SELECT 
        S.[NAME],
        P.NOTE,
        'Выше средней' AS Status
    FROM PROGRESS P
    JOIN STUDENT S ON P.IDSTUDENT = S.IDSTUDENT
    WHERE P.NOTE > @avgNote;
END
ELSE
BEGIN
    PRINT 'Средняя оценка: ' + CAST(@avgNote AS VARCHAR) + ' (не выше 5)';
END

SELECT 
    S.[NAME],
    P.NOTE,
    CASE 
        WHEN P.NOTE >= 8 THEN 'Отлично'
        WHEN P.NOTE >= 6 THEN 'Хорошо'
        WHEN P.NOTE >= 4 THEN 'Удовлетворительно'
        ELSE 'Неудовлетворительно'
    END AS GradeDescription
FROM PROGRESS P
JOIN STUDENT S ON P.IDSTUDENT = S.IDSTUDENT
WHERE P.SUBJECT = 'ПЗ';

CREATE TABLE #TEMP_TABLE (
    ID INT,
    Name NVARCHAR(50),
    Value INT
);
DECLARE @i INT = 1;
WHILE @i <= 10
BEGIN
    INSERT INTO #TEMP_TABLE (ID, Name, Value)
    VALUES (@i, 'Запись ' + CAST(@i AS NVARCHAR), CAST(RAND() * 100 AS INT));
    SET @i = @i + 1;
END;
SELECT * FROM #TEMP_TABLE;

DECLARE @countStudents INT;
SELECT @countStudents = COUNT(*) FROM STUDENT;
IF @countStudents < 10
BEGIN
    PRINT 'Меньше 10 студентов: ' + CAST(@countStudents AS VARCHAR);
    RETURN;
END;
PRINT 'Больше или равно 10 студентов';

BEGIN TRY
    INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY, AUDITORIUM_NAME)
    VALUES ('999-9', 'ЛК', 500, 'Тест'); 
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
