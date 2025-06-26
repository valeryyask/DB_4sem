-- Запрос для статистики по должностям в отделах
SELECT 
    d.department_name AS [Отдел],
    p.position_title AS [Должность],
    COUNT(*) AS [Количество назначений],
    MIN(a.contract_term_days) AS [Минимальный срок контракта],
    MAX(a.contract_term_days) AS [Максимальный срок контракта],
    AVG(CAST(a.contract_term_days AS FLOAT)) AS [Средний срок контракта]
FROM dbo.Appointments a
INNER JOIN dbo.Departments d ON a.department_id = d.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
GROUP BY d.department_name, p.position_title;
-- Запрос для подсчета сотрудников по возрастным группам
SELECT 
    age_range AS [Возрастной диапазон],
    COUNT(*) AS [Количество сотрудников]
FROM (
    SELECT 
        CASE 
            WHEN DATEDIFF(YEAR, birth_date, GETDATE()) BETWEEN 18 AND 30 THEN '18-30'
            WHEN DATEDIFF(YEAR, birth_date, GETDATE()) BETWEEN 31 AND 45 THEN '31-45'
            WHEN DATEDIFF(YEAR, birth_date, GETDATE()) BETWEEN 46 AND 60 THEN '46-60'
            ELSE '60+'
        END AS age_range
    FROM dbo.Employees
) sub
GROUP BY age_range
ORDER BY age_range DESC;
-- Запрос для среднего срока контракта по отделам и должностям
SELECT 
    d.department_name AS [Отдел],
    p.position_title AS [Должность],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [Средний срок контракта]
FROM dbo.Appointments a
INNER JOIN dbo.Departments d ON a.department_id = d.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
GROUP BY d.department_name, p.position_title
ORDER BY [Средний срок контракта] DESC;
-- Запрос для среднего срока контракта по должностям "Менеджер" и "Аналитик"
SELECT 
    d.department_name AS [Отдел],
    p.position_title AS [Должность],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [Средний срок контракта]
FROM dbo.Appointments a
INNER JOIN dbo.Departments d ON a.department_id = d.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
WHERE p.position_title LIKE N'%Менеджер%' OR p.position_title LIKE N'%Аналитик%'
GROUP BY d.department_name, p.position_title
ORDER BY [Средний срок контракта] DESC;
-- Запрос для среднего срока контракта по должностям в отделе "ИТ"
SELECT 
    p.position_title AS [Должность],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [Средний срок контракта]
FROM dbo.Appointments a
INNER JOIN dbo.Departments d ON a.department_id = d.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
WHERE d.department_name LIKE N'%ИТ%'
GROUP BY p.position_title
ORDER BY [Средний срок контракта] DESC;
-- Запрос для подсчета сотрудников с контрактами более 365 дней
SELECT 
    p.position_title AS [Должность],
    COUNT(*) AS [Количество сотрудников]
FROM dbo.Appointments a
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
WHERE a.contract_term_days > 365
GROUP BY p.position_title
HAVING COUNT(*) > 0
ORDER BY [Количество сотрудников] DESC;