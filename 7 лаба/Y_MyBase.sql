SELECT 
    d.department_name AS [�����],
    p.position_title AS [���������],
    e.last_name + ' ' + e.first_name AS [���������],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [������� ���� ��������� (���)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'��'
GROUP BY ROLLUP (d.department_name, p.position_title, e.last_name + ' ' + e.first_name);
SELECT 
    d.department_name AS [�����],
    p.position_title AS [���������],
    e.last_name + ' ' + e.first_name AS [���������],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [������� ���� ��������� (���)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'��'
GROUP BY CUBE (d.department_name, p.position_title, e.last_name + ' ' + e.first_name);
SELECT 
    p.position_title AS [���������],
    d.department_name AS [�����],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [������� ���� ��������� (���)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'��'
GROUP BY p.position_title, d.department_name

UNION

SELECT 
    p.position_title AS [���������],
    d.department_name AS [�����],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [������� ���� ��������� (���)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'������������'
GROUP BY p.position_title, d.department_name;

SELECT 
    p.position_title AS [���������],
    d.department_name AS [�����],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [������� ���� ��������� (���)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'��'
GROUP BY p.position_title, d.department_name

UNION ALL

SELECT 
    p.position_title AS [���������],
    d.department_name AS [�����],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [������� ���� ��������� (���)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'������������'
GROUP BY p.position_title, d.department_name;
SELECT 
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [������� ���� ��������� (���)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'��'
GROUP BY p.position_title

INTERSECT

SELECT 
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [������� ���� ��������� (���)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'������������'
GROUP BY p.position_title;
SELECT 
    p.position_title AS [���������],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [������� ���� ��������� (���)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'��'
GROUP BY p.position_title

EXCEPT

SELECT 
    p.position_title AS [���������],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [������� ���� ��������� (���)]
FROM dbo.Departments d
INNER JOIN dbo.Appointments a ON d.department_id = a.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
INNER JOIN dbo.Employees e ON a.employee_id = e.employee_id
WHERE d.department_name = N'������������'
GROUP BY p.position_title;