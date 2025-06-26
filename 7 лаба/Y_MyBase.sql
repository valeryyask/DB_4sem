SELECT 
    d.department_name AS [Отдел],
    p.position_title AS [Должность],
    e.last_name + ' ' + e.first_name AS [Сотрудник],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [Средний срок контракта (дни)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'ИТ'
GROUP BY ROLLUP (d.department_name, p.position_title, e.last_name + ' ' + e.first_name);
SELECT 
    d.department_name AS [Отдел],
    p.position_title AS [Должность],
    e.last_name + ' ' + e.first_name AS [Сотрудник],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [Средний срок контракта (дни)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'ИТ'
GROUP BY CUBE (d.department_name, p.position_title, e.last_name + ' ' + e.first_name);
SELECT 
    p.position_title AS [Должность],
    d.department_name AS [Отдел],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [Средний срок контракта (дни)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'ИТ'
GROUP BY p.position_title, d.department_name

UNION

SELECT 
    p.position_title AS [Должность],
    d.department_name AS [Отдел],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [Средний срок контракта (дни)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'Производство'
GROUP BY p.position_title, d.department_name;

SELECT 
    p.position_title AS [Должность],
    d.department_name AS [Отдел],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [Средний срок контракта (дни)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'ИТ'
GROUP BY p.position_title, d.department_name

UNION ALL

SELECT 
    p.position_title AS [Должность],
    d.department_name AS [Отдел],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [Средний срок контракта (дни)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'Производство'
GROUP BY p.position_title, d.department_name;
SELECT 
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [Средний срок контракта (дни)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'ИТ'
GROUP BY p.position_title

INTERSECT

SELECT 
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [Средний срок контракта (дни)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'Производство'
GROUP BY p.position_title;
SELECT 
    p.position_title AS [Должность],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [Средний срок контракта (дни)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'ИТ'
GROUP BY p.position_title

EXCEPT

SELECT 
    p.position_title AS [Должность],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [Средний срок контракта (дни)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'Производство'
GROUP BY p.position_title;