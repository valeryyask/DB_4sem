CREATE VIEW Преподаватель
AS
SELECT 
    TEACHER AS Код,
    TEACHER_NAME AS Имя_преподавателя,
    GENDER AS Пол,
    PULPIT AS Код_кафедры
FROM dbo.TEACHER;
GO
use UNIVER select * from Преподаватель
GO
CREATE VIEW Количество_кафедр
AS
SELECT 
    F.FACULTY AS Факультет,
    COUNT(P.PULPIT) AS Количество_кафедр
FROM dbo.FACULTY F
LEFT JOIN dbo.PULPIT P ON F.FACULTY = P.FACULTY
GROUP BY F.FACULTY;
GO
use UNIVER select * from Количество_кафедр
GO
CREATE VIEW Аудитории
AS
SELECT 
    AUDITORIUM AS Код,
    AUDITORIUM_NAME AS Наименование_аудитории
FROM dbo.AUDITORIUM
WHERE AUDITORIUM_TYPE LIKE 'ЛК%';
GO
use UNIVER select * from Аудитории
GO
CREATE VIEW Лекционные_аудитории
AS
SELECT 
    AUDITORIUM AS Код,
    AUDITORIUM_NAME AS Наименование_аудитории
FROM dbo.AUDITORIUM
WHERE AUDITORIUM_TYPE LIKE 'ЛК%'
WITH CHECK OPTION;
GO
use UNIVER select * from Лекционные_аудитории
GO
CREATE VIEW Дисциплины
AS
SELECT TOP (100) PERCENT
    SUBJECT AS Код,
    SUBJECT_NAME AS Наименование_дисциплины,
    PULPIT AS Код_кафедры
FROM dbo.SUBJECT
ORDER BY SUBJECT_NAME;
GO
use UNIVER select * from Дисциплины
GO
ALTER VIEW Количество_кафедр
WITH SCHEMABINDING
AS
SELECT 
    F.FACULTY AS Факультет,
    COUNT_BIG(P.PULPIT) AS Количество_кафедр
FROM dbo.FACULTY F
LEFT JOIN dbo.PULPIT P ON F.FACULTY = P.FACULTY
GROUP BY F.FACULTY;
GO