-- Создание базы данных
CREATE DATABASE UNIVER;
GO

-- Использование созданной базы данных
USE UNIVER;
GO

-- Создание таблицы FACULTY
CREATE TABLE dbo.FACULTY (
    FACULTY CHAR(10) NOT NULL,
    FACULTY_NAME NVARCHAR(50) DEFAULT '???',
    CONSTRAINT PK_FACULTY PRIMARY KEY (FACULTY)
);
GO

-- Создание таблицы PROFESSION
CREATE TABLE dbo.PROFESSION (
    PROFESSION CHAR(20) NOT NULL,
    FACULTY CHAR(10) NOT NULL,
    PROFESSION_NAME NVARCHAR(100) NULL,
    QUALIFICATION NVARCHAR(50) NULL,
    CONSTRAINT PK_PROFESSION PRIMARY KEY (PROFESSION),
    CONSTRAINT FK_PROFESSION_FACULTY FOREIGN KEY (FACULTY) REFERENCES dbo.FACULTY(FACULTY)
);
GO

-- Создание таблицы PULPIT
CREATE TABLE dbo.PULPIT (
    PULPIT CHAR(20) NOT NULL,
    PULPIT_NAME NVARCHAR(100) NULL,
    FACULTY CHAR(10) NOT NULL,
    CONSTRAINT PK_PULPIT PRIMARY KEY (PULPIT),
    CONSTRAINT FK_PULPIT_FACULTY FOREIGN KEY (FACULTY) REFERENCES dbo.FACULTY(FACULTY)
);
GO

-- Создание таблицы TEACHER
CREATE TABLE dbo.TEACHER (
    TEACHER CHAR(10) NOT NULL,
    TEACHER_NAME NVARCHAR(100) NULL,
    GENDER CHAR(1) NULL,
    PULPIT CHAR(20) NOT NULL,
    CONSTRAINT PK_TEACHER PRIMARY KEY (TEACHER),
    CONSTRAINT FK_TEACHER_PULPIT FOREIGN KEY (PULPIT) REFERENCES dbo.PULPIT(PULPIT),
    CONSTRAINT CHK_GENDER CHECK (GENDER IN (N'м', N'ж'))
);
GO

-- Создание таблицы SUBJECT
CREATE TABLE dbo.SUBJECT (
    SUBJECT CHAR(10) NOT NULL,
    SUBJECT_NAME NVARCHAR(100) NULL UNIQUE,
    PULPIT CHAR(20) NOT NULL,
    CONSTRAINT PK_SUBJECT PRIMARY KEY (SUBJECT),
    CONSTRAINT FK_SUBJECT_PULPIT FOREIGN KEY (PULPIT) REFERENCES dbo.PULPIT(PULPIT)
);
GO

-- Создание таблицы AUDITORIUM_TYPE
CREATE TABLE dbo.AUDITORIUM_TYPE (
    AUDITORIUM_TYPE CHAR(10) NOT NULL,
    AUDITORIUM_TYPENAME NVARCHAR(30) NULL,
    CONSTRAINT PK_AUDITORIUM_TYPE PRIMARY KEY (AUDITORIUM_TYPE)
);
GO

-- Создание таблицы AUDITORIUM
CREATE TABLE dbo.AUDITORIUM (
    AUDITORIUM CHAR(20) NOT NULL,
    AUDITORIUM_TYPE CHAR(10) NOT NULL,
    AUDITORIUM_CAPACITY INT DEFAULT 1,
    AUDITORIUM_NAME NVARCHAR(50) NULL,
    CONSTRAINT PK_AUDITORIUM PRIMARY KEY (AUDITORIUM),
    CONSTRAINT FK_AUDITORIUM_AUDITORIUM_TYPE FOREIGN KEY (AUDITORIUM_TYPE) REFERENCES dbo.AUDITORIUM_TYPE(AUDITORIUM_TYPE),
    CONSTRAINT CHK_AUDITORIUM_CAPACITY CHECK (AUDITORIUM_CAPACITY BETWEEN 1 AND 300)
);
GO

-- Создание таблицы GROUP
CREATE TABLE dbo.[GROUP] (
    IDGROUP INT NOT NULL,
    FACULTY CHAR(10) NOT NULL,
    PROFESSION CHAR(20) NOT NULL,
    YEAR_FIRST SMALLINT NULL,
    COURSE AS CAST(DATEDIFF(YEAR, DATEFROMPARTS(YEAR_FIRST, 9, 1), GETDATE()) AS TINYINT),
    CONSTRAINT PK_GROUP PRIMARY KEY (IDGROUP),
    CONSTRAINT FK_GROUP_FACULTY FOREIGN KEY (FACULTY) REFERENCES dbo.FACULTY(FACULTY),
    CONSTRAINT FK_GROUP_PROFESSION FOREIGN KEY (PROFESSION) REFERENCES dbo.PROFESSION(PROFESSION),
    CONSTRAINT CHK_YEAR_FIRST CHECK (YEAR_FIRST < YEAR(GETDATE()) + 2)
);
GO

-- Создание таблицы STUDENT
CREATE TABLE dbo.STUDENT (
    IDSTUDENT INT NOT NULL IDENTITY(1000,1),
    IDGROUP INT NOT NULL,
    [NAME] NVARCHAR(100) NULL,
    BDAY DATE NULL,
    STAMP ROWVERSION,
    INFO XML NULL,
    FOTO VARBINARY(MAX) NULL,
    CONSTRAINT PK_STUDENT PRIMARY KEY (IDSTUDENT),
    CONSTRAINT FK_STUDENT_GROUP FOREIGN KEY (IDGROUP) REFERENCES dbo.[GROUP](IDGROUP)
);
GO

-- Создание таблицы PROGRESS
CREATE TABLE dbo.PROGRESS (
    SUBJECT CHAR(10) NOT NULL,
    IDSTUDENT INT NOT NULL,
    PDATE DATE NULL,
    NOTE INT NULL,
    CONSTRAINT PK_PROGRESS PRIMARY KEY (SUBJECT, IDSTUDENT),
    CONSTRAINT FK_PROGRESS_SUBJECT FOREIGN KEY (SUBJECT) REFERENCES dbo.SUBJECT(SUBJECT),
    CONSTRAINT FK_PROGRESS_STUDENT FOREIGN KEY (IDSTUDENT) REFERENCES dbo.STUDENT(IDSTUDENT),
    CONSTRAINT CHK_NOTE CHECK (NOTE BETWEEN 1 AND 10)
);
GO

-- Заполнение таблицы FACULTY
INSERT INTO dbo.FACULTY (FACULTY, FACULTY_NAME) VALUES
    ('ТТЛП', N'Технологии и техника лесной промышленности'),
    ('ТОВ', N'Технологии органических веществ'),
    ('ХТиТ', N'Химические технологии и техника'),
    ('ИЭФ', N'Инженерно-экономический'),
    ('ЛХ', N'Лесохозяйственный'),
    ('ИДиП', N'Издательское дело и полиграфия'),
    ('ИТ', N'Информационных технологий');
GO

-- Заполнение таблицы PROFESSION
INSERT INTO dbo.PROFESSION (PROFESSION, FACULTY, PROFESSION_NAME, QUALIFICATION) VALUES
    ('1-36 06 01', 'ИДиП', N'Полиграфическое оборудование и системы обработки информации', N'инженер-электромеханик'),
    ('1-36 07 01', 'ХТиТ', N'Машины и аппараты химических производств и предприятий строительных материалов', N'инженер-механик'),
    ('1-40 01 02', 'ИТ', N'Информационные системы и технологии', N'инженер-программист-системотехник'),
    ('1-46 01 01', 'ТТЛП', N'Лесоинженерное дело', N'инженер-технолог'),
    ('1-47 01 01', 'ИДиП', N'Издательское дело', N'редактор-технолог'),
    ('1-48 01 02', 'ТОВ', N'Химическая технология органических веществ, материалов и изделий', N'инженер-химик-технолог'),
    ('1-48 01 05', 'ТОВ', N'Химическая технология переработки древесины', N'инженер-химик-технолог'),
    ('1-54 01 03', 'ТОВ', N'Физико-химические методы и приборы контроля качества продукции', N'инженер по сертификации'),
    ('1-75 01 01', 'ЛХ', N'Лесное хозяйство', N'инженер лесного хозяйства'),
    ('1-75 02 01', 'ЛХ', N'Садово-парковое строительство', N'инженер садово-паркового строительства'),
    ('1-89 02 02', 'ЛХ', N'Туризм и природопользование', N'специалист в сфере туризма');
GO

-- Заполнение таблицы PULPIT
INSERT INTO dbo.PULPIT (PULPIT, PULPIT_NAME, FACULTY) VALUES
    ('РИТ', N'Редакционно-издательских технологий', 'ИДиП'),
    ('СБУАиА', N'Статистики, бухгалтерского учета, анализа и аудита', 'ИЭФ'),
    ('ТДП', N'Технологий деревообрабатывающих производств', 'ТТЛП'),
    ('ТиДИД', N'Технологии и дизайна изделий из древесины', 'ТТЛП'),
    ('ТиП', N'Туризма и природопользования', 'ЛХ'),
    ('ТЛ', N'Транспорта леса', 'ТТЛП'),
    ('ТНВиОХТ', N'Технологии неорганических веществ и общей химической технологии', 'ХТиТ'),
    ('ТНХСиППМ', N'Технологии нефтехимического синтеза и переработки полимерных материалов', 'ТОВ'),
    ('ХПД', N'Химической переработки древесины', 'ТОВ'),
    ('ХТЭПиМЭЕ', N'Химии, технологии электрохимических производств и материалов электронной техники', 'ХТиТ'),
    ('ЭТиМ', N'Экономической теории и маркетинга', 'ИЭФ');
GO

-- Заполнение таблицы TEACHER
INSERT INTO dbo.TEACHER (TEACHER, TEACHER_NAME, GENDER, PULPIT) VALUES
    ('НСКВ', N'Носков Михаил Трофимович', NULL, 'ТДП'),
    ('ПРКП', N'Прокопенко Николай Иванович', NULL, 'ТНХСиППМ'),
    ('МРЗВ', N'Морозова Елена Степановна', NULL, 'ТНХСиППМ'),
    ('РВКС', N'Ровкас Андрей Петрович', NULL, 'ТНХСиППМ'),
    ('РЖКВ', N'Рыжиков Леонид Николаевич', NULL, 'ТНХСиППМ'),
    ('РМНВ', N'Романов Дмитрий Михайлович', NULL, 'ТНХСиППМ'),
    ('СМЛВ', N'Смелов Владимир Владиславович', NULL, 'ТНХСиППМ'),
    ('КРЛВ', N'Крылов Павел Павлович', NULL, 'ТНХСиППМ'),
    ('ЧРН', N'Чернова Анна Викторовна', NULL, 'ХПД'),
    ('МХВ', N'Мохов Михаил Сергеевич', NULL, 'ХПД');
GO

-- Заполнение таблицы SUBJECT
INSERT INTO dbo.SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) VALUES
    ('ПЗ', N'Представление знаний в компьютерных системах', 'ТНХСиППМ'),
    ('ПИС', N'Проектирование информационных систем', 'ТНХСиППМ'),
    ('ПСП', N'Программирование сетевых приложений', 'ТНХСиППМ'),
    ('ПЭХ', N'Прикладная электрохимия', 'ХТЭПиМЭЕ'),
    ('СУБД', N'Системы управления базами данных', 'ТНХСиППМ'),
    ('ТиОЛ', N'Технология и оборудование лесозаготовок', 'ТЛ'),
    ('ТРИ', N'Технология резиновых изделий', 'ТНХСиППМ'),
    ('ЭП', N'Экономика природопользования', 'ЭТиМ'),
    ('ЭТ', N'Экономическая теория', 'ЭТиМ');
GO

-- Заполнение таблицы AUDITORIUM_TYPE
INSERT INTO dbo.AUDITORIUM_TYPE (AUDITORIUM_TYPE, AUDITORIUM_TYPENAME) VALUES
    ('ЛБ-X', N'Химическая лаборатория'),
    ('ЛБ-К', N'Компьютерный класс'),
    ('ЛБ-СК', N'Спец. компьютерный класс'),
    ('ЛК', N'Лекционная'),
    ('ЛК-К', N'Лекционная с уст. проектором');
GO

-- Заполнение таблицы AUDITORIUM
INSERT INTO dbo.AUDITORIUM (AUDITORIUM, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY, AUDITORIUM_NAME) VALUES
    ('301-1', 'ЛБ-К', 15, N'301-1'),
    ('304-4', 'ЛБ-К', 90, N'304-4'),
    ('313-1', 'ЛК-К', 60, N'313-1'),
    ('314-4', 'ЛК', 90, N'314-4'),
    ('320-4', 'ЛК', 90, N'320-4'),
    ('324-1', 'ЛК-К', 50, N'324-1'),
    ('413-1', 'ЛБ-К', 15, N'413-1'),
    ('423-1', 'ЛБ-К', 90, N'423-1');
GO

-- Заполнение таблицы GROUP
INSERT INTO dbo.[GROUP] (IDGROUP, FACULTY, PROFESSION, YEAR_FIRST) VALUES
    (22, 'ЛХ', '1-75 02 01', 2011),
    (23, 'ЛХ', '1-89 02 02', 2012),
    (24, 'ЛХ', '1-89 02 02', 2011),
    (25, 'ТТЛП', '1-46 01 01', 2013),
    (26, 'ТТЛП', '1-46 01 01', 2012),
    (27, 'ТТЛП', '1-46 01 01', 2012),
    (28, 'ИЭФ', '1-36 07 01', 2013),
    (29, 'ИЭФ', '1-36 07 01', 2012),
    (30, 'ИЭФ', '1-36 07 01', 2010),
    (31, 'ИЭФ', '1-36 07 01', 2013),
    (32, 'ИЭФ', '1-36 07 01', 2012);
GO

-- Заполнение таблицы STUDENT
INSERT INTO dbo.STUDENT (IDGROUP, [NAME], BDAY) VALUES
    (22, N'Пугач Михаил Трофимович', '1996-01-12'),
    (23, N'Авдеев Николай Иванович', '1996-07-19'),
    (24, N'Белова Елена Степановна', '1996-05-22'),
    (25, N'Вилков Андрей Петрович', '1996-12-08'),
    (26, N'Грушин Леонид Николаевич', '1995-11-11'),
    (27, N'Дунаев Дмитрий Михайлович', '1996-08-24'),
    (28, N'Клуни Иван Владиславович', '1996-09-15'),
    (29, N'Крылов Олег Павлович', '1996-10-16');
GO

-- Заполнение таблицы PROGRESS
INSERT INTO dbo.PROGRESS (SUBJECT, IDSTUDENT, PDATE, NOTE) VALUES
    ('ПЗ', 1000, '2014-01-12', 4),
    ('ПЗ', 1001, '2014-01-19', 5),
    ('ПЗ', 1003, '2014-01-08', 9),
    ('СУБД', 1006, '2014-01-11', 8),
    ('СУБД', 1007, '2014-01-27', 6);
GO

-- Проверка содержимого таблиц
SELECT * FROM dbo.FACULTY;
SELECT * FROM dbo.PROFESSION;
SELECT * FROM dbo.PULPIT;
SELECT * FROM dbo.TEACHER;
SELECT * FROM dbo.SUBJECT;
SELECT * FROM dbo.AUDITORIUM_TYPE;
SELECT * FROM dbo.AUDITORIUM;
SELECT * FROM dbo.[GROUP];
SELECT * FROM dbo.STUDENT;
SELECT * FROM dbo.PROGRESS;
GO