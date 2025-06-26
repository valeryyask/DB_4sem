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

-- ������� 1: ��������� ������� COUNT_STUDENTS
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

-- ������������ ������� COUNT_STUDENTS
SELECT '��� �������� �� ���������� ����' AS Description, dbo.COUNT_STUDENTS('����', NULL) AS StudentCount
UNION ALL
SELECT '�������� �� ���� �� ������������� 1-46 01 01', dbo.COUNT_STUDENTS('����', '1-46 01 01')
UNION ALL
SELECT '��� �������� (��� �������)', dbo.COUNT_STUDENTS(NULL, NULL);
GO

-- ����������� ������� COUNT_STUDENTS (������������ ALTER)
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

SELECT '�������� �� ���������� ��' AS Description, dbo.COUNT_STUDENTS('��', NULL) AS StudentCount
UNION ALL
SELECT '�������� �� �� �� ������������� 1-89 02 02', dbo.COUNT_STUDENTS('��', '1-89 02 02')
UNION ALL
SELECT '��� �������� �� ������������� 1-46 01 01', dbo.COUNT_STUDENTS(NULL, '1-46 01 01');
GO

-- ������� 2: ��������� ������� FSUBJECTS
CREATE FUNCTION dbo.FSUBJECTS
(
    @p VARCHAR(20)
)
RETURNS VARCHAR(300)
AS
BEGIN
    DECLARE @subjects VARCHAR(300) = N'����������: ';
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
    
    IF LEN(@subjects) > LEN(N'����������: ')
        SET @subjects = LEFT(@subjects, LEN(@subjects) - 1);
    
    RETURN @subjects;
END;
GO

SELECT P.PULPIT, P.PULPIT_NAME, dbo.FSUBJECTS(P.PULPIT) AS Subjects
FROM dbo.PULPIT P
ORDER BY P.PULPIT;
GO

-- ������� 3: ��������� ������� FFACPUL
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

SELECT '��� ������� �� ���� �����������' AS Description, FACULTY, FACULTY_NAME, PULPIT, PULPIT_NAME
FROM dbo.FFACPUL(NULL, NULL)
UNION ALL
SELECT '��� ������� ���������� ����', FACULTY, FACULTY_NAME, PULPIT, PULPIT_NAME
FROM dbo.FFACPUL('����', NULL)
UNION ALL
SELECT '������� ��������', FACULTY, FACULTY_NAME, PULPIT, PULPIT_NAME
FROM dbo.FFACPUL(NULL, '��������')
UNION ALL
SELECT '������� ��� �� ����', FACULTY, FACULTY_NAME, PULPIT, PULPIT_NAME
FROM dbo.FFACPUL('����', '���');
GO

-- ������� 4: ��������� ������� FCTEACHER
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

SELECT '��� �������������' AS Description, '����� ����������' AS PULPIT_NAME, dbo.FCTEACHER(NULL) AS Teachers;
GO


CREATE FUNCTION FACULTY_REPORTING(@c int)
RETURNS @fr TABLE
(
    [���������] varchar(50),
    [���������� ������] int,
    [���������� �����] int,
    [���������� ���������] int,
    [���������� ��������������] int
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
-- �������� ������������ �������, ���� ��� ����
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

-- ������� 1: ��������� ������� COUNT_EMPLOYEES
-- ������������ ���������� ����������� � ������ �, �����������, �� ���������
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

-- ������������ ������� COUNT_EMPLOYEES
SELECT '��� ���������� � ������ 1' AS Description, dbo.COUNT_EMPLOYEES(1, NULL) AS EmployeeCount
UNION ALL
SELECT '���������� � ������ 1 �� ��������� 1', dbo.COUNT_EMPLOYEES(1, 1)
UNION ALL
SELECT '��� ���������� (��� �������)', dbo.COUNT_EMPLOYEES(NULL, NULL);
GO

-- ����������� ������� COUNT_EMPLOYEES (������������ ALTER)
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

-- ��������� ������������ COUNT_EMPLOYEES
SELECT '���������� � ������ 2' AS Description, dbo.COUNT_EMPLOYEES(2, NULL) AS EmployeeCount
UNION ALL
SELECT '���������� � ������ 2 �� ��������� 2', dbo.COUNT_EMPLOYEES(2, 2)
UNION ALL
SELECT '��� ���������� �� ��������� 1', dbo.COUNT_EMPLOYEES(NULL, 1);
GO

-- ������� 2: ��������� ������� FPOSITION_BENEFITS
-- ���������� ������ � �������� ����� ��� �������� ���������
CREATE FUNCTION dbo.FPOSITION_BENEFITS
(
    @position_id INT
)
RETURNS NVARCHAR(300)
AS
BEGIN
    DECLARE @benefits NVARCHAR(300) = N'������: ';
    DECLARE @benefit_text NVARCHAR(MAX);
    
    -- ��������� benefits - ��� ���� ���� NVARCHAR(MAX), ������ ��������� ���
    SELECT @benefit_text = benefits
    FROM dbo.Positions
    WHERE position_id = @position_id;
    
    IF @benefit_text IS NOT NULL
        SET @benefits = @benefits + RTRIM(@benefit_text);
    ELSE
        SET @benefits = @benefits + N'��� ������';
    
    RETURN @benefits;
END;
GO

-- �������� ������ � �������������� FPOSITION_BENEFITS
SELECT P.position_id, P.position_title, dbo.FPOSITION_BENEFITS(P.position_id) AS Benefits
FROM dbo.Positions P
ORDER BY P.position_id;
GO

-- ������� 3: ��������� ������� FDEPT_POS
-- ���������� ������� � �������� � �����������
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

-- ������������ FDEPT_POS
SELECT '��� ��������� �� ���� �������' AS Description, department_id, department_name, position_id, position_title
FROM dbo.FDEPT_POS(NULL, NULL)
WHERE position_id IS NOT NULL
UNION ALL
SELECT '��� ��������� � ������ 1', department_id, department_name, position_id, position_title
FROM dbo.FDEPT_POS(1, NULL)
WHERE position_id IS NOT NULL
UNION ALL
SELECT '��������� 1', department_id, department_name, position_id, position_title
FROM dbo.FDEPT_POS(NULL, 1)
WHERE position_id IS NOT NULL
UNION ALL
SELECT '��������� 1 � ������ 1', department_id, department_name, position_id, position_title
FROM dbo.FDEPT_POS(1, 1)
WHERE position_id IS NOT NULL;
GO

-- ������� 4: ��������� ������� FEMPLOYEE_COUNT
-- ������������ ���������� ����������� �� �������� ���������
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

-- ������������ FEMPLOYEE_COUNT
SELECT P.position_id AS Description, P.position_title, dbo.FEMPLOYEE_COUNT(P.position_id) AS Employees
FROM dbo.Positions P
WHERE dbo.FEMPLOYEE_COUNT(P.position_id) > 0
ORDER BY P.position_id;
GO

-- �������������� �������� ������ ��� ������ ���������� �����������
SELECT '��� ����������' AS Description, '����� ����������' AS position_title, dbo.FEMPLOYEE_COUNT(NULL) AS Employees;
GO