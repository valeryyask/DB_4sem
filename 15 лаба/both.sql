USE UNIVER;
GO

-- ������� 1: �������� ������� TR_AUDIT � �������� TR_TEACHER_INS
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
VALUES ('���1', N'�������� �������������', N'�', '��������');
SELECT * FROM dbo.TR_AUDIT;
GO

-- ������� 2: �������� AFTER-�������� TR_TEACHER_DEL
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

DELETE FROM dbo.TEACHER WHERE TEACHER = '���1';
SELECT * FROM dbo.TR_AUDIT;
GO

-- ������� 3: �������� AFTER-�������� TR_TEACHER_UPD
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
           CONCAT('��: ', D.TEACHER, ', ', D.TEACHER_NAME, ', ', D.GENDER, ', ', D.PULPIT,
                  ' | �����: ', I.TEACHER, ', ', I.TEACHER_NAME, ', ', I.GENDER, ', ', I.PULPIT)
    FROM INSERTED I
    INNER JOIN DELETED D ON I.TEACHER = D.TEACHER;
END;
GO

INSERT INTO dbo.TEACHER (TEACHER, TEACHER_NAME, GENDER, PULPIT)
VALUES ('���2', N'�������� ������������� 2', N'�', '���');
UPDATE dbo.TEACHER
SET TEACHER_NAME = N'�������� ������������� ��������'
WHERE TEACHER = '���2';
SELECT * FROM dbo.TR_AUDIT;
GO

-- ������� 4: �������� AFTER-�������� TR_TEACHER ��� INSERT, DELETE, UPDATE
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
               CONCAT('��: ', D.TEACHER, ', ', D.TEACHER_NAME, ', ', D.GENDER, ', ', D.PULPIT,
                      ' | �����: ', I.TEACHER, ', ', I.TEACHER_NAME, ', ', I.GENDER, ', ', I.PULPIT)
        FROM INSERTED I
        INNER JOIN DELETED D ON I.TEACHER = D.TEACHER;
    END;
END;
GO

INSERT INTO dbo.TEACHER (TEACHER, TEACHER_NAME, GENDER, PULPIT)
VALUES ('���3', N'�������� ������������� 3', N'�', '���');
UPDATE dbo.TEACHER
SET GENDER = N'�'
WHERE TEACHER = '���3';
DELETE FROM dbo.TEACHER WHERE TEACHER = '���3';
SELECT * FROM dbo.TR_AUDIT;
GO

-- ������� 5: ������������, ��� �������� ����������� ����������� �� AFTER-��������
ALTER TABLE dbo.TEACHER
ADD CONSTRAINT CHK_GENDER_TEST CHECK (GENDER IN (N'�', N'�', N'�'));
GO

BEGIN TRY
    INSERT INTO dbo.TEACHER (TEACHER, TEACHER_NAME, GENDER, PULPIT)
    VALUES ('���4', N'�������� ������������� 4', N'�', '��������');
END TRY
BEGIN CATCH
    PRINT '������: ' + ERROR_MESSAGE();
END CATCH;
SELECT * FROM dbo.TR_AUDIT; 
GO

ALTER TABLE dbo.TEACHER
DROP CONSTRAINT CHK_GENDER_TEST;
GO

-- ������� 6: �������� ���� AFTER-��������� TR_TEACHER_DEL1, DEL2, DEL3 � ��������������
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
    PRINT '�������� TR_TEACHER_DEL1';
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
    PRINT '�������� TR_TEACHER_DEL2';
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
    PRINT '�������� TR_TEACHER_DEL3';
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
VALUES ('���5', N'�������� ������������� 5', N'�', '��');
DELETE FROM dbo.TEACHER WHERE TEACHER = '���5';
SELECT * FROM dbo.TR_AUDIT;
GO

-- ������� 7: ������������, ��� AFTER-������� �������� ������ ����������
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
        RAISERROR('��������� ������������ ���������� ��������������', 16, 1);
        ROLLBACK;
    END
END;
GO

BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO dbo.TEACHER (TEACHER, TEACHER_NAME, GENDER, PULPIT)
    VALUES ('���6', N'�������� ������������� 6', N'�', '��������');
    COMMIT;
END TRY
BEGIN CATCH
    PRINT '������: ' + ERROR_MESSAGE();
    ROLLBACK;
END CATCH;
SELECT * FROM dbo.TEACHER WHERE TEACHER = '���6';
SELECT * FROM dbo.TR_AUDIT;
GO

-- ������� 8: INSTEAD OF-������� ��� ������� FACULTY
IF OBJECT_ID('dbo.TR_FACULTY_DEL') IS NOT NULL
    DROP TRIGGER dbo.TR_FACULTY_DEL;
GO
CREATE TRIGGER dbo.TR_FACULTY_DEL
ON dbo.FACULTY
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('�������� ����������� ���������', 16, 1);
    ROLLBACK;
END;
GO

BEGIN TRY
    DELETE FROM dbo.FACULTY WHERE FACULTY = '����';
END TRY
BEGIN CATCH
    PRINT '������: ' + ERROR_MESSAGE();
END CATCH;

-- ������� ������� ��������� � ���������� �������� (������ ���� ����������� ���������)
INSERT INTO dbo.FACULTY (FACULTY, FACULTY_NAME) VALUES ('����', N'�������� ���������');
SELECT * FROM dbo.FACULTY WHERE FACULTY = '����';
DELETE FROM dbo.FACULTY WHERE FACULTY = '����'; -- �������� �������, ��� ��� ��� ������������
SELECT * FROM dbo.FACULTY WHERE FACULTY = '����';
GO

-- ������� 9: DDL-������� ��� ���� ������ UNIVER
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

    PRINT '��� �������: ' + @event_type;
    PRINT '��� �������: ' + @object_name;
    PRINT '��� �������: ' + @object_type;
    RAISERROR('�������� ��� �������� ������ � ���� ������ UNIVER ���������', 16, 1);
    ROLLBACK;
END;
GO

BEGIN TRY
    CREATE TABLE dbo.TEST_TABLE (ID INT);
END TRY
BEGIN CATCH
    PRINT '������: ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    DROP TABLE dbo.AUDITORIUM;
END TRY
BEGIN CATCH
    PRINT '������: ' + ERROR_MESSAGE();
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

-- ������� �������� ������
DELETE FROM dbo.TEACHER WHERE TEACHER LIKE '���%';
GO

USE Y_MyBase;
GO

-- ������� 1: �������� ������� TR_AUDIT � �������� TR_EMPLOYEES_INS
-- �������� ������� TR_AUDIT
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
VALUES (N'������', N'����', N'��������', '1980-01-01', N'�');
SELECT * FROM dbo.TR_AUDIT;
GO

-- ������� 2: �������� AFTER-�������� TR_EMPLOYEES_DEL
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

DELETE FROM dbo.Employees WHERE last_name = N'������';
SELECT * FROM dbo.TR_AUDIT;
GO

-- ������� 3: �������� AFTER-�������� TR_EMPLOYEES_UPD
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
           CONCAT('��: ', D.employee_id, ', ', D.last_name, ', ', D.first_name, ', ', D.middle_name, ', ', D.birth_date, ', ', D.gender,
                  ' | �����: ', I.employee_id, ', ', I.last_name, ', ', I.first_name, ', ', I.middle_name, ', ', I.birth_date, ', ', I.gender)
    FROM INSERTED I
    INNER JOIN DELETED D ON I.employee_id = D.employee_id;
END;
GO

INSERT INTO dbo.Employees (last_name, first_name, middle_name, birth_date, gender)
VALUES (N'������', N'����', N'��������', '1985-02-02', N'�');
UPDATE dbo.Employees
SET first_name = N'���� �����������'
WHERE last_name = N'������';
SELECT * FROM dbo.TR_AUDIT;
GO

-- ������� 4: �������� AFTER-�������� TR_EMPLOYEES ��� INSERT, DELETE, UPDATE
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
               CONCAT('��: ', D.employee_id, ', ', D.last_name, ', ', D.first_name, ', ', D.middle_name, ', ', D.birth_date, ', ', D.gender,
                      ' | �����: ', I.employee_id, ', ', I.last_name, ', ', I.first_name, ', ', I.middle_name, ', ', I.birth_date, ', ', I.gender)
        FROM INSERTED I
        INNER JOIN DELETED D ON I.employee_id = D.employee_id;
    END;
END;
GO

INSERT INTO dbo.Employees (last_name, first_name, middle_name, birth_date, gender)
VALUES (N'�������', N'�����', N'���������', '1990-03-03', N'�');
UPDATE dbo.Employees
SET gender = N'�'
WHERE last_name = N'�������';
DELETE FROM dbo.Employees WHERE last_name = N'�������';
SELECT * FROM dbo.TR_AUDIT;
GO

-- ������� 5: ������������, ��� �������� ����������� ����������� �� AFTER-��������
-- ��������� �������� ����������� �� gender
ALTER TABLE dbo.Employees
ADD CONSTRAINT CHK_GENDER_TEST CHECK (gender IN (N'�', N'�', N'�'));
GO

BEGIN TRY
    INSERT INTO dbo.Employees (last_name, first_name, middle_name, birth_date, gender)
    VALUES (N'������', N'����', N'��������', '1995-04-04', N'�');
END TRY
BEGIN CATCH
    PRINT '������: ' + ERROR_MESSAGE();
END CATCH;
SELECT * FROM dbo.TR_AUDIT; 
GO

ALTER TABLE dbo.Employees
DROP CONSTRAINT CHK_GENDER_TEST;
GO

-- ������� 6: �������� ���� AFTER-��������� TR_EMPLOYEES_DEL1, DEL2, DEL3 � ��������������
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
    PRINT '�������� TR_EMPLOYEES_DEL1';
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
    PRINT '�������� TR_EMPLOYEES_DEL2';
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
    PRINT '�������� TR_EMPLOYEES_DEL3';
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
VALUES (N'������', N'�����', N'��������', '1988-05-05', N'�');
DELETE FROM dbo.Employees WHERE last_name = N'������';
SELECT * FROM dbo.TR_AUDIT;
GO

-- ������� 7: ������������, ��� AFTER-������� �������� ������ ����������
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
        RAISERROR('��������� ������������ ���������� �����������', 16, 1);
        ROLLBACK;
    END
END;
GO

BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO dbo.Employees (last_name, first_name, middle_name, birth_date, gender)
    VALUES (N'�������', N'������', N'���������', '1992-06-06', N'�');
    COMMIT;
END TRY
BEGIN CATCH
    PRINT '������: ' + ERROR_MESSAGE();
    ROLLBACK;
END CATCH;
SELECT * FROM dbo.Employees WHERE last_name = N'�������';
SELECT * FROM dbo.TR_AUDIT;
GO

-- ������� 8: INSTEAD OF-������� ��� ������� Departments
IF OBJECT_ID('dbo.TR_DEPARTMENTS_DEL') IS NOT NULL
    DROP TRIGGER dbo.TR_DEPARTMENTS_DEL;
GO
CREATE TRIGGER dbo.TR_DEPARTMENTS_DEL
ON dbo.Departments
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('�������� ������� ���������', 16, 1);
    ROLLBACK;
END;
GO

BEGIN TRY
    INSERT INTO dbo.Departments (department_name) VALUES (N'�������� �����');
    DELETE FROM dbo.Departments WHERE department_name = N'�������� �����';
END TRY
BEGIN CATCH
    PRINT '������: ' + ERROR_MESSAGE();
END CATCH;
SELECT * FROM dbo.Departments WHERE department_name = N'�������� �����';
GO

-- ������� 9: DDL-������� ��� ���� ������ Y_MyBase
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

    PRINT '��� �������: ' + @event_type;
    PRINT '��� �������: ' + @object_name;
    PRINT '��� �������: ' + @object_type;
    RAISERROR('�������� ��� �������� ������ � ���� ������ Y_MyBase ���������', 16, 1);
    ROLLBACK;
END;
GO

BEGIN TRY
    CREATE TABLE dbo.TEST_TABLE (ID INT);
END TRY
BEGIN CATCH
    PRINT '������: ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    DROP TABLE dbo.Departments;
END TRY
BEGIN CATCH
    PRINT '������: ' + ERROR_MESSAGE();
END CATCH;
GO

-- �������� ���� DML-���������
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

DELETE FROM dbo.Employees WHERE last_name IN (N'������', N'������', N'�������', N'������', N'�������');
GO