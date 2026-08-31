-- =============================================================================
-- DQL: departments
-- Queries for retrieving department data
-- =============================================================================

-- List all departments with branch and company info
SELECT
    d.id,
    d.name AS department_name,
    b.name AS branch_name,
    c.name AS company_name
FROM departments d
INNER JOIN branches b ON b.id = d.branch_id
INNER JOIN companies c ON c.id = b.company_id
ORDER BY c.name, b.name, d.name;

-- Count employees per department
SELECT
    d.id,
    d.name AS department_name,
    b.name AS branch_name,
    COUNT(e.id) AS total_employees
FROM departments d
INNER JOIN branches b ON b.id = d.branch_id
LEFT JOIN employees e ON e.department_id = d.id
GROUP BY d.id, d.name, b.name
ORDER BY total_employees DESC;

-- Find all departments within a specific branch
SELECT
    d.id,
    d.name
FROM departments d
WHERE d.branch_id = :branch_id
ORDER BY d.name;
