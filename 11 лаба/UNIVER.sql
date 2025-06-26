USE UNIVER;
GO

PRINT 'Задание 1 (UNIVER): Список дисциплин на кафедре ТНХСиППМ';
DECLARE @subject_name NVARCHAR(100), @result NVARCHAR(MAX) = '';
DECLARE subject_cursor CURSOR LOCAL FOR 
    SELECT RTRIM(SUBJECT_NAME) 
    FROM dbo.SUBJECT 
    WHERE PULPIT = 'ТНХСиППМ';
OPEN subject_cursor;
FETCH subject_cursor INTO @subject_name;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @result = @result + @subject_name + ', ';
    FETCH subject_cursor INTO @subject_name;
END;
SET @result = LEFT(@result, LEN(@result) - 2);
PRINT 'Дисциплины: ' + @result;
CLOSE subject_cursor;
DEALLOCATE subject_cursor;
GO

PRINT 'Задание 2 (UNIVER): Локальный курсор';
DECLARE @teacher_code CHAR(10), @teacher_name NVARCHAR(100);
DECLARE teacher_cursor CURSOR LOCAL FOR 
    SELECT TEACHER, TEACHER_NAME 
    FROM dbo.TEACHER 
    WHERE PULPIT = 'ТНХСиППМ';
OPEN teacher_cursor;
FETCH teacher_cursor INTO @teacher_code, @teacher_name;
PRINT '1. ' + @teacher_code + ' ' + RTRIM(@teacher_name);
CLOSE teacher_cursor;
DEALLOCATE teacher_cursor;
GO

PRINT 'Задание 2 (UNIVER): Попытка доступа к локальному курсору';
DECLARE @teacher_code CHAR(10), @teacher_name NVARCHAR(100);
BEGIN TRY
    FETCH teacher_cursor INTO @teacher_code, @teacher_name;
    PRINT '2. ' + @teacher_code + ' ' + RTRIM(@teacher_name);
END TRY
BEGIN CATCH
    PRINT 'Ошибка: Курсор не существует';
END CATCH;
GO

PRINT 'Задание 2 (UNIVER): Глобальный курсор';
DECLARE @teacher_code CHAR(10), @teacher_name NVARCHAR(100);
DECLARE teacher_cursor CURSOR GLOBAL FOR 
    SELECT TEACHER, TEACHER_NAME 
    FROM dbo.TEACHER 
    WHERE PULPIT = 'ТНХСиППМ';
OPEN teacher_cursor;
FETCH teacher_cursor INTO @teacher_code, @teacher_name;
PRINT '1. ' + @teacher_code + ' ' + RTRIM(@teacher_name);
GO

PRINT 'Задание 2 (UNIVER): Доступ к глобальному курсору';
DECLARE @teacher_code CHAR(10), @teacher_name NVARCHAR(100);
FETCH teacher_cursor INTO @teacher_code, @teacher_name;
PRINT '2. ' + @teacher_code + ' ' + RTRIM(@teacher_name);
CLOSE teacher_cursor;
DEALLOCATE teacher_cursor;
GO

PRINT 'Задание 3 (UNIVER): Статический курсор';
DECLARE @subject_code CHAR(10), @subject_name NVARCHAR(100), @pulpit CHAR(20);
DECLARE subject_cursor CURSOR LOCAL STATIC FOR 
    SELECT SUBJECT, SUBJECT_NAME, PULPIT 
    FROM dbo.SUBJECT 
    WHERE PULPIT = 'ТНХСиППМ';
OPEN subject_cursor;
PRINT 'Количество строк: ' + CAST(@@CURSOR_ROWS AS VARCHAR(5));
UPDATE dbo.SUBJECT SET SUBJECT_NAME = 'Обновленное ПЗ' WHERE SUBJECT = 'ПЗ';
DELETE FROM dbo.SUBJECT WHERE SUBJECT = 'ПСП';
INSERT INTO dbo.SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES ('НОВ', 'Новая дисциплина', 'ТНХСиППМ');
FETCH subject_cursor INTO @subject_code, @subject_name, @pulpit;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @subject_code + ' ' + RTRIM(@subject_name) + ' ' + @pulpit;
    FETCH subject_cursor INTO @subject_code, @subject_name, @pulpit;
END;
CLOSE subject_cursor;
DEALLOCATE subject_cursor;
GO

UPDATE dbo.SUBJECT SET SUBJECT_NAME = 'Представление знаний в компьютерных системах' WHERE SUBJECT = 'ПЗ';
INSERT INTO dbo.SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES ('ПСП', 'Программирование сетевых приложений', 'ТНХСиППМ');
DELETE FROM dbo.SUBJECT WHERE SUBJECT = 'НОВ';
GO

PRINT 'Задание 3 (UNIVER): Динамический курсор';
DECLARE @subject_code CHAR(10), @subject_name NVARCHAR(100), @pulpit CHAR(20);
DECLARE subject_cursor CURSOR LOCAL DYNAMIC FOR 
    SELECT SUBJECT, SUBJECT_NAME, PULPIT 
    FROM dbo.SUBJECT 
    WHERE PULPIT = 'ТНХСиППМ';
OPEN subject_cursor;
PRINT 'Количество строк: ' + CAST(@@CURSOR_ROWS AS VARCHAR(5));
UPDATE dbo.SUBJECT SET SUBJECT_NAME = 'Обновленное ПЗ' WHERE SUBJECT = 'ПЗ';
DELETE FROM dbo.SUBJECT WHERE SUBJECT = 'ПСП';
INSERT INTO dbo.SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES ('НОВ', 'Новая дисциплина', 'ТНХСиППМ');
FETCH subject_cursor INTO @subject_code, @subject_name, @pulpit;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @subject_code + ' ' + RTRIM(@subject_name) + ' ' + @pulpit;
    FETCH subject_cursor INTO @subject_code, @subject_name, @pulpit;
END;
CLOSE subject_cursor;
DEALLOCATE subject_cursor;
GO

UPDATE dbo.SUBJECT SET SUBJECT_NAME = 'Представление знаний в компьютерных системах' WHERE SUBJECT = 'ПЗ';
INSERT INTO dbo.SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
VALUES ('ПСП', 'Программирование сетевых приложений', 'ТНХСиППМ');
DELETE FROM dbo.SUBJECT WHERE SUBJECT = 'НОВ';
GO

PRINT 'Задание 4 (UNIVER): Навигация с курсором SCROLL';
DECLARE @row_num INT, @subject_name NVARCHAR(100);
DECLARE subject_cursor CURSOR LOCAL DYNAMIC SCROLL FOR 
    SELECT ROW_NUMBER() OVER (ORDER BY SUBJECT_NAME) AS N, SUBJECT_NAME 
    FROM dbo.SUBJECT 
    WHERE PULPIT = 'ТНХСиППМ';
OPEN subject_cursor;
FETCH FIRST FROM subject_cursor INTO @row_num, @subject_name;
PRINT 'Первая строка: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@subject_name);
FETCH NEXT FROM subject_cursor INTO @row_num, @subject_name;
PRINT 'Следующая строка: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@subject_name);
FETCH PRIOR FROM subject_cursor INTO @row_num, @subject_name;
PRINT 'Предыдущая строка: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@subject_name);
FETCH LAST FROM subject_cursor INTO @row_num, @subject_name;
PRINT 'Последняя строка: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@subject_name);
FETCH ABSOLUTE 3 FROM subject_cursor INTO @row_num, @subject_name;
PRINT 'Третья строка от начала: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@subject_name);
FETCH ABSOLUTE -3 FROM subject_cursor INTO @row_num, @subject_name;
PRINT 'Третья строка от конца: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@subject_name);
FETCH RELATIVE 2 FROM subject_cursor INTO @row_num, @subject_name;
PRINT 'Две строки вперед: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@subject_name);
FETCH RELATIVE -2 FROM subject_cursor INTO @row_num, @subject_name;
PRINT 'Две строки назад: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@subject_name);
CLOSE subject_cursor;
DEALLOCATE subject_cursor;
GO

PRINT 'Задание 5 (UNIVER): Курсор с CURRENT OF';
DECLARE @subject_code CHAR(10), @subject_name NVARCHAR(100);
DECLARE subject_cursor CURSOR LOCAL DYNAMIC FOR 
    SELECT SUBJECT, SUBJECT_NAME 
    FROM dbo.SUBJECT 
    WHERE PULPIT = 'ТНХСиППМ' 
    FOR UPDATE;
OPEN subject_cursor;
FETCH subject_cursor INTO @subject_code, @subject_name;
DELETE FROM dbo.PROGRESS WHERE SUBJECT = @subject_code;
DELETE FROM dbo.SUBJECT WHERE CURRENT OF subject_cursor;
FETCH subject_cursor INTO @subject_code, @subject_name;
UPDATE dbo.SUBJECT SET SUBJECT_NAME = RTRIM(@subject_name) + ' (обновлено)' 
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

IF NOT EXISTS (SELECT 1 FROM dbo.SUBJECT WHERE SUBJECT = 'ПЗ')
    INSERT INTO dbo.SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) 
    VALUES ('ПЗ', 'Представление знаний в компьютерных системах', 'ТНХСиППМ');
UPDATE dbo.SUBJECT SET SUBJECT_NAME = 'Программирование сетевых приложений' WHERE SUBJECT = 'ПСП';
GO

PRINT 'Задание 6 (UNIVER): Удаление строк с оценками ниже 4';
DELETE FROM dbo.PROGRESS 
WHERE IDSTUDENT IN (
    SELECT p.IDSTUDENT 
    FROM dbo.PROGRESS p
    JOIN dbo.STUDENT s ON p.IDSTUDENT = s.IDSTUDENT
    JOIN dbo.[GROUP] g ON s.IDGROUP = g.IDGROUP
    WHERE p.NOTE < 4
);
GO

PRINT 'Задание 6 (UNIVER): Обновление оценки для студента с IDSTUDENT = 1001';
UPDATE dbo.PROGRESS 
SET NOTE = NOTE + 1 
WHERE IDSTUDENT = 1001;
GO