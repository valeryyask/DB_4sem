--1 
SELECT 
    E.EmployeeID AS 'ID сотрудника',
    E.LastName + ' ' + E.FirstName + ' ' + ISNULL(E.MiddleName, '') AS 'ФИО',
    D.DepartmentName AS 'Отдел',
    P.PositionName AS 'Должность',
    E.Salary AS 'Зарплата'
FROM 
    EMPLOYEE E
INNER JOIN 
    DEPARTMENT D ON E.DepartmentID = D.DepartmentID
INNER JOIN 
    POSITION P ON E.PositionID = P.PositionID;
-- 2
--SELECT 
--    E.EmployeeID AS 'ID сотрудника',
--    E.LastName + ' ' + E.FirstName AS 'ФИО',
--    P.PositionName AS 'Должность',
--    D.DepartmentName AS 'Отдел'
--FROM 
--    EMPLOYEE E
--INNER JOIN 
--    POSITION P ON E.PositionID = P.PositionID
--INNER JOIN 
--    DEPARTMENT D ON E.DepartmentID = D.DepartmentID
--WHERE 
--    P.PositionName LIKE '%менеджер%';
-- 3
--SELECT 
--    D.DepartmentName AS 'Отдел',
--    P.PositionName AS 'Должность',
--    E.LastName + ' ' + E.FirstName AS 'Сотрудник',
--    E.Salary AS 'Зарплата',
--    CASE 
--        WHEN E.Salary BETWEEN 50000 AND 70000 THEN 'пятьдесят-семьдесят тысяч'
--        WHEN E.Salary BETWEEN 70001 AND 90000 THEN 'семьдесят-девяносто тысяч'
--        WHEN E.Salary BETWEEN 90001 AND 120000 THEN 'девяносто-сто двадцать тысяч'
--        WHEN E.Salary > 120000 THEN 'более ста двадцати тысяч'
--        ELSE 'менее пятидесяти тысяч'
--    END AS 'Диапазон зарплаты'
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
--    D.DepartmentName AS 'Отдел',
--    ISNULL(E.LastName + ' ' + E.FirstName, '***') AS 'Сотрудник',
--    ISNULL(P.PositionName, '***') AS 'Должность'
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
--INSERT INTO #TempDept VALUES (1, 'IT'), (2, 'HR'), (3, 'Finance'), (4, 'Бухгалтерия');
--INSERT INTO #TempEmp VALUES (1, 'Милочкин', 1), (2, 'Леваньков', 1), (3, 'Волосюк', 2), (4, 'Гуркин', NULL), (5, 'Аврусевич', 5);

---- Данные левой таблицы без соответствия в правой
--SELECT 
--    D.DeptName AS 'Отдел',
--    'Нет сотрудников' AS 'Сотрудник'
--FROM 
--    #TempDept D
--LEFT OUTER JOIN 
--    #TempEmp E ON D.DeptID = E.DeptID
--WHERE 
--    E.EmpID IS NULL;
---- Данные правой таблицы без соответствия в левой
--SELECT 
--    'Неизвестный отдел' AS 'Отдел',
--    E.EmpName AS 'Сотрудник'
--FROM 
--    #TempDept D
--RIGHT OUTER JOIN 
--    #TempEmp E ON D.DeptID = E.DeptID
--WHERE 
--    D.DeptID IS NULL;

---- Все данные из обеих таблиц
--SELECT 
--    ISNULL(D.DeptName, 'Неизвестный отдел') AS 'Отдел',
--    ISNULL(E.EmpName, 'Нет сотрудников') AS 'Сотрудник'
--FROM 
--    #TempDept D
--FULL OUTER JOIN 
--    #TempEmp E ON D.DeptID = E.DeptID;
--DROP TABLE #TempDept;
--DROP TABLE #TempEmp;