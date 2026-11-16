-- Creates the punch inconsistencies: audit alerts, odd punch counts and insufficient breaks.
CREATE OR REPLACE VIEW vw_relatorio_inconsistencias_ponto AS
SELECT e.employee_id,
       e.name AS employee_name,
       p.punched_at::date AS work_date,
       a.alert_type AS inconsistency_type
  FROM punch_audit a
  JOIN time_punch p ON p.time_punch_id = a.time_punch_id
  JOIN employee e ON e.employee_id = a.employee_id
UNION ALL
SELECT e.employee_id,
       e.name,
       p.punched_at::date,
       'odd_punch_count'
  FROM time_punch p
  JOIN employee e ON e.employee_id = p.employee_id
 GROUP BY e.employee_id, e.name, p.punched_at::date
HAVING COUNT(*) % 2 = 1
UNION ALL
SELECT e.employee_id,
       e.name,
       s.work_date,
       'insufficient_break'
  FROM daily_summary s
  JOIN employee e ON e.employee_id = s.employee_id
 WHERE s.insufficient_break;
