-- =============================================================================
-- DQL: employees
-- Queries for retrieving employee data
-- =============================================================================

-- List all employees with department and branch info
SELECT
    e.id,
    e.name AS employee_name,
    e.id_document,
    e.birth_date,
    d.name AS department_name,
    b.name AS branch_name
FROM employees e
INNER JOIN departments d ON d.id = e.department_id
INNER JOIN branches b ON b.id = d.branch_id
ORDER BY e.name;

-- Find employee by ID document (CPF/RG/CNH)
SELECT
    e.id,
    e.name,
    e.id_document,
    d.name AS department_name
FROM employees e
INNER JOIN departments d ON d.id = e.department_id
WHERE e.id_document = :id_document;

-- List employees from a specific department
SELECT
    e.id,
    e.name,
    e.birth_date
FROM employees e
WHERE e.department_id = :department_id
ORDER BY e.name;

-- Count employees per department and branch
SELECT
    b.name AS branch_name,
    d.name AS department_name,
    COUNT(e.id) AS total_employees
FROM employees e
INNER JOIN departments d ON d.id = e.department_id
INNER JOIN branches b ON b.id = d.branch_id
GROUP BY b.name, d.name
ORDER BY b.name, total_employees DESC;
