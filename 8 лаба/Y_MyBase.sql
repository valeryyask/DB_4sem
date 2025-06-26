CREATE VIEW Сотрудник
AS
SELECT 
    E.employee_id AS Код,
    CONCAT(E.last_name, ' ', E.first_name, ' ', COALESCE(E.middle_name, '')) AS Полное_имя,
    E.gender AS Пол,
    A.department_id AS Код_отдела
FROM dbo.Employees E
JOIN dbo.Appointments A ON E.employee_id = A.employee_id;
GO
use Y_MyBase select * from Сотрудник
GO
CREATE VIEW Количество_отделов
AS
SELECT 
    P.position_title AS Должность,
    COUNT(A.department_id) AS Количество_отделов
FROM dbo.Positions P
LEFT JOIN dbo.Appointments A ON P.position_id = A.position_id
GROUP BY P.position_title;
GO
use Y_MyBase select * from Количество_отделов 
GO
CREATE VIEW Активные_назначения
AS
SELECT 
    appointment_id AS Код,
    appointment_date AS Дата_назначения
FROM dbo.Appointments
WHERE DATEADD(DAY, contract_term_days, appointment_date) >= GETDATE();
GO
use Y_MyBase select * from Активные_назначения 
GO
CREATE VIEW Активные_назначения_ограниченные
AS
SELECT 
    appointment_id AS Код,
    appointment_date AS Дата_назначения
FROM dbo.Appointments
WHERE DATEADD(DAY, contract_term_days, appointment_date) >= GETDATE()
WITH CHECK OPTION;
GO
use Y_MyBase select * from Активные_назначения_ограниченные
GO
CREATE VIEW Должности
AS
SELECT TOP (100) PERCENT
    position_id AS Код,
    position_title AS Название_должности
FROM dbo.Positions
ORDER BY position_title;
GO
use Y_MyBase select * from Должности
GO
ALTER VIEW Количество_отделов
WITH SCHEMABINDING
AS
SELECT 
    P.position_title AS Должность,
    COUNT_BIG(A.department_id) AS Количество_отделов
FROM dbo.Positions P
LEFT JOIN dbo.Appointments A ON P.position_id = A.position_id
GROUP BY P.position_title;
GO