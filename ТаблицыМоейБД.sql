 --Создание таблицы "Сотрудники"
CREATE TABLE dbo.Employees (
    employee_id INT IDENTITY(1,1) PRIMARY KEY,
    last_name NVARCHAR(50) NOT NULL,
    first_name NVARCHAR(50) NOT NULL,
    middle_name NVARCHAR(50),
    birth_date DATE NOT NULL,
    gender NCHAR(1) NOT NULL CONSTRAINT CHK_Gender CHECK (gender IN (N'М', N'Ж'))
);
GO

 --Создание таблицы "Отделы"
CREATE TABLE dbo.Departments (
    department_id INT IDENTITY(1,1) PRIMARY KEY,
    department_name NVARCHAR(100) NOT NULL
);
GO

 --Создание таблицы "Должности"
CREATE TABLE dbo.Positions (
    position_id INT IDENTITY(1,1) PRIMARY KEY,
    position_title NVARCHAR(100) NOT NULL,
    benefits NVARCHAR(MAX),
    qualifications NVARCHAR(MAX)
);
GO

 --Создание таблицы "Назначения"
CREATE TABLE dbo.Appointments (
    appointment_id INT IDENTITY(1,1) PRIMARY KEY,
    employee_id INT NOT NULL,
    department_id INT NOT NULL,
    position_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    contract_term_days INT,
    CONSTRAINT FK_Appointments_Employees FOREIGN KEY (employee_id) REFERENCES dbo.Employees(employee_id),
    CONSTRAINT FK_Appointments_Departments FOREIGN KEY (department_id) REFERENCES dbo.Departments(department_id),
    CONSTRAINT FK_Appointments_Positions FOREIGN KEY (position_id) REFERENCES dbo.Positions(position_id));