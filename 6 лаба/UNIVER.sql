-- ������ ��� ���������� ���������� �� ����� ���������
SELECT 
    at.AUDITORIUM_TYPENAME AS [��� ���������],
    MAX(a.AUDITORIUM_CAPACITY) AS [������������ �����������],
    MIN(a.AUDITORIUM_CAPACITY) AS [����������� �����������],
    AVG(a.AUDITORIUM_CAPACITY) AS [������� �����������],
    SUM(a.AUDITORIUM_CAPACITY) AS [��������� �����������],
    COUNT(*) AS [���������� ���������]
FROM dbo.AUDITORIUM a
INNER JOIN dbo.AUDITORIUM_TYPE at
    ON a.AUDITORIUM_TYPE = at.AUDITORIUM_TYPE
GROUP BY at.AUDITORIUM_TYPENAME;
-- ������ ��� �������� ������ � ���������� � �������������� CASE
SELECT 
    note_range AS [������],
    COUNT(*) AS [����������]
FROM (
    SELECT 
        CASE 
            WHEN NOTE BETWEEN 8 AND 10 THEN '8-10'
            WHEN NOTE BETWEEN 6 AND 7 THEN '6-7'
            WHEN NOTE BETWEEN 4 AND 5 THEN '4-5'
            ELSE '1-3'
        END AS note_range
    FROM dbo.PROGRESS
) sub
GROUP BY note_range
ORDER BY note_range DESC;
-- ������ ��� ���������� ������� ������ �� �����������, �������������� � ������
SELECT 
    f.FACULTY_NAME AS [���������],
    p.PROFESSION_NAME AS [�������������],
    g.COURSE AS [����],
    ROUND(AVG(CAST(pr.NOTE AS FLOAT)), 2) AS [������� ������]
FROM dbo.FACULTY f
INNER JOIN dbo.[GROUP] g ON f.FACULTY = g.FACULTY
INNER JOIN dbo.PROFESSION p ON g.PROFESSION = p.PROFESSION
INNER JOIN dbo.STUDENT s ON g.IDGROUP = s.IDGROUP
INNER JOIN dbo.PROGRESS pr ON s.IDSTUDENT = pr.IDSTUDENT
GROUP BY f.FACULTY_NAME, p.PROFESSION_NAME, g.COURSE
ORDER BY [������� ������] DESC;
-- ������ ��� ������� ������ �� ����������� �� � ����
SELECT 
    f.FACULTY_NAME AS [���������],
    p.PROFESSION_NAME AS [�������������],
    g.COURSE AS [����],
    ROUND(AVG(CAST(pr.NOTE AS FLOAT)), 2) AS [������� ������]
FROM dbo.FACULTY f
INNER JOIN dbo.[GROUP] g ON f.FACULTY = g.FACULTY
INNER JOIN dbo.PROFESSION p ON g.PROFESSION = p.PROFESSION
INNER JOIN dbo.STUDENT s ON g.IDGROUP = s.IDGROUP
INNER JOIN dbo.PROGRESS pr ON s.IDSTUDENT = pr.IDSTUDENT
INNER JOIN dbo.SUBJECT sub ON pr.SUBJECT = sub.SUBJECT
WHERE sub.SUBJECT_NAME IN (N'������� ���������� ������ ������', N'������ �������������� � ����������������')
GROUP BY f.FACULTY_NAME, p.PROFESSION_NAME, g.COURSE
ORDER BY [������� ������] DESC;
-- ������ ��� ������� ������ �� ����������� �� ���������� ���
SELECT 
    p.PROFESSION_NAME AS [�������������],
    sub.SUBJECT_NAME AS [����������],
    ROUND(AVG(CAST(pr.NOTE AS FLOAT)), 2) AS [������� ������]
FROM dbo.FACULTY f
INNER JOIN dbo.[GROUP] g ON f.FACULTY = g.FACULTY
INNER JOIN dbo.PROFESSION p ON g.PROFESSION = p.PROFESSION
INNER JOIN dbo.STUDENT s ON g.IDGROUP = s.IDGROUP
INNER JOIN dbo.PROGRESS pr ON s.IDSTUDENT = pr.IDSTUDENT
INNER JOIN dbo.SUBJECT sub ON pr.SUBJECT = sub.SUBJECT
WHERE f.FACULTY = '���'
GROUP BY p.PROFESSION_NAME, sub.SUBJECT_NAME
ORDER BY [������� ������] DESC;
-- ������ ��� �������� ��������� � �������� 8 � 9 �� �����������
SELECT 
    sub.SUBJECT_NAME AS [����������],
    COUNT(*) AS [���������� ���������]
FROM dbo.PROGRESS pr
INNER JOIN dbo.SUBJECT sub ON pr.SUBJECT = sub.SUBJECT
WHERE pr.NOTE IN (8, 9)
GROUP BY sub.SUBJECT_NAME
HAVING COUNT(*) > 0
ORDER BY [���������� ���������] DESC;