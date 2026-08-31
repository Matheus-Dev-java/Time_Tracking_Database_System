-- =============================================================================
-- DQL: companies
-- Queries for retrieving company data
-- =============================================================================

-- List all active companies
SELECT
    id,
    name,
    cnpj
FROM companies
ORDER BY name;

-- Find a company by CNPJ
SELECT
    id,
    name,
    cnpj
FROM companies
WHERE cnpj = :cnpj;

-- Count total branches per company
SELECT
    c.id,
    c.name AS company_name,
    COUNT(b.id) AS total_branches
FROM companies c
LEFT JOIN branches b ON b.company_id = c.id
GROUP BY c.id, c.name
ORDER BY total_branches DESC;
