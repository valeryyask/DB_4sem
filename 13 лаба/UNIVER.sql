-- Удаляем существующие процедуры, если они уже созданы
IF OBJECT_ID('PSUBJECT', 'P') IS NOT NULL DROP PROCEDURE PSUBJECT;
IF OBJECT_ID('PAUDITORIUM_INSERT', 'P') IS NOT NULL DROP PROCEDURE PAUDITORIUM_INSERT;
IF OBJECT_ID('PAUDITORIUM_INSERTX', 'P') IS NOT NULL DROP PROCEDURE PAUDITORIUM_INSERTX;
IF OBJECT_ID('SUBJECT_REPORT', 'P') IS NOT NULL DROP PROCEDURE SUBJECT_REPORT;
GO

-- Создание процедуры PSUBJECT
CREATE PROCEDURE PSUBJECT
AS
BEGIN
    SELECT * FROM SUBJECT;
    SELECT COUNT(*) AS 'Общее количество дисциплин' FROM SUBJECT;
END;
GO

-- Создание процедуры PAUDITORIUM_INSERT
CREATE PROCEDURE PAUDITORIUM_INSERT
    @a CHAR(10),
    @c INT,
    @t CHAR(10)
AS
BEGIN
    -- Проверка существования типа аудитории
    IF NOT EXISTS (SELECT 1 FROM AUDITORIUM_TYPE WHERE AUDITORIUM_TYPE = @t)
    BEGIN
        PRINT 'Тип аудитории не существует. Добавляем...';
        INSERT INTO AUDITORIUM_TYPE (AUDITORIUM_TYPE) VALUES (@t);
    END

    -- Проверка уникальности аудитории
    IF NOT EXISTS (SELECT 1 FROM AUDITORIUM WHERE AUDITORIUM = @a)
    BEGIN
        INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_CAPACITY, AUDITORIUM_TYPE)
        VALUES (@a, @c, @t);
    END
    ELSE
    BEGIN
        RAISERROR('Аудитория уже существует', 11, 1);
    END
END;
GO

-- Создание процедуры SUBJECT_REPORT
CREATE PROCEDURE SUBJECT_REPORT
    @p CHAR(20),
    @rc INT OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.SUBJECT WHERE PULPIT = @p)
    BEGIN
        RAISERROR('ошибка в параметрах', 11, 1);
        SET @rc = 0;
        RETURN;
    END

    SELECT SUBJECT_NAME FROM dbo.SUBJECT WHERE PULPIT = @p;
    SELECT @rc = COUNT(*) FROM dbo.SUBJECT WHERE PULPIT = @p;
END;
GO

-- Создание процедуры PAUDITORIUM_INSERTX (вставка нескольких аудиторий)
CREATE PROCEDURE PAUDITORIUM_INSERTX
AS
BEGIN
    DECLARE @count INT = 0;

    -- Добавляем тип ЛБ-Н, если его нет
    IF NOT EXISTS (SELECT 1 FROM AUDITORIUM_TYPE WHERE AUDITORIUM_TYPE = 'ЛБ-Н')
    BEGIN
        INSERT INTO AUDITORIUM_TYPE (AUDITORIUM_TYPE) VALUES ('ЛБ-Н');
    END

    -- Массив аудиторий
    DECLARE @a TABLE (AUD CHAR(10), CAP INT);
    INSERT INTO @a VALUES ('500-1', 40), ('501-1', 40), ('600-1', 20), ('601-1', 20);

    DECLARE @name CHAR(10), @cap INT;

    DECLARE cur CURSOR FOR SELECT AUD, CAP FROM @a;
    OPEN cur;

    FETCH NEXT FROM cur INTO @name, @cap;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC PAUDITORIUM_INSERT @name, @cap, 'ЛБ-Н';
        FETCH NEXT FROM cur INTO @name, @cap;
        SET @count = @count + 1;
    END

    CLOSE cur;
    DEALLOCATE cur;

    PRINT 'Добавлено аудиторий: ' + CAST(@count AS VARCHAR);
END;
GO

-- Выполнение процедур и проверка

-- Проверка SUBJECT (все предметы + количество)
EXEC PSUBJECT;
GO

-- Проверка SUBJECT_REPORT
DECLARE @cnt INT;
EXEC SUBJECT_REPORT 'ИС', @cnt OUTPUT;
PRINT 'Количество дисциплин: ' + CAST(@cnt AS VARCHAR);
GO

-- Проверка с несуществующей кафедрой
EXEC SUBJECT_REPORT 'НЕИЗВЕСТНО', @cnt OUTPUT;
PRINT 'Количество дисциплин: ' + CAST(@cnt AS VARCHAR);
GO

-- Вставка аудиторий
EXEC PAUDITORIUM_INSERTX;
GO