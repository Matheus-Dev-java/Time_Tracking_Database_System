-- Night work between 22:00 and 05:00 per employee in the reference month.
WITH reference_period AS (
    SELECT DATE '2026-10-19' AS start_date, DATE '2026-10-31' AS end_date
)
SELECT e.employee_id,
       e.name AS employee_name,
       COUNT(*) AS night_days,
       SUM(s.night_minutes) AS night_minutes,
       ROUND((SUM(s.night_minutes) / 60.0)::numeric, 2) AS night_hours
  FROM daily_summary s
  JOIN employee e ON e.employee_id = s.employee_id
  JOIN reference_period rp ON s.work_date BETWEEN rp.start_date AND rp.end_date
 WHERE s.night_minutes > 0
 GROUP BY e.employee_id, e.name
 ORDER BY night_minutes DESC, e.employee_id;
