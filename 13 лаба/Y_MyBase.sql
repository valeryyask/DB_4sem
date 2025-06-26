-- 1. ���������: ��������� ����������� �� ������
CREATE OR ALTER PROCEDURE GetEmployeesByDepartment
    @department_name NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        e.employee_id,
        e.last_name,
        e.first_name,
        e.middle_name,
        e.birth_date,
        e.gender,
        d.department_name,
        p.position_title,
        a.appointment_date,
        a.contract_term_days
    FROM dbo.Appointments a
    JOIN dbo.Employees e ON a.employee_id = e.employee_id
    JOIN dbo.Departments d ON a.department_id = d.department_id
    JOIN dbo.Positions p ON a.position_id = p.position_id
    WHERE d.department_name = @department_name
    ORDER BY e.last_name, e.first_name;
END;
GO

-- 2. ���������: ����� �� ���������� ����������� � �������
CREATE OR ALTER PROCEDURE DepartmentEmployeeReport
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        d.department_name,
        COUNT(a.employee_id) AS employee_count
    FROM dbo.Departments d
    LEFT JOIN dbo.Appointments a ON d.department_id = a.department_id
    GROUP BY d.department_name
    ORDER BY employee_count DESC;
END;
GO

-- 3. ���������: ���������� ���������� � ���������� � �����
CREATE OR ALTER PROCEDURE AddEmployeeAndAssign
    @last_name NVARCHAR(50),
    @first_name NVARCHAR(50),
    @middle_name NVARCHAR(50) = NULL,
    @birth_date DATE,
    @gender NCHAR(1),
    @department_id INT,
    @position_id INT,
    @appointment_date DATE,
    @contract_term_days INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @new_employee_id INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.Employees (
            last_name, first_name, middle_name, birth_date, gender
        )
        VALUES (
            @last_name, @first_name, @middle_name, @birth_date, @gender
        );

        SET @new_employee_id = SCOPE_IDENTITY();

        INSERT INTO dbo.Appointments (
            employee_id, department_id, position_id, appointment_date, contract_term_days
        )
        VALUES (
            @new_employee_id, @department_id, @position_id, @appointment_date, @contract_term_days
        );

        COMMIT;

        -- ����� ���������� � ����� ����������
        SELECT 
            e.employee_id,
            e.last_name,
            e.first_name,
            e.middle_name,
            e.birth_date,
            e.gender,
            d.department_name,
            p.position_title,
            a.appointment_date,
            a.contract_term_days
        FROM dbo.Employees e
        JOIN dbo.Appointments a ON e.employee_id = a.employee_id
        JOIN dbo.Departments d ON a.department_id = d.department_id
        JOIN dbo.Positions p ON a.position_id = p.position_id
        WHERE e.employee_id = @new_employee_id;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        PRINT '������: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- 4. ������� �������
EXEC GetEmployeesByDepartment @department_name = N'�����������';
GO

EXEC DepartmentEmployeeReport;
GO

EXEC AddEmployeeAndAssign 
    @last_name = N'������',
    @first_name = N'����',
    @middle_name = N'��������',
    @birth_date = '1990-01-01',
	@gender = N'�',
    @department_id = 1,
    @position_id = 2,
    @contract_term_days = 365,
	@appointment_date = '2025-05-25';
GO
