-- ������ ��� ���������� �� ���������� � �������
SELECT 
    d.department_name AS [�����],
    p.position_title AS [���������],
    COUNT(*) AS [���������� ����������],
    MIN(a.contract_term_days) AS [����������� ���� ���������],
    MAX(a.contract_term_days) AS [������������ ���� ���������],
    AVG(CAST(a.contract_term_days AS FLOAT)) AS [������� ���� ���������]
FROM dbo.Appointments a
INNER JOIN dbo.Departments d ON a.department_id = d.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
GROUP BY d.department_name, p.position_title;
-- ������ ��� �������� ����������� �� ���������� �������
SELECT 
    age_range AS [���������� ��������],
    COUNT(*) AS [���������� �����������]
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
-- ������ ��� �������� ����� ��������� �� ������� � ����������
SELECT 
    d.department_name AS [�����],
    p.position_title AS [���������],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [������� ���� ���������]
FROM dbo.Appointments a
INNER JOIN dbo.Departments d ON a.department_id = d.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
GROUP BY d.department_name, p.position_title
ORDER BY [������� ���� ���������] DESC;
-- ������ ��� �������� ����� ��������� �� ���������� "��������" � "��������"
SELECT 
    d.department_name AS [�����],
    p.position_title AS [���������],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [������� ���� ���������]
FROM dbo.Appointments a
INNER JOIN dbo.Departments d ON a.department_id = d.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
WHERE p.position_title LIKE N'%��������%' OR p.position_title LIKE N'%��������%'
GROUP BY d.department_name, p.position_title
ORDER BY [������� ���� ���������] DESC;
-- ������ ��� �������� ����� ��������� �� ���������� � ������ "��"
SELECT 
    p.position_title AS [���������],
    ROUND(AVG(CAST(a.contract_term_days AS FLOAT)), 2) AS [������� ���� ���������]
FROM dbo.Appointments a
INNER JOIN dbo.Departments d ON a.department_id = d.department_id
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
WHERE d.department_name LIKE N'%��%'
GROUP BY p.position_title
ORDER BY [������� ���� ���������] DESC;
-- ������ ��� �������� ����������� � ����������� ����� 365 ����
SELECT 
    p.position_title AS [���������],
    COUNT(*) AS [���������� �����������]
FROM dbo.Appointments a
INNER JOIN dbo.Positions p ON a.position_id = p.position_id
WHERE a.contract_term_days > 365
GROUP BY p.position_title
HAVING COUNT(*) > 0
ORDER BY [���������� �����������] DESC;