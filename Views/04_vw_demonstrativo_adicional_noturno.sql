-- Creates the monthly night work statement, covering minutes between 22:00 and 05:00.
CREATE OR REPLACE VIEW vw_demonstrativo_adicional_noturno AS
SELECT e.employee_id,
       e.name AS employee_name,
       to_char(s.work_date, 'YYYY-MM') AS year_month,
       SUM(s.night_minutes) AS night_minutes,
       ROUND((SUM(s.night_minutes) / 60.0)::numeric, 2) AS night_hours
  FROM daily_summary s
  JOIN employee e ON e.employee_id = s.employee_id
 WHERE s.night_minutes > 0
 GROUP BY e.employee_id, e.name, to_char(s.work_date, 'YYYY-MM');
