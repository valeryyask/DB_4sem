CREATE VIEW ���������
AS
SELECT 
    E.employee_id AS ���,
    CONCAT(E.last_name, ' ', E.first_name, ' ', COALESCE(E.middle_name, '')) AS ������_���,
    E.gender AS ���,
    A.department_id AS ���_������
FROM dbo.Employees E
JOIN dbo.Appointments A ON E.employee_id = A.employee_id;
GO
use Y_MyBase select * from ���������
GO
CREATE VIEW ����������_�������
AS
SELECT 
    P.position_title AS ���������,
    COUNT(A.department_id) AS ����������_�������
FROM dbo.Positions P
LEFT JOIN dbo.Appointments A ON P.position_id = A.position_id
GROUP BY P.position_title;
GO
use Y_MyBase select * from ����������_������� 
GO
CREATE VIEW ��������_����������
AS
SELECT 
    appointment_id AS ���,
    appointment_date AS ����_����������
FROM dbo.Appointments
WHERE DATEADD(DAY, contract_term_days, appointment_date) >= GETDATE();
GO
use Y_MyBase select * from ��������_���������� 
GO
CREATE VIEW ��������_����������_������������
AS
SELECT 
    appointment_id AS ���,
    appointment_date AS ����_����������
FROM dbo.Appointments
WHERE DATEADD(DAY, contract_term_days, appointment_date) >= GETDATE()
WITH CHECK OPTION;
GO
use Y_MyBase select * from ��������_����������_������������
GO
CREATE VIEW ���������
AS
SELECT TOP (100) PERCENT
    position_id AS ���,
    position_title AS ��������_���������
FROM dbo.Positions
ORDER BY position_title;
GO
use Y_MyBase select * from ���������
GO
ALTER VIEW ����������_�������
WITH SCHEMABINDING
AS
SELECT 
    P.position_title AS ���������,
    COUNT_BIG(A.department_id) AS ����������_�������
FROM dbo.Positions P
LEFT JOIN dbo.Appointments A ON P.position_id = A.position_id
GROUP BY P.position_title;
GO