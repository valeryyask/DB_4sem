USE Y_MyBase;
GO
SET NOCOUNT ON;

-- Задание 1: Неявная транзакция
PRINT '=== Задание 1: Неявная транзакция ===';
IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'dbo.TempTable'))
    DROP TABLE dbo.TempTable;

DECLARE @count INT, @flag CHAR = 'c';
SET IMPLICIT_TRANSACTIONS ON;
CREATE TABLE dbo.TempTable (ID INT PRIMARY KEY, Name NVARCHAR(50));
INSERT INTO dbo.TempTable VALUES (1, N'Смирнов'), (2, N'Иванов'), (3, N'Петров');
SET @count = (SELECT COUNT(*) FROM dbo.TempTable);
PRINT 'Количество строк в таблице TempTable: ' + CAST(@count AS VARCHAR(2));
IF @flag = 'c'
    COMMIT;
ELSE
    ROLLBACK;
SET IMPLICIT_TRANSACTIONS OFF;
IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'dbo.TempTable'))
    PRINT 'Таблица TempTable существует';
ELSE
    PRINT 'Таблицы TempTable нет';
GO

-- Задание 2: Атомарность явной транзакции
PRINT '=== Задание 2: Атомарность явной транзакции ===';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Employees (last_name, first_name, middle_name, birth_date, gender)
    VALUES (N'Козлов', N'Алексей', N'Иванович', '1990-03-15', N'М');
    UPDATE Employees
    SET gender = N'X' 
    WHERE last_name = N'Козлов';
    COMMIT TRANSACTION;
    PRINT 'Транзакция успешно завершена';
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ConstraintName NVARCHAR(100);
    SET @ConstraintName = CASE
        WHEN PATINDEX('%constraint "[A-Z_0-9]%"', @ErrorMessage) > 0
        THEN SUBSTRING(@ErrorMessage, PATINDEX('%constraint "[A-Z_0-9]%"', @ErrorMessage) + 11, 
                       CHARINDEX('"', @ErrorMessage, PATINDEX('%constraint "[A-Z_0-9]%"', @ErrorMessage) + 11) - 
                       PATINDEX('%constraint "[A-Z_0-9]%"', @ErrorMessage) - 11)
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
    INSERT INTO Appointments (employee_id, department_id, position_id, appointment_date, contract_term_days)
    VALUES (1, 1, 1, '2023-01-01', 365);
    SAVE TRANSACTION SavePoint;
    UPDATE Appointments
    SET employee_id = 999
    WHERE appointment_id = (SELECT MAX(appointment_id) FROM Appointments);
    COMMIT TRANSACTION;
    PRINT 'Транзакция успешно завершена';
END TRY
BEGIN CATCH
    PRINT 'Ошибка: ' + ERROR_MESSAGE();
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION SavePoint;
    IF @@TRANCOUNT > 0
        COMMIT TRANSACTION;
    PRINT 'Откат до контрольной точки';
END CATCH;
SELECT * FROM Appointments WHERE employee_id = 1;
GO

-- Задание 4: READ UNCOMMITTED
PRINT '=== Задание 4: READ UNCOMMITTED ===';
-- Сценарий A
BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- t1 --
SELECT @@SPID, 'insert Employees' AS 'результат', * 
FROM Employees 
WHERE last_name = N'Сидоров';
SELECT @@SPID, 'update Appointments' AS 'результат', contract_term_days 
FROM Appointments 
WHERE employee_id = 1;
-- t2 --
COMMIT;
GO
-- Сценарий B
BEGIN TRANSACTION;
SELECT @@SPID;
INSERT INTO Employees (last_name, first_name, middle_name, birth_date, gender)
VALUES (N'Сидоров', N'Сергей', N'Петрович', '1985-04-10', N'М');
UPDATE Appointments 
SET contract_term_days = 730 
WHERE employee_id = 1;
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
FROM Appointments 
WHERE department_id = 1;
-- t1 --
-- t2 --
SELECT 'insert Appointments' AS 'результат', COUNT(*) 
FROM Appointments 
WHERE department_id = 1;
COMMIT;
GO
-- Сценарий B
BEGIN TRANSACTION;
-- t1 --
INSERT INTO Appointments (employee_id, department_id, position_id, appointment_date, contract_term_days)
VALUES (1, 1, 1, '2023-02-01', 180);
COMMIT;
-- t2 --
GO

-- Задание 6: REPEATABLE READ
PRINT '=== Задание 6: REPEATABLE READ ===';
-- Сценарий A
BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT last_name 
FROM Employees 
WHERE department_id = (SELECT department_id FROM Appointments WHERE employee_id = 1);
-- t1 --
-- t2 --
SELECT CASE 
    WHEN last_name = N'Федоров' THEN 'insert Employees' 
    ELSE '' 
END AS 'результат', last_name 
FROM Employees 
WHERE department_id = (SELECT department_id FROM Appointments WHERE employee_id = 1);
COMMIT;
GO
-- Сценарий B
BEGIN TRANSACTION;
-- t1 --
INSERT INTO Employees (last_name, first_name, middle_name, birth_date, gender)
VALUES (N'Федоров', N'Иван', N'Алексеевич', '1990-03-20', N'М');
COMMIT;
-- t2 --
GO

-- Задание 7: SERIALIZABLE
PRINT '=== Задание 7: SERIALIZABLE ===';
-- Сценарий A
BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DELETE FROM Appointments 
WHERE employee_id = 1;
INSERT INTO Appointments (employee_id, department_id, position_id, appointment_date, contract_term_days)
VALUES (1, 1, 1, '2023-03-01', 365);
UPDATE Appointments 
SET contract_term_days = 1095 
WHERE employee_id = 1;
SELECT appointment_id 
FROM Appointments 
WHERE employee_id = 1;
-- t1 --
SELECT appointment_id 
FROM Appointments 
WHERE employee_id = 1;
-- t2 --
COMMIT;
GO
-- Сценарий B
BEGIN TRANSACTION;
DELETE FROM Appointments 
WHERE employee_id = 1;
INSERT INTO Appointments (employee_id, department_id, position_id, appointment_date, contract_term_days)
VALUES (1, 1, 1, '2023-03-01', 365);
UPDATE Appointments 
SET contract_term_days = 1095 
WHERE employee_id = 1;
SELECT appointment_id 
FROM Appointments 
WHERE employee_id = 1;
-- t1 --
COMMIT;
SELECT appointment_id 
FROM Appointments 
WHERE employee_id = 1;
-- t2 --
GO

-- Задание 8: Вложенные транзакции
PRINT '=== Задание 8: Вложенные транзакции ===';
BEGIN TRY
    BEGIN TRANSACTION OuterTran;
    PRINT 'Уровень вложенности (начало): ' + CAST(@@TRANCOUNT AS VARCHAR(10));
    INSERT INTO Employees (last_name, first_name, middle_name, birth_date, gender)
    VALUES (N'Федоров', N'Иван', N'Алексеевич', '1990-06-10', N'М');
    BEGIN TRANSACTION InnerTran;
    PRINT 'Уровень вложенности (внутренняя): ' + CAST(@@TRANCOUNT AS VARCHAR(10));
    INSERT INTO Appointments (employee_id, department_id, position_id, appointment_date, contract_term_days)
    VALUES (999, 1, 1, '2023-03-10', 365); -- Ошибка: нарушение FOREIGN KEY
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
SELECT * FROM Employees WHERE last_name = N'Федоров';
SELECT * FROM Appointments WHERE employee_id = 999;
GO