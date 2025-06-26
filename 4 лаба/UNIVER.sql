-- �������� ���� ������
CREATE DATABASE UNIVER;
GO

-- ������������� ��������� ���� ������
USE UNIVER;
GO

-- �������� ������� FACULTY
CREATE TABLE dbo.FACULTY (
    FACULTY CHAR(10) NOT NULL,
    FACULTY_NAME NVARCHAR(50) DEFAULT '???',
    CONSTRAINT PK_FACULTY PRIMARY KEY (FACULTY)
);
GO

-- �������� ������� PROFESSION
CREATE TABLE dbo.PROFESSION (
    PROFESSION CHAR(20) NOT NULL,
    FACULTY CHAR(10) NOT NULL,
    PROFESSION_NAME NVARCHAR(100) NULL,
    QUALIFICATION NVARCHAR(50) NULL,
    CONSTRAINT PK_PROFESSION PRIMARY KEY (PROFESSION),
    CONSTRAINT FK_PROFESSION_FACULTY FOREIGN KEY (FACULTY) REFERENCES dbo.FACULTY(FACULTY)
);
GO

-- �������� ������� PULPIT
CREATE TABLE dbo.PULPIT (
    PULPIT CHAR(20) NOT NULL,
    PULPIT_NAME NVARCHAR(100) NULL,
    FACULTY CHAR(10) NOT NULL,
    CONSTRAINT PK_PULPIT PRIMARY KEY (PULPIT),
    CONSTRAINT FK_PULPIT_FACULTY FOREIGN KEY (FACULTY) REFERENCES dbo.FACULTY(FACULTY)
);
GO

-- �������� ������� TEACHER
CREATE TABLE dbo.TEACHER (
    TEACHER CHAR(10) NOT NULL,
    TEACHER_NAME NVARCHAR(100) NULL,
    GENDER CHAR(1) NULL,
    PULPIT CHAR(20) NOT NULL,
    CONSTRAINT PK_TEACHER PRIMARY KEY (TEACHER),
    CONSTRAINT FK_TEACHER_PULPIT FOREIGN KEY (PULPIT) REFERENCES dbo.PULPIT(PULPIT),
    CONSTRAINT CHK_GENDER CHECK (GENDER IN (N'�', N'�'))
);
GO

-- �������� ������� SUBJECT
CREATE TABLE dbo.SUBJECT (
    SUBJECT CHAR(10) NOT NULL,
    SUBJECT_NAME NVARCHAR(100) NULL UNIQUE,
    PULPIT CHAR(20) NOT NULL,
    CONSTRAINT PK_SUBJECT PRIMARY KEY (SUBJECT),
    CONSTRAINT FK_SUBJECT_PULPIT FOREIGN KEY (PULPIT) REFERENCES dbo.PULPIT(PULPIT)
);
GO

-- �������� ������� AUDITORIUM_TYPE
CREATE TABLE dbo.AUDITORIUM_TYPE (
    AUDITORIUM_TYPE CHAR(10) NOT NULL,
    AUDITORIUM_TYPENAME NVARCHAR(30) NULL,
    CONSTRAINT PK_AUDITORIUM_TYPE PRIMARY KEY (AUDITORIUM_TYPE)
);
GO

-- �������� ������� AUDITORIUM
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

-- �������� ������� GROUP
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

-- �������� ������� STUDENT
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

-- �������� ������� PROGRESS
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

-- ���������� ������� FACULTY
INSERT INTO dbo.FACULTY (FACULTY, FACULTY_NAME) VALUES
    ('����', N'���������� � ������� ������ ��������������'),
    ('���', N'���������� ������������ �������'),
    ('����', N'���������� ���������� � �������'),
    ('���', N'���������-�������������'),
    ('��', N'�����������������'),
    ('����', N'������������ ���� � ����������'),
    ('��', N'�������������� ����������');
GO

-- ���������� ������� PROFESSION
INSERT INTO dbo.PROFESSION (PROFESSION, FACULTY, PROFESSION_NAME, QUALIFICATION) VALUES
    ('1-36 06 01', '����', N'��������������� ������������ � ������� ��������� ����������', N'�������-��������������'),
    ('1-36 07 01', '����', N'������ � �������� ���������� ����������� � ����������� ������������ ����������', N'�������-�������'),
    ('1-40 01 02', '��', N'�������������� ������� � ����������', N'�������-�����������-�������������'),
    ('1-46 01 01', '����', N'�������������� ����', N'�������-��������'),
    ('1-47 01 01', '����', N'������������ ����', N'��������-��������'),
    ('1-48 01 02', '���', N'���������� ���������� ������������ �������, ���������� � �������', N'�������-�����-��������'),
    ('1-48 01 05', '���', N'���������� ���������� ����������� ���������', N'�������-�����-��������'),
    ('1-54 01 03', '���', N'������-���������� ������ � ������� �������� �������� ���������', N'������� �� ������������'),
    ('1-75 01 01', '��', N'������ ���������', N'������� ������� ���������'),
    ('1-75 02 01', '��', N'������-�������� �������������', N'������� ������-��������� �������������'),
    ('1-89 02 02', '��', N'������ � ������������������', N'���������� � ����� �������');
GO

-- ���������� ������� PULPIT
INSERT INTO dbo.PULPIT (PULPIT, PULPIT_NAME, FACULTY) VALUES
    ('���', N'�����������-������������ ����������', '����'),
    ('������', N'����������, �������������� �����, ������� � ������', '���'),
    ('���', N'���������� �������������������� �����������', '����'),
    ('�����', N'���������� � ������� ������� �� ���������', '����'),
    ('���', N'������� � ������������������', '��'),
    ('��', N'���������� ����', '����'),
    ('�������', N'���������� �������������� ������� � ����� ���������� ����������', '����'),
    ('��������', N'���������� ���������������� ������� � ����������� ���������� ����������', '���'),
    ('���', N'���������� ����������� ���������', '���'),
    ('��������', N'�����, ���������� ����������������� ����������� � ���������� ����������� �������', '����'),
    ('����', N'������������� ������ � ����������', '���');
GO

-- ���������� ������� TEACHER
INSERT INTO dbo.TEACHER (TEACHER, TEACHER_NAME, GENDER, PULPIT) VALUES
    ('����', N'������ ������ ����������', NULL, '���'),
    ('����', N'���������� ������� ��������', NULL, '��������'),
    ('����', N'�������� ����� ����������', NULL, '��������'),
    ('����', N'������ ������ ��������', NULL, '��������'),
    ('����', N'������� ������ ����������', NULL, '��������'),
    ('����', N'������� ������� ����������', NULL, '��������'),
    ('����', N'������ �������� �������������', NULL, '��������'),
    ('����', N'������ ����� ��������', NULL, '��������'),
    ('���', N'������� ���� ����������', NULL, '���'),
    ('���', N'����� ������ ���������', NULL, '���');
GO

-- ���������� ������� SUBJECT
INSERT INTO dbo.SUBJECT (SUBJECT, SUBJECT_NAME, PULPIT) VALUES
    ('��', N'������������� ������ � ������������ ��������', '��������'),
    ('���', N'�������������� �������������� ������', '��������'),
    ('���', N'���������������� ������� ����������', '��������'),
    ('���', N'���������� ������������', '��������'),
    ('����', N'������� ���������� ������ ������', '��������'),
    ('����', N'���������� � ������������ �������������', '��'),
    ('���', N'���������� ��������� �������', '��������'),
    ('��', N'��������� ������������������', '����'),
    ('��', N'������������� ������', '����');
GO

-- ���������� ������� AUDITORIUM_TYPE
INSERT INTO dbo.AUDITORIUM_TYPE (AUDITORIUM_TYPE, AUDITORIUM_TYPENAME) VALUES
    ('��-X', N'���������� �����������'),
    ('��-�', N'������������ �����'),
    ('��-��', N'����. ������������ �����'),
    ('��', N'����������'),
    ('��-�', N'���������� � ���. ����������');
GO

-- ���������� ������� AUDITORIUM
INSERT INTO dbo.AUDITORIUM (AUDITORIUM, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY, AUDITORIUM_NAME) VALUES
    ('301-1', '��-�', 15, N'301-1'),
    ('304-4', '��-�', 90, N'304-4'),
    ('313-1', '��-�', 60, N'313-1'),
    ('314-4', '��', 90, N'314-4'),
    ('320-4', '��', 90, N'320-4'),
    ('324-1', '��-�', 50, N'324-1'),
    ('413-1', '��-�', 15, N'413-1'),
    ('423-1', '��-�', 90, N'423-1');
GO

-- ���������� ������� GROUP
INSERT INTO dbo.[GROUP] (IDGROUP, FACULTY, PROFESSION, YEAR_FIRST) VALUES
    (22, '��', '1-75 02 01', 2011),
    (23, '��', '1-89 02 02', 2012),
    (24, '��', '1-89 02 02', 2011),
    (25, '����', '1-46 01 01', 2013),
    (26, '����', '1-46 01 01', 2012),
    (27, '����', '1-46 01 01', 2012),
    (28, '���', '1-36 07 01', 2013),
    (29, '���', '1-36 07 01', 2012),
    (30, '���', '1-36 07 01', 2010),
    (31, '���', '1-36 07 01', 2013),
    (32, '���', '1-36 07 01', 2012);
GO

-- ���������� ������� STUDENT
INSERT INTO dbo.STUDENT (IDGROUP, [NAME], BDAY) VALUES
    (22, N'����� ������ ����������', '1996-01-12'),
    (23, N'������ ������� ��������', '1996-07-19'),
    (24, N'������ ����� ����������', '1996-05-22'),
    (25, N'������ ������ ��������', '1996-12-08'),
    (26, N'������ ������ ����������', '1995-11-11'),
    (27, N'������ ������� ����������', '1996-08-24'),
    (28, N'����� ���� �������������', '1996-09-15'),
    (29, N'������ ���� ��������', '1996-10-16');
GO

-- ���������� ������� PROGRESS
INSERT INTO dbo.PROGRESS (SUBJECT, IDSTUDENT, PDATE, NOTE) VALUES
    ('��', 1000, '2014-01-12', 4),
    ('��', 1001, '2014-01-19', 5),
    ('��', 1003, '2014-01-08', 9),
    ('����', 1006, '2014-01-11', 8),
    ('����', 1007, '2014-01-27', 6);
GO

-- �������� ����������� ������
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