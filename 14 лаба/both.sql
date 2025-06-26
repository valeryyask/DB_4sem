USE UNIVER;
IF OBJECT_ID('dbo.COUNT_STUDENTS') IS NOT NULL
    DROP FUNCTION dbo.COUNT_STUDENTS;
GO
IF OBJECT_ID('dbo.FSUBJECTS') IS NOT NULL
    DROP FUNCTION dbo.FSUBJECTS;
GO
IF OBJECT_ID('dbo.FFACPUL') IS NOT NULL
    DROP FUNCTION dbo.FFACPUL;
GO
IF OBJECT_ID('dbo.FCTEACHER') IS NOT NULL
    DROP FUNCTION dbo.FCTEACHER;
GO

-- Задание 1: Скалярная функция COUNT_STUDENTS
CREATE FUNCTION dbo.COUNT_STUDENTS
(
    @faculty VARCHAR(20) = NULL,
    @prof VARCHAR(20) = NULL
)
RETURNS INT
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(DISTINCT S.IDSTUDENT)
    FROM dbo.FACULTY F
    INNER JOIN dbo.[GROUP] G ON F.FACULTY = G.FACULTY
    INNER JOIN dbo.STUDENT S ON G.IDGROUP = S.IDGROUP
    WHERE (@faculty IS NULL OR F.FACULTY = @faculty)
      AND (@prof IS NULL OR G.PROFESSION = @prof);
    RETURN @count;
END;
GO

-- Тестирование функции COUNT_STUDENTS
SELECT 'Все студенты на факультете ТТЛП' AS Description, dbo.COUNT_STUDENTS('ТТЛП', NULL) AS StudentCount
UNION ALL
SELECT 'Студенты на ТТЛП по специальности 1-46 01 01', dbo.COUNT_STUDENTS('ТТЛП', '1-46 01 01')
UNION ALL
SELECT 'Все студенты (без фильтра)', dbo.COUNT_STUDENTS(NULL, NULL);
GO

-- Модификация функции COUNT_STUDENTS (демонстрация ALTER)
ALTER FUNCTION dbo.COUNT_STUDENTS
(
    @faculty VARCHAR(20) = NULL,
    @prof VARCHAR(20) = NULL
)
RETURNS INT
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(DISTINCT S.IDSTUDENT)
    FROM dbo.FACULTY F
    INNER JOIN dbo.[GROUP] G ON F.FACULTY = G.FACULTY
    INNER JOIN dbo.STUDENT S ON G.IDGROUP = S.IDGROUP
    WHERE (@faculty IS NULL OR F.FACULTY = @faculty)
      AND (@prof IS NULL OR G.PROFESSION = @prof);
    RETURN @count;
END;
GO

SELECT 'Студенты на факультете ЛХ' AS Description, dbo.COUNT_STUDENTS('ЛХ', NULL) AS StudentCount
UNION ALL
SELECT 'Студенты на ЛХ по специальности 1-89 02 02', dbo.COUNT_STUDENTS('ЛХ', '1-89 02 02')
UNION ALL
SELECT 'Все студенты по специальности 1-46 01 01', dbo.COUNT_STUDENTS(NULL, '1-46 01 01');
GO

-- Задание 2: Скалярная функция FSUBJECTS
CREATE FUNCTION dbo.FSUBJECTS
(
    @p VARCHAR(20)
)
RETURNS VARCHAR(300)
AS
BEGIN
    DECLARE @subjects VARCHAR(300) = N'Дисциплины: ';
    DECLARE @subject_name NVARCHAR(100);
    DECLARE subject_cursor CURSOR LOCAL STATIC FOR
        SELECT SUBJECT_NAME
        FROM dbo.SUBJECT
        WHERE PULPIT = @p;
    
    OPEN subject_cursor;
    FETCH NEXT FROM subject_cursor INTO @subject_name;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @subjects = @subjects + RTRIM(@subject_name) + ', ';
        FETCH NEXT FROM subject_cursor INTO @subject_name;
    END;
    
    CLOSE subject_cursor;
    DEALLOCATE subject_cursor;
    
    IF LEN(@subjects) > LEN(N'Дисциплины: ')
        SET @subjects = LEFT(@subjects, LEN(@subjects) - 1);
    
    RETURN @subjects;
END;
GO

SELECT P.PULPIT, P.PULPIT_NAME, dbo.FSUBJECTS(P.PULPIT) AS Subjects
FROM dbo.PULPIT P
ORDER BY P.PULPIT;
GO

-- Задание 3: Табличная функция FFACPUL
CREATE FUNCTION dbo.FFACPUL
(
    @faculty VARCHAR(20) = NULL,
    @pulpit VARCHAR(20) = NULL
)
RETURNS TABLE
AS
RETURN
(
    SELECT F.FACULTY, F.FACULTY_NAME, P.PULPIT, P.PULPIT_NAME
    FROM dbo.FACULTY F
    LEFT OUTER JOIN dbo.PULPIT P ON F.FACULTY = P.FACULTY
    WHERE (@faculty IS NULL OR F.FACULTY = @faculty)
      AND (@pulpit IS NULL OR P.PULPIT = @pulpit)
);
GO

SELECT 'Все кафедры на всех факультетах' AS Description, FACULTY, FACULTY_NAME, PULPIT, PULPIT_NAME
FROM dbo.FFACPUL(NULL, NULL)
UNION ALL
SELECT 'Все кафедры факультета ТТЛП', FACULTY, FACULTY_NAME, PULPIT, PULPIT_NAME
FROM dbo.FFACPUL('ТТЛП', NULL)
UNION ALL
SELECT 'Кафедра ТНХСиППМ', FACULTY, FACULTY_NAME, PULPIT, PULPIT_NAME
FROM dbo.FFACPUL(NULL, 'ТНХСиППМ')
UNION ALL
SELECT 'Кафедра ТДП на ТТЛП', FACULTY, FACULTY_NAME, PULPIT, PULPIT_NAME
FROM dbo.FFACPUL('ТТЛП', 'ТДП');
GO

-- Задание 4: Скалярная функция FCTEACHER
CREATE FUNCTION dbo.FCTEACHER
(
    @pulpit VARCHAR(20) = NULL
)
RETURNS INT
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(*)
    FROM dbo.TEACHER
    WHERE (@pulpit IS NULL OR PULPIT = @pulpit);
    RETURN @count;
END;
GO

SELECT P.PULPIT AS Description, P.PULPIT_NAME, dbo.FCTEACHER(P.PULPIT) AS Teachers
FROM dbo.PULPIT P
WHERE dbo.FCTEACHER(P.PULPIT) > 0
ORDER BY P.PULPIT;
GO

SELECT 'Все преподаватели' AS Description, 'Общее количество' AS PULPIT_NAME, dbo.FCTEACHER(NULL) AS Teachers;
GO


CREATE FUNCTION FACULTY_REPORTING(@c int)
RETURNS @fr TABLE
(
    [Факультет] varchar(50),
    [Количество кафедр] int,
    [Количество групп] int,
    [Количество студентов] int,
    [Количество специальностей] int
)
AS
BEGIN
    DECLARE cc CURSOR STATIC FOR
        SELECT FACULTY FROM FACULTY
        WHERE dbo.COUNT_STUDENTS(FACULTY, DEFAULT) > @c;
    
    DECLARE @f varchar(30);
    
    OPEN cc;
    FETCH cc INTO @f;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT @fr
        VALUES (
            @f,
            dbo.COUNT_DEPARTMENTS(@f),
            dbo.COUNT_GROUPS(@f),
            dbo.COUNT_STUDENTS(@f, DEFAULT),
            dbo.COUNT_PROFESSIONS(@f)
        );
        FETCH cc INTO @f;
    END;
    
    CLOSE cc;
    DEALLOCATE cc;
    
    RETURN;
END;

SELECT * FROM dbo.FACULTY_REPORTING(0);


USE Y_MyBase;
-- Удаление существующих функций, если они есть
IF OBJECT_ID('dbo.COUNT_EMPLOYEES') IS NOT NULL
    DROP FUNCTION dbo.COUNT_EMPLOYEES;
GO
IF OBJECT_ID('dbo.FPOSITION_BENEFITS') IS NOT NULL
    DROP FUNCTION dbo.FPOSITION_BENEFITS;
GO
IF OBJECT_ID('dbo.FDEPT_POS') IS NOT NULL
    DROP FUNCTION dbo.FDEPT_POS;
GO
IF OBJECT_ID('dbo.FEMPLOYEE_COUNT') IS NOT NULL
    DROP FUNCTION dbo.FEMPLOYEE_COUNT;
GO

-- Задание 1: Скалярная функция COUNT_EMPLOYEES
-- Подсчитывает количество сотрудников в отделе и, опционально, по должности
CREATE FUNCTION dbo.COUNT_EMPLOYEES
(
    @department_id INT = NULL,
    @position_id INT = NULL
)
RETURNS INT
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(DISTINCT A.employee_id)
    FROM dbo.Departments D
    INNER JOIN dbo.Appointments A ON D.department_id = A.department_id
    INNER JOIN dbo.Employees E ON A.employee_id = E.employee_id
    WHERE (@department_id IS NULL OR D.department_id = @department_id)
      AND (@position_id IS NULL OR A.position_id = @position_id);
    RETURN @count;
END;
GO

-- Тестирование функции COUNT_EMPLOYEES
SELECT 'Все сотрудники в отделе 1' AS Description, dbo.COUNT_EMPLOYEES(1, NULL) AS EmployeeCount
UNION ALL
SELECT 'Сотрудники в отделе 1 на должности 1', dbo.COUNT_EMPLOYEES(1, 1)
UNION ALL
SELECT 'Все сотрудники (без фильтра)', dbo.COUNT_EMPLOYEES(NULL, NULL);
GO

-- Модификация функции COUNT_EMPLOYEES (демонстрация ALTER)
ALTER FUNCTION dbo.COUNT_EMPLOYEES
(
    @department_id INT = NULL,
    @position_id INT = NULL
)
RETURNS INT
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(DISTINCT A.employee_id)
    FROM dbo.Departments D
    INNER JOIN dbo.Appointments A ON D.department_id = A.department_id
    INNER JOIN dbo.Employees E ON A.employee_id = E.employee_id
    WHERE (@department_id IS NULL OR D.department_id = @department_id)
      AND (@position_id IS NULL OR A.position_id = @position_id);
    RETURN @count;
END;
GO

-- Повторное тестирование COUNT_EMPLOYEES
SELECT 'Сотрудники в отделе 2' AS Description, dbo.COUNT_EMPLOYEES(2, NULL) AS EmployeeCount
UNION ALL
SELECT 'Сотрудники в отделе 2 на должности 2', dbo.COUNT_EMPLOYEES(2, 2)
UNION ALL
SELECT 'Все сотрудники на должности 1', dbo.COUNT_EMPLOYEES(NULL, 1);
GO

-- Задание 2: Скалярная функция FPOSITION_BENEFITS
-- Возвращает строку с перечнем льгот для заданной должности
CREATE FUNCTION dbo.FPOSITION_BENEFITS
(
    @position_id INT
)
RETURNS NVARCHAR(300)
AS
BEGIN
    DECLARE @benefits NVARCHAR(300) = N'Льготы: ';
    DECLARE @benefit_text NVARCHAR(MAX);
    
    -- Поскольку benefits - это одно поле NVARCHAR(MAX), просто извлекаем его
    SELECT @benefit_text = benefits
    FROM dbo.Positions
    WHERE position_id = @position_id;
    
    IF @benefit_text IS NOT NULL
        SET @benefits = @benefits + RTRIM(@benefit_text);
    ELSE
        SET @benefits = @benefits + N'Нет данных';
    
    RETURN @benefits;
END;
GO

-- Создание отчета с использованием FPOSITION_BENEFITS
SELECT P.position_id, P.position_title, dbo.FPOSITION_BENEFITS(P.position_id) AS Benefits
FROM dbo.Positions P
ORDER BY P.position_id;
GO

-- Задание 3: Табличная функция FDEPT_POS
-- Возвращает таблицу с отделами и должностями
CREATE FUNCTION dbo.FDEPT_POS
(
    @department_id INT = NULL,
    @position_id INT = NULL
)
RETURNS TABLE
AS
RETURN
(
    SELECT D.department_id, D.department_name, P.position_id, P.position_title
    FROM dbo.Departments D
    LEFT OUTER JOIN dbo.Appointments A ON D.department_id = A.department_id
    LEFT OUTER JOIN dbo.Positions P ON A.position_id = P.position_id
    WHERE (@department_id IS NULL OR D.department_id = @department_id)
      AND (@position_id IS NULL OR P.position_id = @position_id)
);
GO

-- Тестирование FDEPT_POS
SELECT 'Все должности во всех отделах' AS Description, department_id, department_name, position_id, position_title
FROM dbo.FDEPT_POS(NULL, NULL)
WHERE position_id IS NOT NULL
UNION ALL
SELECT 'Все должности в отделе 1', department_id, department_name, position_id, position_title
FROM dbo.FDEPT_POS(1, NULL)
WHERE position_id IS NOT NULL
UNION ALL
SELECT 'Должность 1', department_id, department_name, position_id, position_title
FROM dbo.FDEPT_POS(NULL, 1)
WHERE position_id IS NOT NULL
UNION ALL
SELECT 'Должность 1 в отделе 1', department_id, department_name, position_id, position_title
FROM dbo.FDEPT_POS(1, 1)
WHERE position_id IS NOT NULL;
GO

-- Задание 4: Скалярная функция FEMPLOYEE_COUNT
-- Подсчитывает количество сотрудников на заданной должности
CREATE FUNCTION dbo.FEMPLOYEE_COUNT
(
    @position_id INT = NULL
)
RETURNS INT
AS
BEGIN
    DECLARE @count INT;
    SELECT @count = COUNT(DISTINCT A.employee_id)
    FROM dbo.Appointments A
    WHERE (@position_id IS NULL OR A.position_id = @position_id);
    RETURN @count;
END;
GO

-- Тестирование FEMPLOYEE_COUNT
SELECT P.position_id AS Description, P.position_title, dbo.FEMPLOYEE_COUNT(P.position_id) AS Employees
FROM dbo.Positions P
WHERE dbo.FEMPLOYEE_COUNT(P.position_id) > 0
ORDER BY P.position_id;
GO

-- Дополнительный тестовый запрос для общего количества сотрудников
SELECT 'Все сотрудники' AS Description, 'Общее количество' AS position_title, dbo.FEMPLOYEE_COUNT(NULL) AS Employees;
GO