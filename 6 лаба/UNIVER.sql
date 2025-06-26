-- Запрос для вычисления статистики по типам аудиторий
SELECT 
    at.AUDITORIUM_TYPENAME AS [Тип аудитории],
    MAX(a.AUDITORIUM_CAPACITY) AS [Максимальная вместимость],
    MIN(a.AUDITORIUM_CAPACITY) AS [Минимальная вместимость],
    AVG(a.AUDITORIUM_CAPACITY) AS [Средняя вместимость],
    SUM(a.AUDITORIUM_CAPACITY) AS [Суммарная вместимость],
    COUNT(*) AS [Количество аудиторий]
FROM dbo.AUDITORIUM a
INNER JOIN dbo.AUDITORIUM_TYPE at
    ON a.AUDITORIUM_TYPE = at.AUDITORIUM_TYPE
GROUP BY at.AUDITORIUM_TYPENAME;
-- Запрос для подсчета оценок в интервалах с использованием CASE
SELECT 
    note_range AS [Оценка],
    COUNT(*) AS [Количество]
FROM (
    SELECT 
        CASE 
            WHEN NOTE BETWEEN 8 AND 10 THEN '8-10'
            WHEN NOTE BETWEEN 6 AND 7 THEN '6-7'
            WHEN NOTE BETWEEN 4 AND 5 THEN '4-5'
            ELSE '1-3'
        END AS note_range
    FROM dbo.PROGRESS
) sub
GROUP BY note_range
ORDER BY note_range DESC;
-- Запрос для вычисления средней оценки по факультетам, специальностям и курсам
SELECT 
    f.FACULTY_NAME AS [Факультет],
    p.PROFESSION_NAME AS [Специальность],
    g.COURSE AS [Курс],
    ROUND(AVG(CAST(pr.NOTE AS FLOAT)), 2) AS [Средняя оценка]
FROM dbo.FACULTY f
INNER JOIN dbo.[GROUP] g ON f.FACULTY = g.FACULTY
INNER JOIN dbo.PROFESSION p ON g.PROFESSION = p.PROFESSION
INNER JOIN dbo.STUDENT s ON g.IDGROUP = s.IDGROUP
INNER JOIN dbo.PROGRESS pr ON s.IDSTUDENT = pr.IDSTUDENT
GROUP BY f.FACULTY_NAME, p.PROFESSION_NAME, g.COURSE
ORDER BY [Средняя оценка] DESC;
-- Запрос для средней оценки по дисциплинам БД и ОАиП
SELECT 
    f.FACULTY_NAME AS [Факультет],
    p.PROFESSION_NAME AS [Специальность],
    g.COURSE AS [Курс],
    ROUND(AVG(CAST(pr.NOTE AS FLOAT)), 2) AS [Средняя оценка]
FROM dbo.FACULTY f
INNER JOIN dbo.[GROUP] g ON f.FACULTY = g.FACULTY
INNER JOIN dbo.PROFESSION p ON g.PROFESSION = p.PROFESSION
INNER JOIN dbo.STUDENT s ON g.IDGROUP = s.IDGROUP
INNER JOIN dbo.PROGRESS pr ON s.IDSTUDENT = pr.IDSTUDENT
INNER JOIN dbo.SUBJECT sub ON pr.SUBJECT = sub.SUBJECT
WHERE sub.SUBJECT_NAME IN (N'Системы управления базами данных', N'Основы алгоритмизации и программирования')
GROUP BY f.FACULTY_NAME, p.PROFESSION_NAME, g.COURSE
ORDER BY [Средняя оценка] DESC;
-- Запрос для средних оценок по дисциплинам на факультете ТОВ
SELECT 
    p.PROFESSION_NAME AS [Специальность],
    sub.SUBJECT_NAME AS [Дисциплина],
    ROUND(AVG(CAST(pr.NOTE AS FLOAT)), 2) AS [Средняя оценка]
FROM dbo.FACULTY f
INNER JOIN dbo.[GROUP] g ON f.FACULTY = g.FACULTY
INNER JOIN dbo.PROFESSION p ON g.PROFESSION = p.PROFESSION
INNER JOIN dbo.STUDENT s ON g.IDGROUP = s.IDGROUP
INNER JOIN dbo.PROGRESS pr ON s.IDSTUDENT = pr.IDSTUDENT
INNER JOIN dbo.SUBJECT sub ON pr.SUBJECT = sub.SUBJECT
WHERE f.FACULTY = 'ТОВ'
GROUP BY p.PROFESSION_NAME, sub.SUBJECT_NAME
ORDER BY [Средняя оценка] DESC;
-- Запрос для подсчета студентов с оценками 8 и 9 по дисциплинам
SELECT 
    sub.SUBJECT_NAME AS [Дисциплина],
    COUNT(*) AS [Количество студентов]
FROM dbo.PROGRESS pr
INNER JOIN dbo.SUBJECT sub ON pr.SUBJECT = sub.SUBJECT
WHERE pr.NOTE IN (8, 9)
GROUP BY sub.SUBJECT_NAME
HAVING COUNT(*) > 0
ORDER BY [Количество студентов] DESC;