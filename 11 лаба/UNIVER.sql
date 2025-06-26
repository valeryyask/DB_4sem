USE UNIVER;
GO

PRINT '������� 1 (UNIVER): ������ ��������� �� ������� ��������';
DECLARE @subject_name NVARCHAR(100), @result NVARCHAR(MAX) = '';
DECLARE subject_cursor CURSOR LOCAL FOR 
    SELECT RTRIM(SUBJECT_NAME) 
    FROM dbo.SUBJECT 
    WHERE PULPIT = '��������';
OPEN subject_cursor;
FETCH subject_cursor INTO @subject_name;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @result = @result + @subject_name + ', ';
    FETCH subject_cursor INTO @subject_name;
END;
SET @result = LEFT(@result, LEN(@result) - 2);
PRINT '����������: ' + @result;
CLOSE subject_cursor;
DEALLOCATE subject_cursor;
GO

PRINT '������� 2 (UNIVER): ��������� ������';
DECLARE @teacher_code CHAR(10), @teacher_name NVARCHAR(100);
DECLARE teacher_cursor CURSOR LOCAL FOR 
    SELECT TEACHER, TEACHER_NAME 
    FROM dbo.TEACHER 
    WHERE PULPIT = '��������';
OPEN teacher_cursor;
FETCH teacher_cursor INTO @teacher_code, @teacher_name;
PRINT '1. ' + @teacher_code + ' ' + RTRIM(@teacher_name);
CLOSE teacher_cursor;
DEALLOCATE teacher_cursor;
GO

PRINT '������� 2 (UNIVER): ������� ������� � ���������� �������';
DECLARE @teacher_code CHAR(10), @teacher_name NVARCHAR(100);
BEGIN TRY
    FETCH teacher_cursor INTO @teacher_code, @teacher_name;
    PRINT '2. ' + @teacher_code + ' ' + RTRIM(@teacher_name);
END TRY
BEGIN CATCH
    PRINT '������: ������ �� ����������';
END CATCH;
GO

PRINT '������� 2 (UNIVER): ���������� ������';
DECLARE @teacher_code CHAR(10), @teacher_name NVARCHAR(100);
DECLARE teacher_cursor CURSOR GLOBAL FOR 
    SELECT TEACHER, TEACHER_NAME 
    FROM dbo.TEACHER 
    WHERE PULPIT = '��������';
OPEN teacher_cursor;
FETCH teacher_cursor INTO @teacher_code, @teacher_name;
PRINT '1. ' + @teacher_code + ' ' + RTRIM(@teacher_name);
GO

PRINT '������� 2 (UNIVER): ������ � ����������� �������';
DECLARE @teacher_code CHAR(10), @teacher_name NVARCHAR(100);
FETCH teacher_cursor INTO @teacher_code, @teacher_name;
PRINT '2. ' + @teacher_code + ' ' + RTRIM(@teacher_name);
CLOSE teacher_cursor;
DEALLOCATE teacher_cursor;
GO

PRINT '������� 3 (UNIVER): ����������� ������';
DECLARE @subject_code CHAR(10), @subject_name NVARCHAR(100), @pulpit CHAR(20);
DECLARE subject_cursor CURSOR LOCAL STATIC FOR 
    SELECT SUBJECT, SUBJECT_NAME, PULPIT 
    FROM dbo.SUBJECT 
    WHERE PULPIT = '��������';
OPEN subject_cursor;
PRINT '���������� �����: ' + CAST(@@CURSOR_ROWS AS VARCHAR(5));
UPDATE dbo.SUBJECT SET SUBJECT_NAME = '����������� ��' WHERE SUBJECT = '��';
DELETE FROM dbo.SUBJECT WHERE SUBJECT = '���';
INSERT INTO dbo.SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES ('���', '����� ����������', '��������');
FETCH subject_cursor INTO @subject_code, @subject_name, @pulpit;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @subject_code + ' ' + RTRIM(@subject_name) + ' ' + @pulpit;
    FETCH subject_cursor INTO @subject_code, @subject_name, @pulpit;
END;
CLOSE subject_cursor;
DEALLOCATE subject_cursor;
GO

UPDATE dbo.SUBJECT SET SUBJECT_NAME = '������������� ������ � ������������ ��������' WHERE SUBJECT = '��';
INSERT INTO dbo.SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES ('���', '���������������� ������� ����������', '��������');
DELETE FROM dbo.SUBJECT WHERE SUBJECT = '���';
GO

PRINT '������� 3 (UNIVER): ������������ ������';
DECLARE @subject_code CHAR(10), @subject_name NVARCHAR(100), @pulpit CHAR(20);
DECLARE subject_cursor CURSOR LOCAL DYNAMIC FOR 
    SELECT SUBJECT, SUBJECT_NAME, PULPIT 
    FROM dbo.SUBJECT 
    WHERE PULPIT = '��������';
OPEN subject_cursor;
PRINT '���������� �����: ' + CAST(@@CURSOR_ROWS AS VARCHAR(5));
UPDATE dbo.SUBJECT SET SUBJECT_NAME = '����������� ��' WHERE SUBJECT = '��';
DELETE FROM dbo.SUBJECT WHERE SUBJECT = '���';
INSERT INTO dbo.SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES ('���', '����� ����������', '��������');
FETCH subject_cursor INTO @subject_code, @subject_name, @pulpit;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @subject_code + ' ' + RTRIM(@subject_name) + ' ' + @pulpit;
    FETCH subject_cursor INTO @subject_code, @subject_name, @pulpit;
END;
CLOSE subject_cursor;
DEALLOCATE subject_cursor;
GO

UPDATE dbo.SUBJECT SET SUBJECT_NAME = '������������� ������ � ������������ ��������' WHERE SUBJECT = '��';
INSERT INTO dbo.SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES ('���', '���������������� ������� ����������', '��������');
DELETE FROM dbo.SUBJECT WHERE SUBJECT = '���';
GO

PRINT '������� 4 (UNIVER): ��������� � �������� SCROLL';
DECLARE @row_num INT, @subject_name NVARCHAR(100);
DECLARE subject_cursor CURSOR LOCAL DYNAMIC SCROLL FOR 
    SELECT ROW_NUMBER() OVER (ORDER BY SUBJECT_NAME) AS N, SUBJECT_NAME 
    FROM dbo.SUBJECT 
    WHERE PULPIT = '��������';
OPEN subject_cursor;
FETCH FIRST FROM subject_cursor INTO @row_num, @subject_name;
PRINT '������ ������: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@subject_name);
FETCH NEXT FROM subject_cursor INTO @row_num, @subject_name;
PRINT '��������� ������: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@subject_name);
FETCH PRIOR FROM subject_cursor INTO @row_num, @subject_name;
PRINT '���������� ������: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@subject_name);
FETCH LAST FROM subject_cursor INTO @row_num, @subject_name;
PRINT '��������� ������: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@subject_name);
FETCH ABSOLUTE 3 FROM subject_cursor INTO @row_num, @subject_name;
PRINT '������ ������ �� ������: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@subject_name);
FETCH ABSOLUTE -3 FROM subject_cursor INTO @row_num, @subject_name;
PRINT '������ ������ �� �����: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@subject_name);
FETCH RELATIVE 2 FROM subject_cursor INTO @row_num, @subject_name;
PRINT '��� ������ ������: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@subject_name);
FETCH RELATIVE -2 FROM subject_cursor INTO @row_num, @subject_name;
PRINT '��� ������ �����: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@subject_name);
CLOSE subject_cursor;
DEALLOCATE subject_cursor;
GO

PRINT '������� 5 (UNIVER): ������ � CURRENT OF';
DECLARE @subject_code CHAR(10), @subject_name NVARCHAR(100);
DECLARE subject_cursor CURSOR LOCAL DYNAMIC FOR 
    SELECT SUBJECT, SUBJECT_NAME 
    FROM dbo.SUBJECT 
    WHERE PULPIT = '��������' 
    FOR UPDATE;
OPEN subject_cursor;
FETCH subject_cursor INTO @subject_code, @subject_name;
DELETE FROM dbo.PROGRESS WHERE SUBJECT = @subject_code;
DELETE FROM dbo.SUBJECT WHERE CURRENT OF subject_cursor;
FETCH subject_cursor INTO @subject_code, @subject_name;
UPDATE dbo.SUBJECT SET SUBJECT_NAME = RTRIM(@subject_name) + ' (���������)' 
WHERE CURRENT OF subject_cursor;
FETCH subject_cursor INTO @subject_code, @subject_name;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @subject_code + ' ' + RTRIM(@subject_name);
    FETCH subject_cursor INTO @subject_code, @subject_name;
END;
CLOSE subject_cursor;
DEALLOCATE subject_cursor;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.SUBJECT WHERE SUBJECT = '��')
    INSERT INTO dbo.SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
    VALUES ('��', '������������� ������ � ������������ ��������', '��������');
UPDATE dbo.SUBJECT SET SUBJECT_NAME = '���������������� ������� ����������' WHERE SUBJECT = '���';
GO

PRINT '������� 6 (UNIVER): �������� ����� � �������� ���� 4';
DELETE FROM dbo.PROGRESS 
WHERE IDSTUDENT IN (
    SELECT p.IDSTUDENT 
    FROM dbo.PROGRESS p
    JOIN dbo.STUDENT s ON p.IDSTUDENT = s.IDSTUDENT
    JOIN dbo.[GROUP] g ON s.IDGROUP = g.IDGROUP
    WHERE p.NOTE < 4
);
GO

PRINT '������� 6 (UNIVER): ���������� ������ ��� �������� � IDSTUDENT = 1001';
UPDATE dbo.PROGRESS 
SET NOTE = NOTE + 1 
WHERE IDSTUDENT = 1001;
GO