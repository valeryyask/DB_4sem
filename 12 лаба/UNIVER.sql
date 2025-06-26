USE UNIVER;
GO
SET NOCOUNT ON;

-- ������� 1: ������� ����������
PRINT '=== ������� 1: ������� ���������� ===';
IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'DBO.Y'))
    DROP TABLE Y;

DECLARE @count INT, @flag CHAR = 'c';
SET IMPLICIT_TRANSACTIONS ON;
CREATE TABLE Y (ID INT PRIMARY KEY, Name NVARCHAR(50));
INSERT INTO Y VALUES (1, N'������'), (2, N'������'), (3, N'�������');
SET @count = (SELECT COUNT(*) FROM Y);
PRINT '���������� ����� � ������� Y: ' + CAST(@count AS VARCHAR(2));
IF @flag = 'c'
    COMMIT;
ELSE
    ROLLBACK;
SET IMPLICIT_TRANSACTIONS OFF;
IF EXISTS (SELECT * FROM SYS.OBJECTS WHERE OBJECT_ID = OBJECT_ID(N'DBO.Y'))
    PRINT '������� Y ����������';
ELSE
    PRINT '������� Y ���';
GO

-- ������� 2: ����������� ����� ����������
PRINT '=== ������� 2: ����������� ����� ���������� ===';
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO STUDENT (IDGROUP, [NAME], BDAY)
    VALUES (22, N'������ �������', '1996-03-15');
    UPDATE STUDENT
    SET IDGROUP = 999 -- ������: ��������� �������� �����
    WHERE IDSTUDENT = 1000;
    COMMIT TRANSACTION;
    PRINT '���������� ������� ���������';
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ConstraintName NVARCHAR(100);
    SET @ConstraintName = CASE
        WHEN PATINDEX('%constraint%[FK_][A-Z_0-9]%]', @ErrorMessage) > 0
        THEN SUBSTRING(@ErrorMessage, PATINDEX('%constraint%[FK_][A-Z_0-9]%]', @ErrorMessage) + 11, 50)
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
    INSERT INTO PROGRESS (SUBJECT, IDSTUDENT, PDATE, NOTE)
    VALUES ('��', 1002, '2014-02-01', 7);
    SAVE TRANSACTION SavePoint;
    UPDATE PROGRESS
    SET NOTE = 11 
    WHERE IDSTUDENT = 1002;
    COMMIT TRANSACTION;
    PRINT '���������� ������� ���������';
END TRY
BEGIN CATCH
    PRINT '������: ' + ERROR_MESSAGE();
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION SavePoint;
    COMMIT TRANSACTION;
    PRINT '����� �� ����������� �����';
END CATCH;
SELECT * FROM PROGRESS WHERE IDSTUDENT = 1002;
GO

-- ������� 4: READ UNCOMMITTED
PRINT '=== ������� 4: READ UNCOMMITTED ===';
-- �������� A
BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- t1 --
SELECT @@SPID, 'insert STUDENT' AS '���������', * 
FROM STUDENT 
WHERE [NAME] = N'������� ������';
SELECT @@SPID, 'update PROGRESS' AS '���������', NOTE 
FROM PROGRESS 
WHERE IDSTUDENT = 1000;
-- t2 --
COMMIT;
GO
-- �������� B
BEGIN TRANSACTION;
SELECT @@SPID;
INSERT INTO STUDENT (IDGROUP, [NAME], BDAY)
VALUES (22, N'������� ������', '1996-04-10');
UPDATE PROGRESS 
SET NOTE = 8 
WHERE IDSTUDENT = 1000;
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
FROM PROGRESS 
WHERE SUBJECT = '��';
-- t1 --
-- t2 --
SELECT 'update PROGRESS' AS '���������', COUNT(*) 
FROM PROGRESS 
WHERE SUBJECT = '��';
COMMIT;
GO
-- �������� B
BEGIN TRANSACTION;
-- t1 --
INSERT INTO PROGRESS (SUBJECT, IDSTUDENT, PDATE, NOTE)
VALUES ('��', 1004, '2014-02-15', 6);
COMMIT;
-- t2 --
GO

-- ������� 6: REPEATABLE READ
PRINT '=== ������� 6: REPEATABLE READ ===';
-- �������� A
BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT [NAME] 
FROM STUDENT 
WHERE IDGROUP = 22;
-- t1 --
-- t2 --
SELECT CASE 
    WHEN [NAME] = N'������ �������' THEN 'insert STUDENT' 
    ELSE '' 
END AS '���������', [NAME] 
FROM STUDENT 
WHERE IDGROUP = 22;
COMMIT;
GO
-- �������� B
BEGIN TRANSACTION;
-- t1 --
INSERT INTO STUDENT (IDGROUP, [NAME], BDAY)
VALUES (22, N'������ �������', '1996-03-20');
COMMIT;
-- t2 --
GO

-- ������� 7: SERIALIZABLE
PRINT '=== ������� 7: SERIALIZABLE ===';
-- �������� A
BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DELETE FROM PROGRESS 
WHERE IDSTUDENT = 1000;
INSERT INTO PROGRESS (SUBJECT, IDSTUDENT, PDATE, NOTE)
VALUES ('����', 1000, '2014-03-01', 7);
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
-- �������� B
BEGIN TRANSACTION;
DELETE FROM PROGRESS 
WHERE IDSTUDENT = 1000;
INSERT INTO PROGRESS (SUBJECT, IDSTUDENT, PDATE, NOTE)
VALUES ('����', 1000, '2014-03-01', 7);
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

-- ������� 8: ��������� ����������
PRINT '=== ������� 8: ��������� ���������� ===';
BEGIN TRY
    BEGIN TRANSACTION OuterTran;
    PRINT '������� ����������� (������): ' + CAST(@@TRANCOUNT AS VARCHAR(10));
    INSERT INTO STUDENT (IDGROUP, [NAME], BDAY)
    VALUES (22, N'������� ����', '1996-06-10');
    BEGIN TRANSACTION InnerTran;
    PRINT '������� ����������� (����������): ' + CAST(@@TRANCOUNT AS VARCHAR(10));
    INSERT INTO PROGRESS (SUBJECT, IDSTUDENT, PDATE, NOTE)
    VALUES ('��', 1008, '2014-03-10', 11); -- ������: ��������� CHECK
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
SELECT * FROM STUDENT WHERE [NAME] = N'������� ����';
SELECT * FROM PROGRESS WHERE IDSTUDENT = 1008;
GO