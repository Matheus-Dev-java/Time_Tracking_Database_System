-- Overtime minutes and hours per employee in the reference month.
WITH reference_period AS (
    SELECT DATE '2026-10-19' AS start_date, DATE '2026-10-31' AS end_date
)
SELECT e.employee_id,
       e.name AS employee_name,
       SUM(s.overtime_minutes) AS overtime_minutes,
       ROUND((SUM(s.overtime_minutes) / 60.0)::numeric, 2) AS overtime_hours
  FROM daily_summary s
  JOIN employee e ON e.employee_id = s.employee_id
  JOIN reference_period rp ON s.work_date BETWEEN rp.start_date AND rp.end_date
 GROUP BY e.employee_id, e.name
HAVING SUM(s.overtime_minutes) > 0
 ORDER BY overtime_minutes DESC, e.employee_id;
