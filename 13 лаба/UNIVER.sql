-- ������� ������������ ���������, ���� ��� ��� �������
IF OBJECT_ID('PSUBJECT', 'P') IS NOT NULL DROP PROCEDURE PSUBJECT;
IF OBJECT_ID('PAUDITORIUM_INSERT', 'P') IS NOT NULL DROP PROCEDURE PAUDITORIUM_INSERT;
IF OBJECT_ID('PAUDITORIUM_INSERTX', 'P') IS NOT NULL DROP PROCEDURE PAUDITORIUM_INSERTX;
IF OBJECT_ID('SUBJECT_REPORT', 'P') IS NOT NULL DROP PROCEDURE SUBJECT_REPORT;
GO

-- �������� ��������� PSUBJECT
CREATE PROCEDURE PSUBJECT
AS
BEGIN
    SELECT * FROM SUBJECT;
    SELECT COUNT(*) AS '����� ���������� ���������' FROM SUBJECT;
END;
GO

-- �������� ��������� PAUDITORIUM_INSERT
CREATE PROCEDURE PAUDITORIUM_INSERT
    @a CHAR(10),
    @c INT,
    @t CHAR(10)
AS
BEGIN
    -- �������� ������������� ���� ���������
    IF NOT EXISTS (SELECT 1 FROM AUDITORIUM_TYPE WHERE AUDITORIUM_TYPE = @t)
    BEGIN
        PRINT '��� ��������� �� ����������. ���������...';
        INSERT INTO AUDITORIUM_TYPE (AUDITORIUM_TYPE) VALUES (@t);
    END

    -- �������� ������������ ���������
    IF NOT EXISTS (SELECT 1 FROM AUDITORIUM WHERE AUDITORIUM = @a)
    BEGIN
        INSERT INTO AUDITORIUM (AUDITORIUM, AUDITORIUM_CAPACITY, AUDITORIUM_TYPE)
        VALUES (@a, @c, @t);
    END
    ELSE
    BEGIN
        RAISERROR('��������� ��� ����������', 11, 1);
    END
END;
GO

-- �������� ��������� SUBJECT_REPORT
CREATE PROCEDURE SUBJECT_REPORT
    @p CHAR(20),
    @rc INT OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.SUBJECT WHERE PULPIT = @p)
    BEGIN
        RAISERROR('������ � ����������', 11, 1);
        SET @rc = 0;
        RETURN;
    END

    SELECT SUBJECT_NAME FROM dbo.SUBJECT WHERE PULPIT = @p;
    SELECT @rc = COUNT(*) FROM dbo.SUBJECT WHERE PULPIT = @p;
END;
GO

-- �������� ��������� PAUDITORIUM_INSERTX (������� ���������� ���������)
CREATE PROCEDURE PAUDITORIUM_INSERTX
AS
BEGIN
    DECLARE @count INT = 0;

    -- ��������� ��� ��-�, ���� ��� ���
    IF NOT EXISTS (SELECT 1 FROM AUDITORIUM_TYPE WHERE AUDITORIUM_TYPE = '��-�')
    BEGIN
        INSERT INTO AUDITORIUM_TYPE (AUDITORIUM_TYPE) VALUES ('��-�');
    END

    -- ������ ���������
    DECLARE @a TABLE (AUD CHAR(10), CAP INT);
    INSERT INTO @a VALUES ('500-1', 40), ('501-1', 40), ('600-1', 20), ('601-1', 20);

    DECLARE @name CHAR(10), @cap INT;

    DECLARE cur CURSOR FOR SELECT AUD, CAP FROM @a;
    OPEN cur;

    FETCH NEXT FROM cur INTO @name, @cap;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC PAUDITORIUM_INSERT @name, @cap, '��-�';
        FETCH NEXT FROM cur INTO @name, @cap;
        SET @count = @count + 1;
    END

    CLOSE cur;
    DEALLOCATE cur;

    PRINT '��������� ���������: ' + CAST(@count AS VARCHAR);
END;
GO

-- ���������� �������� � ��������

-- �������� SUBJECT (��� �������� + ����������)
EXEC PSUBJECT;
GO

-- �������� SUBJECT_REPORT
DECLARE @cnt INT;
EXEC SUBJECT_REPORT '��', @cnt OUTPUT;
PRINT '���������� ���������: ' + CAST(@cnt AS VARCHAR);
GO

-- �������� � �������������� ��������
EXEC SUBJECT_REPORT '����������', @cnt OUTPUT;
PRINT '���������� ���������: ' + CAST(@cnt AS VARCHAR);
GO

-- ������� ���������
EXEC PAUDITORIUM_INSERTX;
GO