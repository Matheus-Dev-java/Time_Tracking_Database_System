-- =============================================================================
-- DQL: branches
-- Queries for retrieving branch data
-- =============================================================================

-- List all branches with their company name
SELECT
    b.id,
    b.name AS branch_name,
    c.name AS company_name,
    c.cnpj AS company_cnpj
FROM branches b
INNER JOIN companies c ON c.id = b.company_id
ORDER BY c.name, b.name;

-- Find a branch by ID
SELECT
    b.id,
    b.name,
    c.name AS company_name
FROM branches b
INNER JOIN companies c ON c.id = b.company_id
WHERE b.id = :branch_id;

-- Count departments per branch
SELECT
    b.id,
    b.name AS branch_name,
    COUNT(d.id) AS total_departments
FROM branches b
LEFT JOIN departments d ON d.branch_id = b.id
GROUP BY b.id, b.name
ORDER BY total_departments DESC;
