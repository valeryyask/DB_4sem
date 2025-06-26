USE UNIVER;
GO

-- ������� 1: �������� ����� ��������� � ������������ ����� ��������� (INNER JOIN)
SELECT 
    a.AUDITORIUM AS AuditoriumCode,
    at.AUDITORIUM_TYPENAME AS AuditoriumTypeName
FROM dbo.AUDITORIUM a
INNER JOIN dbo.AUDITORIUM_TYPE at ON a.AUDITORIUM_TYPE = at.AUDITORIUM_TYPE;
GO

-- ������� 2: �������� ����� ��������� � ����� � ���������� '���������' (INNER JOIN, LIKE)
SELECT 
    a.AUDITORIUM AS AuditoriumCode,
    at.AUDITORIUM_TYPENAME AS AuditoriumTypeName
FROM dbo.AUDITORIUM a
INNER JOIN dbo.AUDITORIUM_TYPE at ON a.AUDITORIUM_TYPE = at.AUDITORIUM_TYPE
WHERE at.AUDITORIUM_TYPENAME LIKE N'%���������%';
GO

-- ������� 3: �������� ��������� � �������� 6�8 (INNER JOIN, BETWEEN, CASE)
SELECT 
    f.FACULTY_NAME AS Faculty,
    p.PULPIT_NAME AS Pulpit,
    pr.PROFESSION_NAME AS Profession,
    s.SUBJECT_NAME AS Subject,
    st.[NAME] AS StudentName,
    CASE prg.NOTE
        WHEN 6 THEN N'�����'
        WHEN 7 THEN N'����'
        WHEN 8 THEN N'������'
    END AS Rating
FROM dbo.PROGRESS prg
INNER JOIN dbo.STUDENT st ON prg.IDSTUDENT = st.IDSTUDENT
INNER JOIN dbo.[GROUP] g ON st.IDGROUP = g.IDGROUP
INNER JOIN dbo.SUBJECT s ON prg.SUBJECT = s.SUBJECT
INNER JOIN dbo.PULPIT p ON s.PULPIT = p.PULPIT
INNER JOIN dbo.FACULTY f ON p.FACULTY = f.FACULTY
INNER JOIN dbo.PROFESSION pr ON g.PROFESSION = pr.PROFESSION
WHERE prg.NOTE BETWEEN 6 AND 8
ORDER BY prg.NOTE DESC;
GO

-- ������� 4: �������� ������ � �������������� (LEFT OUTER JOIN, ISNULL)
SELECT 
    p.PULPIT_NAME AS Pulpit,
    ISNULL(t.TEACHER_NAME, N'***') AS Teacher
FROM dbo.PULPIT p
LEFT OUTER JOIN dbo.TEACHER t ON p.PULPIT = t.PULPIT;
GO

-- ������� 5: ������������ ��������������� FULL OUTER JOIN
-- �������� ��������� ������
CREATE TABLE dbo.TestTable1 (
    ID INT PRIMARY KEY,
    Name NVARCHAR(50)
);
CREATE TABLE dbo.TestTable2 (
    ID INT PRIMARY KEY,
    Description NVARCHAR(50)
);
GO

-- ���������� ������
INSERT INTO dbo.TestTable1 (ID, Name) VALUES
    (1, N'������� 1'),
    (2, N'������� 2'),
    (3, N'������� 3');
INSERT INTO dbo.TestTable2 (ID, Description) VALUES
    (2, N'�������� 2'),
    (3, N'�������� 3'),
    (4, N'�������� 4');
GO

-- 5.1: ������ ������ �� ����� ������� (TestTable1, ��� TestTable2)
SELECT 
    t1.ID,
    t1.Name,
    t2.Description
FROM dbo.TestTable1 t1
FULL OUTER JOIN dbo.TestTable2 t2 ON t1.ID = t2.ID
WHERE t2.ID IS NULL;
GO

-- 5.2: ������ ������ �� ������ ������� (TestTable2, ��� TestTable1)
SELECT 
    t1.ID,
    t1.Name,
    t2.Description
FROM dbo.TestTable1 t1
FULL OUTER JOIN dbo.TestTable2 t2 ON t1.ID = t2.ID
WHERE t1.ID IS NULL;
GO

-- 5.3: ������ �� ����� ������ (����� �����������)
SELECT 
    t1.ID,
    t1.Name,
    t2.Description
FROM dbo.TestTable1 t1
FULL OUTER JOIN dbo.TestTable2 t2 ON t1.ID = t2.ID
WHERE t1.ID IS NOT NULL AND t2.ID IS NOT NULL;
GO

-- �������� ��������� ������
DROP TABLE dbo.TestTable1;
DROP TABLE dbo.TestTable2;
GO

-- ������� 6: �������� ����� ��������� � ����� � ������� CROSS JOIN
SELECT 
    a.AUDITORIUM AS AuditoriumCode,
    at.AUDITORIUM_TYPENAME AS AuditoriumTypeName
FROM dbo.AUDITORIUM_TYPE at
CROSS JOIN dbo.AUDITORIUM a
WHERE a.AUDITORIUM_TYPE = at.AUDITORIUM_TYPE;
GO

-- ������� 8: �������� ������� TIMETABLE � �������
-- 8.1: ��������� ��������� �� ����������� ���� (��������, �����������, 1 ����)
SELECT 
    a.AUDITORIUM,
    a.AUDITORIUM_NAME
FROM dbo.AUDITORIUM a
WHERE a.AUDITORIUM NOT IN (
    SELECT AUDITORIUM 
    FROM dbo.TIMETABLE 
    WHERE WEEKDAY = 1 AND LESSON_NUMBER = 1
);
GO

-- 8.2: ��������� ��������� �� ����������� ���� ������ (��������, �����������)
SELECT 
    a.AUDITORIUM,
    a.AUDITORIUM_NAME
FROM dbo.AUDITORIUM a
WHERE a.AUDITORIUM NOT IN (
    SELECT AUDITORIUM 
    FROM dbo.TIMETABLE 
    WHERE WEEKDAY = 1
);
GO

-- 8.3: ����� � �������������� (��������, �� �����������)
SELECT 
    t.TEACHER,
    t.TEACHER_NAME,
    w.WEEKDAY,
    ln.LESSON_NUMBER
FROM dbo.TEACHER t
CROSS APPLY (SELECT 1 AS WEEKDAY) w
CROSS APPLY (SELECT 1 AS LESSON_NUMBER UNION SELECT 2) ln
WHERE NOT EXISTS (
    SELECT 1 
    FROM dbo.TIMETABLE tt 
    WHERE tt.TEACHER = t.TEACHER 
    AND tt.WEEKDAY = w.WEEKDAY 
    AND tt.LESSON_NUMBER = ln.LESSON_NUMBER
);
GO

-- 8.4: ����� � ����� (��������, �� �����������)
SELECT 
    g.IDGROUP,
    g.FACULTY,
    w.WEEKDAY,
    ln.LESSON_NUMBER
FROM dbo.[GROUP] g
CROSS APPLY (SELECT 1 AS WEEKDAY) w
CROSS APPLY (SELECT 1 AS LESSON_NUMBER UNION SELECT 2) ln
WHERE NOT EXISTS (
    SELECT 1 
    FROM dbo.TIMETABLE tt 
    WHERE tt.IDGROUP = g.IDGROUP 
    AND tt.WEEKDAY = w.WEEKDAY 
    AND tt.LESSON_NUMBER = ln.LESSON_NUMBER
);
GO