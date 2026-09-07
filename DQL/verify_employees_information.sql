SELECT 
    e.id AS matricula,
    e.name AS funcionario,
    e.id_document AS documento,
    d.name AS departamento,
    b.name AS filial,
    c.name AS empresa
FROM employees e
INNER JOIN departments d ON d.id = e.department_id
INNER JOIN branches b    ON b.id = d.branch_id
INNER JOIN companies c   ON c.id = b.company_id
ORDER BY c.name, b.name, e.name;