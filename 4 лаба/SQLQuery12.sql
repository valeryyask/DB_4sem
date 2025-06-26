--1 �������
USE Y_MyBase;
GO

SELECT 
    a.appointment_id,
    d.department_name
FROM dbo.Appointments a
INNER JOIN dbo.Departments d ON a.department_id = d.department_id;
GO
--2 �������
USE Y_MyBase;
GO

SELECT 
    a.appointment_id,
    d.department_name
FROM dbo.Appointments a
INNER JOIN dbo.Departments d ON a.department_id = d.department_id
WHERE d.department_name LIKE N'%IT%';
GO
--3 �������
SELECT 
    d.department_name AS Department,
    p.position_title AS Position,
    e.first_name + N' ' + COALESCE(e.middle_name + N' ', N'') + e.last_name AS EmployeeName,
    CASE a.appointment_id
        WHEN 1 THEN N'�����'
        WHEN 2 THEN N'����'
        WHEN 3 THEN N'������'
        WHEN 4 THEN N'�����'
        WHEN 5 THEN N'����'
    END AS Rating
FROM dbo.Appointments a
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
INNER JOIN dbo.Departments d ON a.department_id = d.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
WHERE 
    CASE a.appointment_id
        WHEN 1 THEN 6
        WHEN 2 THEN 7
        WHEN 3 THEN 8
        WHEN 4 THEN 6
        WHEN 5 THEN 7
    END BETWEEN 6 AND 8
ORDER BY 
    CASE a.appointment_id
        WHEN 1 THEN 6
        WHEN 2 THEN 7
        WHEN 3 THEN 8
        WHEN 4 THEN 6
        WHEN 5 THEN 7
    END DESC;
--4 �������
SELECT 
    d.department_name AS Department,
    ISNULL(e.first_name + N' ' + COALESCE(e.middle_name + N' ', N'') + e.last_name, N'***') AS Employee
FROM dbo.Departments d
LEFT OUTER JOIN dbo.Appointments a ON d.department_id = a.department_id
LEFT OUTER JOIN dbo.Employees e ON a.employee_id = e.employee_id;
--5 �������
--CREATE TABLE dbo.TableA (
--    id INT PRIMARY KEY,
--    name NVARCHAR(50)
--);

--CREATE TABLE dbo.TableB (
--    id INT PRIMARY KEY,
--    name NVARCHAR(50)
--);

--INSERT INTO dbo.TableA (id, name) VALUES
--    (1, N'������� A1'),
--    (2, N'������� A2'),
--    (3, N'������� A3');

--INSERT INTO dbo.TableB (id, name) VALUES
--    (2, N'������� B2'),
--    (3, N'������� B3'),
--    (4, N'������� B4');
--GO

---- ������������ ��������������� FULL OUTER JOIN
---- ������ 1: TableA FULL OUTER JOIN TableB
--SELECT 
--    a.id AS a_id, a.name AS a_name,
--    b.id AS b_id, b.name AS b_name
--FROM dbo.TableA a
--FULL OUTER JOIN dbo.TableB b ON a.id = b.id;

---- ������ 2: TableB FULL OUTER JOIN TableA
--SELECT 
--    b.id AS b_id, b.name AS b_name,
--    a.id AS a_id, a.name AS a_name
--FROM dbo.TableB b
--FULL OUTER JOIN dbo.TableA a ON b.id = a.id;
--GO

---- ������ 3: ������ ������ �� TableA (����� �����)
--SELECT 
--    a.id, a.name
--FROM dbo.TableA a
--FULL OUTER JOIN dbo.TableB b ON a.id = b.id
--WHERE b.id IS NULL;
--GO

---- ������ 4: ������ ������ �� TableB (������ �����)
--SELECT 
--    b.id, b.name
--FROM dbo.TableA a
--FULL OUTER JOIN dbo.TableB b ON a.id = b.id
--WHERE a.id IS NULL;
--GO

---- ������ 5: ����� ������ (�����������)
--SELECT 
--    a.id, a.name
--FROM dbo.TableA a
--FULL OUTER JOIN dbo.TableB b ON a.id = b.id
--WHERE a.id IS NOT NULL AND b.id IS NOT NULL;
--GO

---- �������� ������
--DROP TABLE dbo.TableA;
--DROP TABLE dbo.TableB;
--6 �������
SELECT 
    a.appointment_id,
    d.department_name
FROM dbo.Appointments a
CROSS JOIN dbo.Departments d
WHERE a.department_id = d.department_id;