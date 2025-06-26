USE Y_MyBASE;
GO

SELECT 
    d.department_name AS DepartmentName
FROM dbo.Departments d
WHERE d.department_id IN (
    SELECT a.department_id
    FROM dbo.Appointments a
    INNER JOIN dbo.Positions p ON a.position_id = p.position_id
    WHERE p.position_title LIKE N'%технологи[я|и]%'
);
GO

SELECT DISTINCT 
    d.department_name AS DepartmentName
FROM dbo.Departments d
INNER JOIN (
    SELECT a.department_id
    FROM dbo.Appointments a
    INNER JOIN dbo.Positions p ON a.position_id = p.position_id
    WHERE p.position_title LIKE N'%технологи[я|и]%'
) a ON d.department_id = a.department_id;
GO

SELECT DISTINCT 
    d.department_name AS DepartmentName
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
WHERE p.position_title LIKE N'%технологи[я|и]%';
GO

SELECT 
    a.appointment_id,
    d.department_name,
    a.contract_term_days
FROM dbo.Appointments a
INNER JOIN dbo.Departments d ON a.department_id = d.department_id
WHERE a.contract_term_days = (
    SELECT TOP 1 a2.contract_term_days
    FROM dbo.Appointments a2
    WHERE a2.department_id = a.department_id
    ORDER BY a2.contract_term_days DESC
)
ORDER BY a.contract_term_days DESC;
GO

SELECT 
    d.department_name
FROM dbo.Departments d
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Appointments a
    WHERE a.department_id = d.department_id
);
GO

SELECT 
    (SELECT AVG(CAST(a.contract_term_days AS FLOAT)) FROM dbo.Appointments a WHERE a.position_id = 1) AS AvgContractTerm_Position1,
    (SELECT AVG(CAST(a.contract_term_days AS FLOAT)) FROM dbo.Appointments a WHERE a.position_id = 2) AS AvgContractTerm_Position2
FROM (SELECT 1 AS Dummy) AS d; 
GO

SELECT 
    e.employee_id,
    e.last_name + N' ' + e.first_name AS EmployeeName
FROM dbo.Employees e
INNER JOIN dbo.Appointments a ON e.employee_id = a.employee_id
GROUP BY e.employee_id, e.last_name, e.first_name
HAVING MIN(a.contract_term_days) >= ALL (
    SELECT MIN(a2.contract_term_days)
    FROM dbo.Appointments a2
    WHERE a2.position_id = 2
);
GO

SELECT DISTINCT 
    e.employee_id,
    e.last_name + N' ' + e.first_name AS EmployeeName
FROM dbo.Employees e
INNER JOIN dbo.Appointments a ON e.employee_id = a.employee_id
WHERE a.contract_term_days > ANY (
    SELECT a2.contract_term_days
    FROM dbo.Appointments a2
    WHERE a2.position_id = 1
);
GO