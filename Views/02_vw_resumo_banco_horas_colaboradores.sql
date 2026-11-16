-- Creates the hour bank balance of active employees by department.
CREATE OR REPLACE VIEW vw_resumo_banco_horas_colaboradores AS
SELECT d.department_id,
       d.name AS department,
       e.employee_id,
       e.name AS employee_name,
       b.balance_minutes,
       ROUND((b.balance_minutes / 60.0)::numeric, 2) AS balance_hours,
       b.updated_at,
       b.expires_at
  FROM hour_bank b
  JOIN employee e ON e.employee_id = b.employee_id
  JOIN department d ON d.department_id = e.department_id
 WHERE e.active;
