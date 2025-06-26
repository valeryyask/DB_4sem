USE Y_MyBase;
GO
SET NOCOUNT ON;

-- ������� 1: ������� ����������
PRINT '=== ������� 1: ������� ���������� ===';
IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'dbo.TempTable'))
    DROP TABLE dbo.TempTable;

DECLARE @count INT, @flag CHAR = 'c';
SET IMPLICIT_TRANSACTIONS ON;
CREATE TABLE dbo.TempTable (ID INT PRIMARY KEY, Name NVARCHAR(50));
INSERT INTO dbo.TempTable VALUES (1, N'�������'), (2, N'������'), (3, N'������');
SET @count = (SELECT COUNT(*) FROM dbo.TempTable);
PRINT '���������� ����� � ������� TempTable: ' + CAST(@count AS VARCHAR(2));
IF @flag = 'c'
    COMMIT;
ELSE
    ROLLBACK;
SET IMPLICIT_TRANSACTIONS OFF;
IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'dbo.TempTable'))
    PRINT '������� TempTable ����������';
ELSE
    PRINT '������� TempTable ���';
GO

-- ������� 2: ����������� ����� ����������
PRINT '=== ������� 2: ����������� ����� ���������� ===';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Employees (last_name, first_name, middle_name, birth_date, gender)
    VALUES (N'������', N'�������', N'��������', '1990-03-15', N'�');
    UPDATE Employees
    SET gender = N'X' 
    WHERE last_name = N'������';
    COMMIT TRANSACTION;
    PRINT '���������� ������� ���������';
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ConstraintName NVARCHAR(100);
    SET @ConstraintName = CASE
        WHEN PATINDEX('%constraint "[A-Z_0-9]%"', @ErrorMessage) > 0
        THEN SUBSTRING(@ErrorMessage, PATINDEX('%constraint "[A-Z_0-9]%"', @ErrorMessage) + 11, 
                       CHARINDEX('"', @ErrorMessage, PATINDEX('%constraint "[A-Z_0-9]%"', @ErrorMessage) + 11) - 
                       PATINDEX('%constraint "[A-Z_0-9]%"', @ErrorMessage) - 11)
        ELSE '����������� �����������'
    END;
    PRINT '������: ' + @ErrorMessage + '. �������� �����������: ' + @ConstraintName;
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    PRINT '������� �����������: ' + CAST(@@TRANCOUNT AS VARCHAR(10));
END CATCH;
GO

-- ������� 3: SAVE TRANSACTION
PRINT '=== ������� 3: SAVE TRANSACTION ===';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO Appointments (employee_id, department_id, position_id, appointment_date, contract_term_days)
    VALUES (1, 1, 1, '2023-01-01', 365);
    SAVE TRANSACTION SavePoint;
    UPDATE Appointments
    SET employee_id = 999
    WHERE appointment_id = (SELECT MAX(appointment_id) FROM Appointments);
    COMMIT TRANSACTION;
    PRINT '���������� ������� ���������';
END TRY
BEGIN CATCH
    PRINT '������: ' + ERROR_MESSAGE();
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION SavePoint;
    IF @@TRANCOUNT > 0
        COMMIT TRANSACTION;
    PRINT '����� �� ����������� �����';
END CATCH;
SELECT * FROM Appointments WHERE employee_id = 1;
GO

-- ������� 4: READ UNCOMMITTED
PRINT '=== ������� 4: READ UNCOMMITTED ===';
-- �������� A
BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- t1 --
SELECT @@SPID, 'insert Employees' AS '���������', * 
FROM Employees 
WHERE last_name = N'�������';
SELECT @@SPID, 'update Appointments' AS '���������', contract_term_days 
FROM Appointments 
WHERE employee_id = 1;
-- t2 --
COMMIT;
GO
-- �������� B
BEGIN TRANSACTION;
SELECT @@SPID;
INSERT INTO Employees (last_name, first_name, middle_name, birth_date, gender)
VALUES (N'�������', N'������', N'��������', '1985-04-10', N'�');
UPDATE Appointments 
SET contract_term_days = 730 
WHERE employee_id = 1;
-- t1 --
-- t2 --
ROLLBACK;
GO

-- ������� 5: READ COMMITTED
PRINT '=== ������� 5: READ COMMITTED ===';
-- �������� A
BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT COUNT(*) 
FROM Appointments 
WHERE department_id = 1;
-- t1 --
-- t2 --
SELECT 'insert Appointments' AS '���������', COUNT(*) 
FROM Appointments 
WHERE department_id = 1;
COMMIT;
GO
-- �������� B
BEGIN TRANSACTION;
-- t1 --
INSERT INTO Appointments (employee_id, department_id, position_id, appointment_date, contract_term_days)
VALUES (1, 1, 1, '2023-02-01', 180);
COMMIT;
-- t2 --
GO

-- ������� 6: REPEATABLE READ
PRINT '=== ������� 6: REPEATABLE READ ===';
-- �������� A
BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT last_name 
FROM Employees 
WHERE department_id = (SELECT department_id FROM Appointments WHERE employee_id = 1);
-- t1 --
-- t2 --
SELECT CASE 
    WHEN last_name = N'�������' THEN 'insert Employees' 
    ELSE '' 
END AS '���������', last_name 
FROM Employees 
WHERE department_id = (SELECT department_id FROM Appointments WHERE employee_id = 1);
COMMIT;
GO
-- �������� B
BEGIN TRANSACTION;
-- t1 --
INSERT INTO Employees (last_name, first_name, middle_name, birth_date, gender)
VALUES (N'�������', N'����', N'����������', '1990-03-20', N'�');
COMMIT;
-- t2 --
GO

-- ������� 7: SERIALIZABLE
PRINT '=== ������� 7: SERIALIZABLE ===';
-- �������� A
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
-- �������� B
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

-- ������� 8: ��������� ����������
PRINT '=== ������� 8: ��������� ���������� ===';
BEGIN TRY
    BEGIN TRANSACTION OuterTran;
    PRINT '������� ����������� (������): ' + CAST(@@TRANCOUNT AS VARCHAR(10));
    INSERT INTO Employees (last_name, first_name, middle_name, birth_date, gender)
    VALUES (N'�������', N'����', N'����������', '1990-06-10', N'�');
    BEGIN TRANSACTION InnerTran;
    PRINT '������� ����������� (����������): ' + CAST(@@TRANCOUNT AS VARCHAR(10));
    INSERT INTO Appointments (employee_id, department_id, position_id, appointment_date, contract_term_days)
    VALUES (999, 1, 1, '2023-03-10', 365); -- ������: ��������� FOREIGN KEY
    COMMIT TRANSACTION InnerTran;
    COMMIT TRANSACTION OuterTran;
    PRINT '���������� ���������';
END TRY
BEGIN CATCH
    PRINT '������: ' + ERROR_MESSAGE();
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    PRINT '������� ����������� (����� ������): ' + CAST(@@TRANCOUNT AS VARCHAR(10));
END CATCH;
SELECT * FROM Employees WHERE last_name = N'�������';
SELECT * FROM Appointments WHERE employee_id = 999;
GO