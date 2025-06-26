USE UNIVER;
GO

-- Задание 1: Создание таблицы TR_AUDIT и триггера TR_TEACHER_INS
IF OBJECT_ID('dbo.TR_AUDIT') IS NOT NULL
    DROP TABLE dbo.TR_AUDIT;
GO
CREATE TABLE dbo.TR_AUDIT (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    STMT CHAR(3) NOT NULL, -- INS, DEL, UPD
    TRNAME NVARCHAR(50) NOT NULL,
    CC NVARCHAR(MAX) NULL,
    TS DATETIME DEFAULT GETDATE()
);
GO

IF OBJECT_ID('dbo.TR_TEACHER_INS') IS NOT NULL
    DROP TRIGGER dbo.TR_TEACHER_INS;
GO
CREATE TRIGGER dbo.TR_TEACHER_INS
ON dbo.TEACHER
AFTER INSERT
AS
BEGIN
    INSERT INTO dbo.TR_AUDIT (STMT, TRNAME, CC)
    SELECT 'INS', 'TR_TEACHER_INS',
           CONCAT(TEACHER, ', ', TEACHER_NAME, ', ', GENDER, ', ', PULPIT)
    FROM INSERTED;
END;
GO

INSERT INTO dbo.TEACHER (TEACHER, TEACHER_NAME, GENDER, PULPIT)
VALUES ('ТСТ1', N'Тестовый Преподаватель', N'м', 'ТНХСиППМ');
SELECT * FROM dbo.TR_AUDIT;
GO

-- Задание 2: Создание AFTER-триггера TR_TEACHER_DEL
IF OBJECT_ID('dbo.TR_TEACHER_DEL') IS NOT NULL
    DROP TRIGGER dbo.TR_TEACHER_DEL;
GO
CREATE TRIGGER dbo.TR_TEACHER_DEL
ON dbo.TEACHER
AFTER DELETE
AS
BEGIN
    INSERT INTO dbo.TR_AUDIT (STMT, TRNAME, CC)
    SELECT 'DEL', 'TR_TEACHER_DEL', TEACHER
    FROM DELETED;
END;
GO

DELETE FROM dbo.TEACHER WHERE TEACHER = 'ТСТ1';
SELECT * FROM dbo.TR_AUDIT;
GO

-- Задание 3: Создание AFTER-триггера TR_TEACHER_UPD
IF OBJECT_ID('dbo.TR_TEACHER_UPD') IS NOT NULL
    DROP TRIGGER dbo.TR_TEACHER_UPD;
GO
CREATE TRIGGER dbo.TR_TEACHER_UPD
ON dbo.TEACHER
AFTER UPDATE
AS
BEGIN
    INSERT INTO dbo.TR_AUDIT (STMT, TRNAME, CC)
    SELECT 'UPD', 'TR_TEACHER_UPD',
           CONCAT('До: ', D.TEACHER, ', ', D.TEACHER_NAME, ', ', D.GENDER, ', ', D.PULPIT,
                  ' | После: ', I.TEACHER, ', ', I.TEACHER_NAME, ', ', I.GENDER, ', ', I.PULPIT)
    FROM INSERTED I
    INNER JOIN DELETED D ON I.TEACHER = D.TEACHER;
END;
GO

INSERT INTO dbo.TEACHER (TEACHER, TEACHER_NAME, GENDER, PULPIT)
VALUES ('ТСТ2', N'Тестовый Преподаватель 2', N'ж', 'ХПД');
UPDATE dbo.TEACHER
SET TEACHER_NAME = N'Тестовый Преподаватель Обновлен'
WHERE TEACHER = 'ТСТ2';
SELECT * FROM dbo.TR_AUDIT;
GO

-- Задание 4: Создание AFTER-триггера TR_TEACHER для INSERT, DELETE, UPDATE
IF OBJECT_ID('dbo.TR_TEACHER') IS NOT NULL
    DROP TRIGGER dbo.TR_TEACHER;
GO
CREATE TRIGGER dbo.TR_TEACHER
ON dbo.TEACHER
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
    DECLARE @ins_count INT = (SELECT COUNT(*) FROM INSERTED);
    DECLARE @del_count INT = (SELECT COUNT(*) FROM DELETED);
    DECLARE @event CHAR(3);
    DECLARE @cc NVARCHAR(MAX);

    IF @ins_count > 0 AND @del_count = 0 -- INSERT
    BEGIN
        SET @event = 'INS';
        INSERT INTO dbo.TR_AUDIT (STMT, TRNAME, CC)
        SELECT @event, 'TR_TEACHER',
               CONCAT(TEACHER, ', ', TEACHER_NAME, ', ', GENDER, ', ', PULPIT)
        FROM INSERTED;
    END
    ELSE IF @ins_count = 0 AND @del_count > 0 -- DELETE
    BEGIN
        SET @event = 'DEL';
        INSERT INTO dbo.TR_AUDIT (STMT, TRNAME, CC)
        SELECT @event, 'TR_TEACHER', TEACHER
        FROM DELETED;
    END
    ELSE IF @ins_count > 0 AND @del_count > 0 -- UPDATE
    BEGIN
        SET @event = 'UPD';
        INSERT INTO dbo.TR_AUDIT (STMT, TRNAME, CC)
        SELECT @event, 'TR_TEACHER',
               CONCAT('До: ', D.TEACHER, ', ', D.TEACHER_NAME, ', ', D.GENDER, ', ', D.PULPIT,
                      ' | После: ', I.TEACHER, ', ', I.TEACHER_NAME, ', ', I.GENDER, ', ', I.PULPIT)
        FROM INSERTED I
        INNER JOIN DELETED D ON I.TEACHER = D.TEACHER;
    END;
END;
GO

INSERT INTO dbo.TEACHER (TEACHER, TEACHER_NAME, GENDER, PULPIT)
VALUES ('ТСТ3', N'Тестовый Преподаватель 3', N'м', 'ТДП');
UPDATE dbo.TEACHER
SET GENDER = N'ж'
WHERE TEACHER = 'ТСТ3';
DELETE FROM dbo.TEACHER WHERE TEACHER = 'ТСТ3';
SELECT * FROM dbo.TR_AUDIT;
GO

-- Задание 5: Демонстрация, что проверка ограничений выполняется до AFTER-триггера
ALTER TABLE dbo.TEACHER
ADD CONSTRAINT CHK_GENDER_TEST CHECK (GENDER IN (N'м', N'ж', N'т'));
GO

BEGIN TRY
    INSERT INTO dbo.TEACHER (TEACHER, TEACHER_NAME, GENDER, PULPIT)
    VALUES ('ТСТ4', N'Тестовый Преподаватель 4', N'н', 'ТНХСиППМ');
END TRY
BEGIN CATCH
    PRINT 'Ошибка: ' + ERROR_MESSAGE();
END CATCH;
SELECT * FROM dbo.TR_AUDIT; 
GO

ALTER TABLE dbo.TEACHER
DROP CONSTRAINT CHK_GENDER_TEST;
GO

-- Задание 6: Создание трех AFTER-триггеров TR_TEACHER_DEL1, DEL2, DEL3 и упорядочивание
IF OBJECT_ID('dbo.TR_TEACHER_DEL1') IS NOT NULL
    DROP TRIGGER dbo.TR_TEACHER_DEL1;
GO
CREATE TRIGGER dbo.TR_TEACHER_DEL1
ON dbo.TEACHER
AFTER DELETE
AS
BEGIN
    INSERT INTO dbo.TR_AUDIT (STMT, TRNAME, CC)
    SELECT 'DEL', 'TR_TEACHER_DEL1', TEACHER
    FROM DELETED;
    PRINT 'Выполнен TR_TEACHER_DEL1';
END;
GO

IF OBJECT_ID('dbo.TR_TEACHER_DEL2') IS NOT NULL
    DROP TRIGGER dbo.TR_TEACHER_DEL2;
GO
CREATE TRIGGER dbo.TR_TEACHER_DEL2
ON dbo.TEACHER
AFTER DELETE
AS
BEGIN
    INSERT INTO dbo.TR_AUDIT (STMT, TRNAME, CC)
    SELECT 'DEL', 'TR_TEACHER_DEL2', TEACHER
    FROM DELETED;
    PRINT 'Выполнен TR_TEACHER_DEL2';
END;
GO

IF OBJECT_ID('dbo.TR_TEACHER_DEL3') IS NOT NULL
    DROP TRIGGER dbo.TR_TEACHER_DEL3;
GO
CREATE TRIGGER dbo.TR_TEACHER_DEL3
ON dbo.TEACHER
AFTER DELETE
AS
BEGIN
    INSERT INTO dbo.TR_AUDIT (STMT, TRNAME, CC)
    SELECT 'DEL', 'TR_TEACHER_DEL3', TEACHER
    FROM DELETED;
    PRINT 'Выполнен TR_TEACHER_DEL3';
END;
GO

SELECT t.name, e.type_desc
FROM sys.triggers t
JOIN sys.trigger_events e ON t.object_id = e.object_id
WHERE OBJECT_NAME(t.parent_id) = 'TEACHER' AND e.type_desc = 'DELETE';
GO

EXEC sp_settriggerorder @triggername = 'TR_TEACHER_DEL3', @order = 'First', @stmttype = 'DELETE';
EXEC sp_settriggerorder @triggername = 'TR_TEACHER_DEL2', @order = 'Last', @stmttype = 'DELETE';
GO

INSERT INTO dbo.TEACHER (TEACHER, TEACHER_NAME, GENDER, PULPIT)
VALUES ('ТСТ5', N'Тестовый Преподаватель 5', N'м', 'ТЛ');
DELETE FROM dbo.TEACHER WHERE TEACHER = 'ТСТ5';
SELECT * FROM dbo.TR_AUDIT;
GO

-- Задание 7: Демонстрация, что AFTER-триггер является частью транзакции
IF OBJECT_ID('dbo.TR_TEACHER_LIMIT') IS NOT NULL
    DROP TRIGGER dbo.TR_TEACHER_LIMIT;
GO
CREATE TRIGGER dbo.TR_TEACHER_LIMIT
ON dbo.TEACHER
AFTER INSERT
AS
BEGIN
    IF (SELECT COUNT(*) FROM dbo.TEACHER) > 100
    BEGIN
        RAISERROR('Превышено максимальное количество преподавателей', 16, 1);
        ROLLBACK;
    END
END;
GO

BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO dbo.TEACHER (TEACHER, TEACHER_NAME, GENDER, PULPIT)
    VALUES ('ТСТ6', N'Тестовый Преподаватель 6', N'м', 'ХТЭПиМЭЕ');
    COMMIT;
END TRY
BEGIN CATCH
    PRINT 'Ошибка: ' + ERROR_MESSAGE();
    ROLLBACK;
END CATCH;
SELECT * FROM dbo.TEACHER WHERE TEACHER = 'ТСТ6';
SELECT * FROM dbo.TR_AUDIT;
GO

-- Задание 8: INSTEAD OF-триггер для таблицы FACULTY
IF OBJECT_ID('dbo.TR_FACULTY_DEL') IS NOT NULL
    DROP TRIGGER dbo.TR_FACULTY_DEL;
GO
CREATE TRIGGER dbo.TR_FACULTY_DEL
ON dbo.FACULTY
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Удаление факультетов запрещено', 16, 1);
    ROLLBACK;
END;
GO

BEGIN TRY
    DELETE FROM dbo.FACULTY WHERE FACULTY = 'ТТЛП';
END TRY
BEGIN CATCH
    PRINT 'Ошибка: ' + ERROR_MESSAGE();
END CATCH;

-- Попытка удалить факультет с зависимыми записями (должна быть перехвачена триггером)
INSERT INTO dbo.FACULTY (FACULTY, FACULTY_NAME) VALUES ('ТСТФ', N'Тестовый Факультет');
SELECT * FROM dbo.FACULTY WHERE FACULTY = 'ТСТФ';
DELETE FROM dbo.FACULTY WHERE FACULTY = 'ТСТФ'; -- Удаление пройдет, так как нет зависимостей
SELECT * FROM dbo.FACULTY WHERE FACULTY = 'ТСТФ';
GO

-- Задание 9: DDL-триггер для базы данных UNIVER
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'DDL_UNIVER_PREVENT')
    DROP TRIGGER DDL_UNIVER_PREVENT ON DATABASE;
GO
CREATE TRIGGER DDL_UNIVER_PREVENT
ON DATABASE
FOR CREATE_TABLE, DROP_TABLE
AS
BEGIN
    DECLARE @event_type NVARCHAR(50) = EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(50)');
    DECLARE @object_name NVARCHAR(50) = EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(50)');
    DECLARE @object_type NVARCHAR(50) = EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(50)');

    PRINT 'Тип события: ' + @event_type;
    PRINT 'Имя объекта: ' + @object_name;
    PRINT 'Тип объекта: ' + @object_type;
    RAISERROR('Создание или удаление таблиц в базе данных UNIVER запрещено', 16, 1);
    ROLLBACK;
END;
GO

BEGIN TRY
    CREATE TABLE dbo.TEST_TABLE (ID INT);
END TRY
BEGIN CATCH
    PRINT 'Ошибка: ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    DROP TABLE dbo.AUDITORIUM;
END TRY
BEGIN CATCH
    PRINT 'Ошибка: ' + ERROR_MESSAGE();
END CATCH;
GO

IF OBJECT_ID('dbo.TR_TEACHER_INS') IS NOT NULL
    DROP TRIGGER dbo.TR_TEACHER_INS;
GO
IF OBJECT_ID('dbo.TR_TEACHER_DEL') IS NOT NULL
    DROP TRIGGER dbo.TR_TEACHER_DEL;
GO
IF OBJECT_ID('dbo.TR_TEACHER_UPD') IS NOT NULL
    DROP TRIGGER dbo.TR_TEACHER_UPD;
GO
IF OBJECT_ID('dbo.TR_TEACHER') IS NOT NULL
    DROP TRIGGER dbo.TR_TEACHER;
GO
IF OBJECT_ID('dbo.TR_TEACHER_DEL1') IS NOT NULL
    DROP TRIGGER dbo.TR_TEACHER_DEL1;
GO
IF OBJECT_ID('dbo.TR_TEACHER_DEL2') IS NOT NULL
    DROP TRIGGER dbo.TR_TEACHER_DEL2;
GO
IF OBJECT_ID('dbo.TR_TEACHER_DEL3') IS NOT NULL
    DROP TRIGGER dbo.TR_TEACHER_DEL3;
GO
IF OBJECT_ID('dbo.TR_TEACHER_LIMIT') IS NOT NULL
    DROP TRIGGER dbo.TR_TEACHER_LIMIT;
GO
IF OBJECT_ID('dbo.TR_FACULTY_DEL') IS NOT NULL
    DROP TRIGGER dbo.TR_FACULTY_DEL;
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'DDL_UNIVER_PREVENT')
    DROP TRIGGER DDL_UNIVER_PREVENT ON DATABASE;
GO

-- Очистка тестовых данных
DELETE FROM dbo.TEACHER WHERE TEACHER LIKE 'ТСТ%';
GO

USE Y_MyBase;
GO

-- Задание 1: Создание таблицы TR_AUDIT и триггера TR_EMPLOYEES_INS
-- Создание таблицы TR_AUDIT
IF OBJECT_ID('dbo.TR_AUDIT') IS NOT NULL
    DROP TABLE dbo.TR_AUDIT;
GO
CREATE TABLE dbo.TR_AUDIT (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    STMT CHAR(3) NOT NULL, -- INS, DEL, UPD
    TRNAME NVARCHAR(50) NOT NULL,
    CC NVARCHAR(MAX) NULL,
    TS DATETIME DEFAULT GETDATE()
);
GO

IF OBJECT_ID('dbo.TR_EMPLOYEES_INS') IS NOT NULL
    DROP TRIGGER dbo.TR_EMPLOYEES_INS;
GO
CREATE TRIGGER dbo.TR_EMPLOYEES_INS
ON dbo.Employees
AFTER INSERT
AS
BEGIN
    INSERT INTO dbo.TR_AUDIT (STMT, TRNAME, CC)
    SELECT 'INS', 'TR_EMPLOYEES_INS',
           CONCAT(employee_id, ', ', last_name, ', ', first_name, ', ', middle_name, ', ', birth_date, ', ', gender)
    FROM INSERTED;
END;
GO

INSERT INTO dbo.Employees (last_name, first_name, middle_name, birth_date, gender)
VALUES (N'Иванов', N'Иван', N'Иванович', '1980-01-01', N'М');
SELECT * FROM dbo.TR_AUDIT;
GO

-- Задание 2: Создание AFTER-триггера TR_EMPLOYEES_DEL
IF OBJECT_ID('dbo.TR_EMPLOYEES_DEL') IS NOT NULL
    DROP TRIGGER dbo.TR_EMPLOYEES_DEL;
GO
CREATE TRIGGER dbo.TR_EMPLOYEES_DEL
ON dbo.Employees
AFTER DELETE
AS
BEGIN
    INSERT INTO dbo.TR_AUDIT (STMT, TRNAME, CC)
    SELECT 'DEL', 'TR_EMPLOYEES_DEL', employee_id
    FROM DELETED;
END;
GO

DELETE FROM dbo.Employees WHERE last_name = N'Иванов';
SELECT * FROM dbo.TR_AUDIT;
GO

-- Задание 3: Создание AFTER-триггера TR_EMPLOYEES_UPD
IF OBJECT_ID('dbo.TR_EMPLOYEES_UPD') IS NOT NULL
    DROP TRIGGER dbo.TR_EMPLOYEES_UPD;
GO
CREATE TRIGGER dbo.TR_EMPLOYEES_UPD
ON dbo.Employees
AFTER UPDATE
AS
BEGIN
    INSERT INTO dbo.TR_AUDIT (STMT, TRNAME, CC)
    SELECT 'UPD', 'TR_EMPLOYEES_UPD',
           CONCAT('До: ', D.employee_id, ', ', D.last_name, ', ', D.first_name, ', ', D.middle_name, ', ', D.birth_date, ', ', D.gender,
                  ' | После: ', I.employee_id, ', ', I.last_name, ', ', I.first_name, ', ', I.middle_name, ', ', I.birth_date, ', ', I.gender)
    FROM INSERTED I
    INNER JOIN DELETED D ON I.employee_id = D.employee_id;
END;
GO

INSERT INTO dbo.Employees (last_name, first_name, middle_name, birth_date, gender)
VALUES (N'Петров', N'Петр', N'Петрович', '1985-02-02', N'М');
UPDATE dbo.Employees
SET first_name = N'Петр Обновленный'
WHERE last_name = N'Петров';
SELECT * FROM dbo.TR_AUDIT;
GO

-- Задание 4: Создание AFTER-триггера TR_EMPLOYEES для INSERT, DELETE, UPDATE
IF OBJECT_ID('dbo.TR_EMPLOYEES') IS NOT NULL
    DROP TRIGGER dbo.TR_EMPLOYEES;
GO
CREATE TRIGGER dbo.TR_EMPLOYEES
ON dbo.Employees
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
    DECLARE @ins_count INT = (SELECT COUNT(*) FROM INSERTED);
    DECLARE @del_count INT = (SELECT COUNT(*) FROM DELETED);
    DECLARE @event CHAR(3);
    DECLARE @cc NVARCHAR(MAX);

    IF @ins_count > 0 AND @del_count = 0 -- INSERT
    BEGIN
        SET @event = 'INS';
        INSERT INTO dbo.TR_AUDIT (STMT, TRNAME, CC)
        SELECT @event, 'TR_EMPLOYEES',
               CONCAT(employee_id, ', ', last_name, ', ', first_name, ', ', middle_name, ', ', birth_date, ', ', gender)
        FROM INSERTED;
    END
    ELSE IF @ins_count = 0 AND @del_count > 0 -- DELETE
    BEGIN
        SET @event = 'DEL';
        INSERT INTO dbo.TR_AUDIT (STMT, TRNAME, CC)
        SELECT @event, 'TR_EMPLOYEES', employee_id
        FROM DELETED;
    END
    ELSE IF @ins_count > 0 AND @del_count > 0 -- UPDATE
    BEGIN
        SET @event = 'UPD';
        INSERT INTO dbo.TR_AUDIT (STMT, TRNAME, CC)
        SELECT @event, 'TR_EMPLOYEES',
               CONCAT('До: ', D.employee_id, ', ', D.last_name, ', ', D.first_name, ', ', D.middle_name, ', ', D.birth_date, ', ', D.gender,
                      ' | После: ', I.employee_id, ', ', I.last_name, ', ', I.first_name, ', ', I.middle_name, ', ', I.birth_date, ', ', I.gender)
        FROM INSERTED I
        INNER JOIN DELETED D ON I.employee_id = D.employee_id;
    END;
END;
GO

INSERT INTO dbo.Employees (last_name, first_name, middle_name, birth_date, gender)
VALUES (N'Сидоров', N'Сидор', N'Сидорович', '1990-03-03', N'М');
UPDATE dbo.Employees
SET gender = N'Ж'
WHERE last_name = N'Сидоров';
DELETE FROM dbo.Employees WHERE last_name = N'Сидоров';
SELECT * FROM dbo.TR_AUDIT;
GO

-- Задание 5: Демонстрация, что проверка ограничений выполняется до AFTER-триггера
-- Добавляем тестовое ограничение на gender
ALTER TABLE dbo.Employees
ADD CONSTRAINT CHK_GENDER_TEST CHECK (gender IN (N'М', N'Ж', N'Т'));
GO

BEGIN TRY
    INSERT INTO dbo.Employees (last_name, first_name, middle_name, birth_date, gender)
    VALUES (N'Тестов', N'Тест', N'Тестович', '1995-04-04', N'Н');
END TRY
BEGIN CATCH
    PRINT 'Ошибка: ' + ERROR_MESSAGE();
END CATCH;
SELECT * FROM dbo.TR_AUDIT; 
GO

ALTER TABLE dbo.Employees
DROP CONSTRAINT CHK_GENDER_TEST;
GO

-- Задание 6: Создание трех AFTER-триггеров TR_EMPLOYEES_DEL1, DEL2, DEL3 и упорядочивание
IF OBJECT_ID('dbo.TR_EMPLOYEES_DEL1') IS NOT NULL
    DROP TRIGGER dbo.TR_EMPLOYEES_DEL1;
GO
CREATE TRIGGER dbo.TR_EMPLOYEES_DEL1
ON dbo.Employees
AFTER DELETE
AS
BEGIN
    INSERT INTO dbo.TR_AUDIT (STMT, TRNAME, CC)
    SELECT 'DEL', 'TR_EMPLOYEES_DEL1', employee_id
    FROM DELETED;
    PRINT 'Выполнен TR_EMPLOYEES_DEL1';
END;
GO

IF OBJECT_ID('dbo.TR_EMPLOYEES_DEL2') IS NOT NULL
    DROP TRIGGER dbo.TR_EMPLOYEES_DEL2;
GO
CREATE TRIGGER dbo.TR_EMPLOYEES_DEL2
ON dbo.Employees
AFTER DELETE
AS
BEGIN
    INSERT INTO dbo.TR_AUDIT (STMT, TRNAME, CC)
    SELECT 'DEL', 'TR_EMPLOYEES_DEL2', employee_id
    FROM DELETED;
    PRINT 'Выполнен TR_EMPLOYEES_DEL2';
END;
GO

IF OBJECT_ID('dbo.TR_EMPLOYEES_DEL3') IS NOT NULL
    DROP TRIGGER dbo.TR_EMPLOYEES_DEL3;
GO
CREATE TRIGGER dbo.TR_EMPLOYEES_DEL3
ON dbo.Employees
AFTER DELETE
AS
BEGIN
    INSERT INTO dbo.TR_AUDIT (STMT, TRNAME, CC)
    SELECT 'DEL', 'TR_EMPLOYEES_DEL3', employee_id
    FROM DELETED;
    PRINT 'Выполнен TR_EMPLOYEES_DEL3';
END;
GO

SELECT t.name, e.type_desc
FROM sys.triggers t
JOIN sys.trigger_events e ON t.object_id = e.object_id
WHERE OBJECT_NAME(t.parent_id) = 'Employees' AND e.type_desc = 'DELETE';
GO

EXEC sp_settriggerorder @triggername = 'TR_EMPLOYEES_DEL3', @order = 'First', @stmttype = 'DELETE';
EXEC sp_settriggerorder @triggername = 'TR_EMPLOYEES_DEL2', @order = 'Last', @stmttype = 'DELETE';
GO

INSERT INTO dbo.Employees (last_name, first_name, middle_name, birth_date, gender)
VALUES (N'Козлов', N'Козел', N'Козлович', '1988-05-05', N'М');
DELETE FROM dbo.Employees WHERE last_name = N'Козлов';
SELECT * FROM dbo.TR_AUDIT;
GO

-- Задание 7: Демонстрация, что AFTER-триггер является частью транзакции
IF OBJECT_ID('dbo.TR_EMPLOYEES_LIMIT') IS NOT NULL
    DROP TRIGGER dbo.TR_EMPLOYEES_LIMIT;
GO
CREATE TRIGGER dbo.TR_EMPLOYEES_LIMIT
ON dbo.Employees
AFTER INSERT
AS
BEGIN
    IF (SELECT COUNT(*) FROM dbo.Employees) > 100
    BEGIN
        RAISERROR('Превышено максимальное количество сотрудников', 16, 1);
        ROLLBACK;
    END
END;
GO

BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO dbo.Employees (last_name, first_name, middle_name, birth_date, gender)
    VALUES (N'Смирнов', N'Сергей', N'Сергеевич', '1992-06-06', N'М');
    COMMIT;
END TRY
BEGIN CATCH
    PRINT 'Ошибка: ' + ERROR_MESSAGE();
    ROLLBACK;
END CATCH;
SELECT * FROM dbo.Employees WHERE last_name = N'Смирнов';
SELECT * FROM dbo.TR_AUDIT;
GO

-- Задание 8: INSTEAD OF-триггер для таблицы Departments
IF OBJECT_ID('dbo.TR_DEPARTMENTS_DEL') IS NOT NULL
    DROP TRIGGER dbo.TR_DEPARTMENTS_DEL;
GO
CREATE TRIGGER dbo.TR_DEPARTMENTS_DEL
ON dbo.Departments
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Удаление отделов запрещено', 16, 1);
    ROLLBACK;
END;
GO

BEGIN TRY
    INSERT INTO dbo.Departments (department_name) VALUES (N'Тестовый Отдел');
    DELETE FROM dbo.Departments WHERE department_name = N'Тестовый Отдел';
END TRY
BEGIN CATCH
    PRINT 'Ошибка: ' + ERROR_MESSAGE();
END CATCH;
SELECT * FROM dbo.Departments WHERE department_name = N'Тестовый Отдел';
GO

-- Задание 9: DDL-триггер для базы данных Y_MyBase
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'DDL_Y_MYBASE_PREVENT')
    DROP TRIGGER DDL_Y_MYBASE_PREVENT ON DATABASE;
GO
CREATE TRIGGER DDL_Y_MYBASE_PREVENT
ON DATABASE
FOR CREATE_TABLE, DROP_TABLE
AS
BEGIN
    DECLARE @event_type NVARCHAR(50) = EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(50)');
    DECLARE @object_name NVARCHAR(50) = EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(50)');
    DECLARE @object_type NVARCHAR(50) = EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(50)');

    PRINT 'Тип события: ' + @event_type;
    PRINT 'Имя объекта: ' + @object_name;
    PRINT 'Тип объекта: ' + @object_type;
    RAISERROR('Создание или удаление таблиц в базе данных Y_MyBase запрещено', 16, 1);
    ROLLBACK;
END;
GO

BEGIN TRY
    CREATE TABLE dbo.TEST_TABLE (ID INT);
END TRY
BEGIN CATCH
    PRINT 'Ошибка: ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    DROP TABLE dbo.Departments;
END TRY
BEGIN CATCH
    PRINT 'Ошибка: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Удаление всех DML-триггеров
IF OBJECT_ID('dbo.TR_EMPLOYEES_INS') IS NOT NULL
    DROP TRIGGER dbo.TR_EMPLOYEES_INS;
GO
IF OBJECT_ID('dbo.TR_EMPLOYEES_DEL') IS NOT NULL
    DROP TRIGGER dbo.TR_EMPLOYEES_DEL;
GO
IF OBJECT_ID('dbo.TR_EMPLOYEES_UPD') IS NOT NULL
    DROP TRIGGER dbo.TR_EMPLOYEES_UPD;
GO
IF OBJECT_ID('dbo.TR_EMPLOYEES') IS NOT NULL
    DROP TRIGGER dbo.TR_EMPLOYEES;
GO
IF OBJECT_ID('dbo.TR_EMPLOYEES_DEL1') IS NOT NULL
    DROP TRIGGER dbo.TR_EMPLOYEES_DEL1;
GO
IF OBJECT_ID('dbo.TR_EMPLOYEES_DEL2') IS NOT NULL
    DROP TRIGGER dbo.TR_EMPLOYEES_DEL2;
GO
IF OBJECT_ID('dbo.TR_EMPLOYEES_DEL3') IS NOT NULL
    DROP TRIGGER dbo.TR_EMPLOYEES_DEL3;
GO
IF OBJECT_ID('dbo.TR_EMPLOYEES_LIMIT') IS NOT NULL
    DROP TRIGGER dbo.TR_EMPLOYEES_LIMIT;
GO
IF OBJECT_ID('dbo.TR_DEPARTMENTS_DEL') IS NOT NULL
    DROP TRIGGER dbo.TR_DEPARTMENTS_DEL;
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'DDL_Y_MYBASE_PREVENT')
    DROP TRIGGER DDL_Y_MYBASE_PREVENT ON DATABASE;
GO

DELETE FROM dbo.Employees WHERE last_name IN (N'Иванов', N'Петров', N'Сидоров', N'Козлов', N'Смирнов');
GO