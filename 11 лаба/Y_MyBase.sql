USE Y_MyBase;
GO

DELETE FROM dbo.Appointments;
DELETE FROM dbo.Employees;
DELETE FROM dbo.Positions;
DELETE FROM dbo.Departments;
GO

SET IDENTITY_INSERT dbo.Departments ON;
INSERT INTO dbo.Departments (department_id, department_name) 
VALUES (1, N'ИТ-отдел');
SET IDENTITY_INSERT dbo.Departments OFF;

SET IDENTITY_INSERT dbo.Positions ON;
INSERT INTO dbo.Positions (position_id, position_title) 
VALUES 
    (1, N'Программист'),
    (2, N'Аналитик'),
    (3, N'Менеджер');
SET IDENTITY_INSERT dbo.Positions OFF;

SET IDENTITY_INSERT dbo.Employees ON;
INSERT INTO dbo.Employees (employee_id, last_name, first_name, birth_date, gender) 
VALUES 
    (1, N'Иванов', N'Иван', '1990-01-01', N'М'),
    (2, N'Петров', N'Сергей', '1985-05-05', N'М'),
    (3, N'Белов', N'Алексей', '1988-03-15', N'М'),
    (4, N'Зайцев', N'Дмитрий', '1992-07-20', N'М'),
    (5, N'Смирнов', N'Николай', '1990-11-11', N'М'),
    (6, N'Морозов', N'Владимир', '1987-09-25', N'М'),
    (7, N'Ковалёв', N'Олег', '1991-04-30', N'М'),
    (8, N'Никитин', N'Павел', '1989-12-12', N'М'),
    (9, N'Лазарев', N'Игорь', '1993-06-18', N'М'),
    (10, N'Романов', N'Андрей', '1986-02-28', N'М');
SET IDENTITY_INSERT dbo.Employees OFF;

SET IDENTITY_INSERT dbo.Appointments ON;
INSERT INTO dbo.Appointments (appointment_id, employee_id, department_id, position_id, appointment_date, contract_term_days) 
VALUES 
    (1, 1, 1, 1, '2024-01-01', 90),
    (2, 2, 1, 2, '2024-02-01', 60),
    (3, 3, 1, 3, '2024-03-01', 30),
    (4, 4, 1, 1, '2024-04-01', 120),
    (5, 5, 1, 2, '2024-05-01', 15);
SET IDENTITY_INSERT dbo.Appointments OFF;
GO

PRINT 'Задание 1 (Y_MyBase): Список должностей в отделе с department_id = 1';
DECLARE @position_title NVARCHAR(100), @result NVARCHAR(MAX) = '';
DECLARE position_cursor CURSOR LOCAL FOR 
    SELECT DISTINCT RTRIM(p.position_title) 
    FROM dbo.Positions p
    JOIN dbo.Appointments a ON p.position_id = a.position_id
    WHERE a.department_id = 1;
OPEN position_cursor;
FETCH position_cursor INTO @position_title;
IF @@FETCH_STATUS = 0
BEGIN
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @result = @result + @position_title + ', ';
        FETCH position_cursor INTO @position_title;
    END;
    SET @result = LEFT(@result, LEN(@result) - 2);
    PRINT 'Должности: ' + @result;
END
ELSE
    PRINT 'Должности: нет данных';
CLOSE position_cursor;
DEALLOCATE position_cursor;
GO

PRINT 'Задание 2 (Y_MyBase): Локальный курсор';
DECLARE @employee_id INT, @last_name NVARCHAR(50);
DECLARE employee_cursor CURSOR LOCAL FOR 
    SELECT employee_id, last_name 
    FROM dbo.Employees 
    WHERE gender = N'М';
OPEN employee_cursor;
FETCH employee_cursor INTO @employee_id, @last_name;
IF @@FETCH_STATUS = 0
    PRINT '1. ' + CAST(@employee_id AS VARCHAR(10)) + ' ' + RTRIM(@last_name);
ELSE
    PRINT 'Нет данных';
CLOSE employee_cursor;
DEALLOCATE employee_cursor;
GO

PRINT 'Задание 2 (Y_MyBase): Попытка доступа к локальному курсору';
DECLARE @employee_id INT, @last_name NVARCHAR(50);
BEGIN TRY
    FETCH employee_cursor INTO @employee_id, @last_name;
    PRINT '2. ' + CAST(@employee_id AS VARCHAR(10)) + ' ' + RTRIM(@last_name);
END TRY
BEGIN CATCH
    PRINT 'Ошибка: Курсор не существует';
END CATCH;
GO

PRINT 'Задание 2 (Y_MyBase): Глобальный курсор';
DECLARE @employee_id INT, @last_name NVARCHAR(50);
DECLARE employee_cursor CURSOR GLOBAL FOR 
    SELECT employee_id, last_name 
    FROM dbo.Employees 
    WHERE gender = N'М';
OPEN employee_cursor;
FETCH employee_cursor INTO @employee_id, @last_name;
IF @@FETCH_STATUS = 0
    PRINT '1. ' + CAST(@employee_id AS VARCHAR(10)) + ' ' + RTRIM(@last_name);
ELSE
    PRINT 'Нет данных';
GO

PRINT 'Задание 2 (Y_MyBase): Доступ к глобальному курсору';
DECLARE @employee_id INT, @last_name NVARCHAR(50);
FETCH employee_cursor INTO @employee_id, @last_name;
IF @@FETCH_STATUS = 0
    PRINT '2. ' + CAST(@employee_id AS VARCHAR(10)) + ' ' + RTRIM(@last_name);
ELSE
    PRINT 'Нет данных';
CLOSE employee_cursor;
DEALLOCATE employee_cursor;
GO

PRINT 'Задание 3 (Y_MyBase): Статический курсор';
DECLARE @employee_id INT, @last_name NVARCHAR(50), @department_id INT;
DECLARE employee_cursor CURSOR LOCAL STATIC FOR 
    SELECT e.employee_id, e.last_name, a.department_id 
    FROM dbo.Employees e
    JOIN dbo.Appointments a ON e.employee_id = a.employee_id
    WHERE a.department_id = 1;
OPEN employee_cursor;
PRINT 'Количество строк: ' + CAST(@@CURSOR_ROWS AS VARCHAR(5));
UPDATE dbo.Employees SET last_name = 'Обновленный' WHERE employee_id = 1;
DELETE FROM dbo.Appointments WHERE employee_id = 2;
DELETE FROM dbo.Employees WHERE employee_id = 2;
INSERT INTO dbo.Employees (last_name, first_name, birth_date, gender) 
VALUES ('Новый', 'Иван', '1990-01-01', N'М');
FETCH employee_cursor INTO @employee_id, @last_name, @department_id;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT CAST(@employee_id AS VARCHAR(10)) + ' ' + RTRIM(@last_name) + ' ' + CAST(@department_id AS VARCHAR(10));
    FETCH employee_cursor INTO @employee_id, @last_name, @department_id;
END;
CLOSE employee_cursor;
DEALLOCATE employee_cursor;
GO

UPDATE dbo.Employees SET last_name = 'Иванов' WHERE employee_id = 1;
SET IDENTITY_INSERT dbo.Employees ON;
IF NOT EXISTS (SELECT 1 FROM dbo.Employees WHERE employee_id = 2)
    INSERT INTO dbo.Employees (employee_id, last_name, first_name, birth_date, gender) 
    VALUES (2, 'Петров', 'Сергей', '1985-05-05', N'М');
SET IDENTITY_INSERT dbo.Employees OFF;
SET IDENTITY_INSERT dbo.Appointments ON;
IF NOT EXISTS (SELECT 1 FROM dbo.Appointments WHERE appointment_id = 2)
    INSERT INTO dbo.Appointments (appointment_id, employee_id, department_id, position_id, appointment_date, contract_term_days) 
    VALUES (2, 2, 1, 2, '2024-02-01', 60);
SET IDENTITY_INSERT dbo.Appointments OFF;
DELETE FROM dbo.Employees WHERE last_name = 'Новый';
GO

PRINT 'Задание 3 (Y_MyBase): Динамический курсор';
DECLARE @employee_id INT, @last_name NVARCHAR(50), @department_id INT;
DECLARE employee_cursor CURSOR LOCAL DYNAMIC FOR 
    SELECT e.employee_id, e.last_name, a.department_id 
    FROM dbo.Employees e
    JOIN dbo.Appointments a ON e.employee_id = a.employee_id
    WHERE a.department_id = 1;
OPEN employee_cursor;
PRINT 'Количество строк: ' + CAST(@@CURSOR_ROWS AS VARCHAR(5));
UPDATE dbo.Employees SET last_name = 'Обновленный' WHERE employee_id = 1;
DELETE FROM dbo.Appointments WHERE employee_id = 2;
DELETE FROM dbo.Employees WHERE employee_id = 2;
INSERT INTO dbo.Employees (last_name, first_name, birth_date, gender) 
VALUES ('Новый', 'Иван', '1990-01-01', N'М');
FETCH employee_cursor INTO @employee_id, @last_name, @department_id;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT CAST(@employee_id AS VARCHAR(10)) + ' ' + RTRIM(@last_name) + ' ' + CAST(@department_id AS VARCHAR(10));
    FETCH employee_cursor INTO @employee_id, @last_name, @department_id;
END;
CLOSE employee_cursor;
DEALLOCATE employee_cursor;
GO

UPDATE dbo.Employees SET last_name = 'Иванов' WHERE employee_id = 1;
SET IDENTITY_INSERT dbo.Employees ON;
IF NOT EXISTS (SELECT 1 FROM dbo.Employees WHERE employee_id = 2)
    INSERT INTO dbo.Employees (employee_id, last_name, first_name, birth_date, gender) 
    VALUES (2, 'Петров', 'Сергей', '1985-05-05', N'М');
SET IDENTITY_INSERT dbo.Employees OFF;
SET IDENTITY_INSERT dbo.Appointments ON;
IF NOT EXISTS (SELECT 1 FROM dbo.Appointments WHERE appointment_id = 2)
    INSERT INTO dbo.Appointments (appointment_id, employee_id, department_id, position_id, appointment_date, contract_term_days) 
    VALUES (2, 2, 1, 2, '2024-02-01', 60);
SET IDENTITY_INSERT dbo.Appointments OFF;
DELETE FROM dbo.Employees WHERE last_name = 'Новый';
GO

PRINT 'Задание 4 (Y_MyBase): Навигация с курсором SCROLL';
DECLARE @row_num INT, @last_name NVARCHAR(50);
DECLARE employee_cursor CURSOR LOCAL DYNAMIC SCROLL FOR 
    SELECT ROW_NUMBER() OVER (ORDER BY last_name) AS N, last_name 
    FROM dbo.Employees 
    WHERE gender = N'М';
OPEN employee_cursor;
FETCH FIRST FROM employee_cursor INTO @row_num, @last_name;
IF @@FETCH_STATUS = 0
    PRINT 'Первая строка: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@last_name);
ELSE
    PRINT 'Первая строка: нет данных';
FETCH NEXT FROM employee_cursor INTO @row_num, @last_name;
IF @@FETCH_STATUS = 0
    PRINT 'Следующая строка: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@last_name);
FETCH PRIOR FROM employee_cursor INTO @row_num, @last_name;
IF @@FETCH_STATUS = 0
    PRINT 'Предыдущая строка: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@last_name);
FETCH LAST FROM employee_cursor INTO @row_num, @last_name;
IF @@FETCH_STATUS = 0
    PRINT 'Последняя строка: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@last_name);
FETCH ABSOLUTE 3 FROM employee_cursor INTO @row_num, @last_name;
IF @@FETCH_STATUS = 0
    PRINT 'Третья строка от начала: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@last_name);
FETCH ABSOLUTE -3 FROM employee_cursor INTO @row_num, @last_name;
IF @@FETCH_STATUS = 0
    PRINT 'Третья строка от конца: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@last_name);
FETCH RELATIVE 2 FROM employee_cursor INTO @row_num, @last_name;
IF @@FETCH_STATUS = 0
    PRINT 'Две строки вперед: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@last_name);
FETCH RELATIVE -2 FROM employee_cursor INTO @row_num, @last_name;
IF @@FETCH_STATUS = 0
    PRINT 'Две строки назад: ' + CAST(@row_num AS VARCHAR(3)) + ' ' + RTRIM(@last_name);
CLOSE employee_cursor;
DEALLOCATE employee_cursor;
GO

PRINT 'Задание 5 (Y_MyBase): Курсор с CURRENT OF';
DECLARE @employee_id INT, @last_name NVARCHAR(50);
DECLARE employee_cursor CURSOR LOCAL DYNAMIC FOR 
    SELECT employee_id, last_name 
    FROM dbo.Employees 
    WHERE gender = N'М' 
    FOR UPDATE;
OPEN employee_cursor;
FETCH employee_cursor INTO @employee_id, @last_name;
IF @@FETCH_STATUS = 0
BEGIN
    DELETE FROM dbo.Appointments WHERE employee_id = @employee_id;
    DELETE FROM dbo.Employees WHERE CURRENT OF employee_cursor;
    FETCH employee_cursor INTO @employee_id, @last_name;
    IF @@FETCH_STATUS = 0
    BEGIN
        UPDATE dbo.Employees SET last_name = RTRIM(@last_name) + ' (обновлено)' 
        WHERE CURRENT OF employee_cursor;
        FETCH employee_cursor INTO @employee_id, @last_name;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            PRINT CAST(@employee_id AS VARCHAR(10)) + ' ' + RTRIM(@last_name);
            FETCH employee_cursor INTO @employee_id, @last_name;
        END;
    END;
END
ELSE
    PRINT 'Нет данных';
CLOSE employee_cursor;
DEALLOCATE employee_cursor;
GO

SET IDENTITY_INSERT dbo.Employees ON;
IF NOT EXISTS (SELECT 1 FROM dbo.Employees WHERE employee_id = 1)
    INSERT INTO dbo.Employees (employee_id, last_name, first_name, birth_date, gender) 
    VALUES (1, 'Иванов', 'Иван', '1990-01-01', N'М');
SET IDENTITY_INSERT dbo.Employees OFF;
SET IDENTITY_INSERT dbo.Appointments ON;
IF NOT EXISTS (SELECT 1 FROM dbo.Appointments WHERE appointment_id = 1)
    INSERT INTO dbo.Appointments (appointment_id, employee_id, department_id, position_id, appointment_date, contract_term_days) 
    VALUES (1, 1, 1, 1, '2024-01-01', 90);
SET IDENTITY_INSERT dbo.Appointments OFF;
UPDATE dbo.Employees SET last_name = 'Петров' WHERE employee_id = 2;
GO

PRINT 'Задание 6 (Y_MyBase): Удаление назначений с contract_term_days < 30';
DELETE FROM dbo.Appointments 
WHERE employee_id IN (
    SELECT a.employee_id 
    FROM dbo.Appointments a
    JOIN dbo.Employees e ON a.employee_id = e.employee_id
    JOIN dbo.Departments d ON a.department_id = d.department_id
    WHERE a.contract_term_days < 30
);
GO

PRINT 'Задание 6 (Y_MyBase): Обновление contract_term_days для сотрудника с employee_id = 1';
UPDATE dbo.Appointments 
SET contract_term_days = contract_term_days + 30 
WHERE employee_id = 1;
GO