CREATE VIEW �������������
AS
SELECT 
    TEACHER AS ���,
    TEACHER_NAME AS ���_�������������,
    GENDER AS ���,
    PULPIT AS ���_�������
FROM dbo.TEACHER;
GO
use UNIVER select * from �������������
GO
CREATE VIEW ����������_������
AS
SELECT 
    F.FACULTY AS ���������,
    COUNT(P.PULPIT) AS ����������_������
FROM dbo.FACULTY F
LEFT JOIN dbo.PULPIT P ON F.FACULTY = P.FACULTY
GROUP BY F.FACULTY;
GO
use UNIVER select * from ����������_������
GO
CREATE VIEW ���������
AS
SELECT 
    AUDITORIUM AS ���,
    AUDITORIUM_NAME AS ������������_���������
FROM dbo.AUDITORIUM
WHERE AUDITORIUM_TYPE LIKE '��%';
GO
use UNIVER select * from ���������
GO
CREATE VIEW ����������_���������
AS
SELECT 
    AUDITORIUM AS ���,
    AUDITORIUM_NAME AS ������������_���������
FROM dbo.AUDITORIUM
WHERE AUDITORIUM_TYPE LIKE '��%'
WITH CHECK OPTION;
GO
use UNIVER select * from ����������_���������
GO
CREATE VIEW ����������
AS
SELECT TOP (100) PERCENT
    SUBJECT AS ���,
    SUBJECT_NAME AS ������������_����������,
    PULPIT AS ���_�������
FROM dbo.SUBJECT
ORDER BY SUBJECT_NAME;
GO
use UNIVER select * from ����������
GO
ALTER VIEW ����������_������
WITH SCHEMABINDING
AS
SELECT 
    F.FACULTY AS ���������,
    COUNT_BIG(P.PULPIT) AS ����������_������
FROM dbo.FACULTY F
LEFT JOIN dbo.PULPIT P ON F.FACULTY = P.FACULTY
GROUP BY F.FACULTY;
GO