USE UNIVER;
GO
SET NOCOUNT ON;

-- Задание 1: Неявная транзакция
PRINT '=== Задание 1: Неявная транзакция ===';
IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'DBO.Y'))
    DROP TABLE Y;

DECLARE @count INT, @flag CHAR = 'c';
SET IMPLICIT_TRANSACTIONS ON;
CREATE TABLE Y (ID INT PRIMARY KEY, Name NVARCHAR(50));
INSERT INTO Y VALUES (1, N'Иванов'), (2, N'Петров'), (3, N'Сидоров');
SET @count = (SELECT COUNT(*) FROM Y);
PRINT 'Количество строк в таблице Y: ' + CAST(@count AS VARCHAR(2));
IF @flag = 'c'
    COMMIT;
ELSE
    ROLLBACK;
SET IMPLICIT_TRANSACTIONS OFF;
IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'DBO.Y'))
    PRINT 'Таблица Y существует';
ELSE
    PRINT 'Таблицы Y нет';
GO

-- Задание 2: Атомарность явной транзакции
PRINT '=== Задание 2: Атомарность явной транзакции ===';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO STUDENT (IDGROUP, [NAME], BDAY)
    VALUES (22, N'Козлов Алексей', '1996-03-15');
    UPDATE STUDENT
    SET IDGROUP = 999 -- Ошибка: нарушение внешнего ключа
    WHERE IDSTUDENT = 1000;
    COMMIT TRANSACTION;
    PRINT 'Транзакция успешно завершена';
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ConstraintName NVARCHAR(100);
    SET @ConstraintName = CASE
        WHEN PATINDEX('%constraint%[FK_][A-Z_0-9]%]', @ErrorMessage) > 0
        THEN SUBSTRING(@ErrorMessage, PATINDEX('%constraint%[FK_][A-Z_0-9]%]', @ErrorMessage) + 11, 50)
        ELSE 'Неизвестное ограничение'
    END;
    PRINT 'Ошибка: ' + @ErrorMessage + '. Нарушено ограничение: ' + @ConstraintName;
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    PRINT 'Уровень вложенности: ' + CAST(@@TRANCOUNT AS VARCHAR(10));
END CATCH;
GO

-- Задание 3: SAVE TRANSACTION
PRINT '=== Задание 3: SAVE TRANSACTION ===';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO PROGRESS (SUBJECT, IDSTUDENT, PDATE, NOTE)
    VALUES ('ПЗ', 1002, '2014-02-01', 7);
    SAVE TRANSACTION SavePoint;
    UPDATE PROGRESS
    SET NOTE = 11 
    WHERE IDSTUDENT = 1002;
    COMMIT TRANSACTION;
    PRINT 'Транзакция успешно завершена';
END TRY
BEGIN CATCH
    PRINT 'Ошибка: ' + ERROR_MESSAGE();
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION SavePoint;
    COMMIT TRANSACTION;
    PRINT 'Откат до контрольной точки';
END CATCH;
SELECT * FROM PROGRESS WHERE IDSTUDENT = 1002;
GO

-- Задание 4: READ UNCOMMITTED
PRINT '=== Задание 4: READ UNCOMMITTED ===';
-- Сценарий A
BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- t1 --
SELECT @@SPID, 'insert STUDENT' AS 'результат', * 
FROM STUDENT 
WHERE [NAME] = N'Смирнов Сергей';
SELECT @@SPID, 'update PROGRESS' AS 'результат', NOTE 
FROM PROGRESS 
WHERE IDSTUDENT = 1000;
-- t2 --
COMMIT;
GO
-- Сценарий B
BEGIN TRANSACTION;
SELECT @@SPID;
INSERT INTO STUDENT (IDGROUP, [NAME], BDAY)
VALUES (22, N'Смирнов Сергей', '1996-04-10');
UPDATE PROGRESS 
SET NOTE = 8 
WHERE IDSTUDENT = 1000;
-- t1 --
-- t2 --
ROLLBACK;
GO

-- Задание 5: READ COMMITTED
PRINT '=== Задание 5: READ COMMITTED ===';
-- Сценарий A
BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT COUNT(*) 
FROM PROGRESS 
WHERE SUBJECT = 'ПЗ';
-- t1 --
-- t2 --
SELECT 'update PROGRESS' AS 'результат', COUNT(*) 
FROM PROGRESS 
WHERE SUBJECT = 'ПЗ';
COMMIT;
GO
-- Сценарий B
BEGIN TRANSACTION;
-- t1 --
INSERT INTO PROGRESS (SUBJECT, IDSTUDENT, PDATE, NOTE)
VALUES ('ПЗ', 1004, '2014-02-15', 6);
COMMIT;
-- t2 --
GO

-- Задание 6: REPEATABLE READ
PRINT '=== Задание 6: REPEATABLE READ ===';
-- Сценарий A
BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT [NAME] 
FROM STUDENT 
WHERE IDGROUP = 22;
-- t1 --
-- t2 --
SELECT CASE 
    WHEN [NAME] = N'Козлов Алексей' THEN 'insert STUDENT' 
    ELSE '' 
END AS 'результат', [NAME] 
FROM STUDENT 
WHERE IDGROUP = 22;
COMMIT;
GO
-- Сценарий B
BEGIN TRANSACTION;
-- t1 --
INSERT INTO STUDENT (IDGROUP, [NAME], BDAY)
VALUES (22, N'Козлов Алексей', '1996-03-20');
COMMIT;
-- t2 --
GO

-- Задание 7: SERIALIZABLE
PRINT '=== Задание 7: SERIALIZABLE ===';
-- Сценарий A
BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DELETE FROM PROGRESS 
WHERE IDSTUDENT = 1000;
INSERT INTO PROGRESS (SUBJECT, IDSTUDENT, PDATE, NOTE)
VALUES ('СУБД', 1000, '2014-03-01', 7);
UPDATE PROGRESS 
SET NOTE = 9 
WHERE IDSTUDENT = 1000;
SELECT SUBJECT 
FROM PROGRESS 
WHERE IDSTUDENT = 1000;
-- t1 --
SELECT SUBJECT 
FROM PROGRESS 
WHERE IDSTUDENT = 1000;
-- t2 --
COMMIT;
GO
-- Сценарий B
BEGIN TRANSACTION;
DELETE FROM PROGRESS 
WHERE IDSTUDENT = 1000;
INSERT INTO PROGRESS (SUBJECT, IDSTUDENT, PDATE, NOTE)
VALUES ('СУБД', 1000, '2014-03-01', 7);
UPDATE PROGRESS 
SET NOTE = 9 
WHERE IDSTUDENT = 1000;
SELECT SUBJECT 
FROM PROGRESS 
WHERE IDSTUDENT = 1000;
-- t1 --
COMMIT;
SELECT SUBJECT 
FROM PROGRESS 
WHERE IDSTUDENT = 1000;
-- t2 --
GO

-- Задание 8: Вложенные транзакции
PRINT '=== Задание 8: Вложенные транзакции ===';
BEGIN TRY
    BEGIN TRANSACTION OuterTran;
    PRINT 'Уровень вложенности (начало): ' + CAST(@@TRANCOUNT AS VARCHAR(10));
    INSERT INTO STUDENT (IDGROUP, [NAME], BDAY)
    VALUES (22, N'Федоров Иван', '1996-06-10');
    BEGIN TRANSACTION InnerTran;
    PRINT 'Уровень вложенности (внутренняя): ' + CAST(@@TRANCOUNT AS VARCHAR(10));
    INSERT INTO PROGRESS (SUBJECT, IDSTUDENT, PDATE, NOTE)
    VALUES ('ПЗ', 1008, '2014-03-10', 11); -- Ошибка: нарушение CHECK
    COMMIT TRANSACTION InnerTran;
    COMMIT TRANSACTION OuterTran;
    PRINT 'Транзакции завершены';
END TRY
BEGIN CATCH
    PRINT 'Ошибка: ' + ERROR_MESSAGE();
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    PRINT 'Уровень вложенности (после отката): ' + CAST(@@TRANCOUNT AS VARCHAR(10));
END CATCH;
SELECT * FROM STUDENT WHERE [NAME] = N'Федоров Иван';
SELECT * FROM PROGRESS WHERE IDSTUDENT = 1008;
GO