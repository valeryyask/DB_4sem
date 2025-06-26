--1 
SELECT 
    E.EmployeeID AS 'ID ����������',
    E.LastName + ' ' + E.FirstName + ' ' + ISNULL(E.MiddleName, '') AS '���',
    D.DepartmentName AS '�����',
    P.PositionName AS '���������',
    E.Salary AS '��������'
FROM 
    EMPLOYEE E
INNER JOIN 
    DEPARTMENT D ON E.DepartmentID = D.DepartmentID
INNER JOIN 
    POSITION P ON E.PositionID = P.PositionID;
-- 2
--SELECT 
--    E.EmployeeID AS 'ID ����������',
--    E.LastName + ' ' + E.FirstName AS '���',
--    P.PositionName AS '���������',
--    D.DepartmentName AS '�����'
--FROM 
--    EMPLOYEE E
--INNER JOIN 
--    POSITION P ON E.PositionID = P.PositionID
--INNER JOIN 
--    DEPARTMENT D ON E.DepartmentID = D.DepartmentID
--WHERE 
--    P.PositionName LIKE '%��������%';
-- 3
--SELECT 
--    D.DepartmentName AS '�����',
--    P.PositionName AS '���������',
--    E.LastName + ' ' + E.FirstName AS '���������',
--    E.Salary AS '��������',
--    CASE 
--        WHEN E.Salary BETWEEN 50000 AND 70000 THEN '���������-��������� �����'
--        WHEN E.Salary BETWEEN 70001 AND 90000 THEN '���������-��������� �����'
--        WHEN E.Salary BETWEEN 90001 AND 120000 THEN '���������-��� �������� �����'
--        WHEN E.Salary > 120000 THEN '����� ��� �������� �����'
--        ELSE '����� ���������� �����'
--    END AS '�������� ��������'
--FROM 
--    EMPLOYEE E
--INNER JOIN 
--    POSITION P ON E.PositionID = P.PositionID
--INNER JOIN 
--    DEPARTMENT D ON E.DepartmentID = D.DepartmentID
--WHERE 
--    E.Salary BETWEEN 70000 AND 150000
--ORDER BY 
--    E.Salary DESC;
-- 4
--SELECT 
--    D.DepartmentName AS '�����',
--    ISNULL(E.LastName + ' ' + E.FirstName, '***') AS '���������',
--    ISNULL(P.PositionName, '***') AS '���������'
--FROM 
--    DEPARTMENT D
--LEFT OUTER JOIN 
--    EMPLOYEE E ON D.DepartmentID = E.DepartmentID
--LEFT OUTER JOIN 
--    POSITION P ON E.PositionID = P.PositionID
--ORDER BY 
--    D.DepartmentName, E.LastName;
-- 5
--CREATE TABLE #TempDept (
--    DeptID INT PRIMARY KEY,
--    DeptName NVARCHAR(50)
--);

--CREATE TABLE #TempEmp (
--    EmpID INT PRIMARY KEY,
--    EmpName NVARCHAR(50),
--    DeptID INT
--);
--INSERT INTO #TempDept VALUES (1, 'IT'), (2, 'HR'), (3, 'Finance'), (4, '�����������');
--INSERT INTO #TempEmp VALUES (1, '��������', 1), (2, '���������', 1), (3, '�������', 2), (4, '������', NULL), (5, '���������', 5);

---- ������ ����� ������� ��� ������������ � ������
--SELECT 
--    D.DeptName AS '�����',
--    '��� �����������' AS '���������'
--FROM 
--    #TempDept D
--LEFT OUTER JOIN 
--    #TempEmp E ON D.DeptID = E.DeptID
--WHERE 
--    E.EmpID IS NULL;
---- ������ ������ ������� ��� ������������ � �����
--SELECT 
--    '����������� �����' AS '�����',
--    E.EmpName AS '���������'
--FROM 
--    #TempDept D
--RIGHT OUTER JOIN 
--    #TempEmp E ON D.DeptID = E.DeptID
--WHERE 
--    D.DeptID IS NULL;

---- ��� ������ �� ����� ������
--SELECT 
--    ISNULL(D.DeptName, '����������� �����') AS '�����',
--    ISNULL(E.EmpName, '��� �����������') AS '���������'
--FROM 
--    #TempDept D
--FULL OUTER JOIN 
--    #TempEmp E ON D.DeptID = E.DeptID;
--DROP TABLE #TempDept;
--DROP TABLE #TempEmp;