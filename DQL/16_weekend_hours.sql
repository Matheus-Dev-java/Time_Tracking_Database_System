-- Hours worked on Saturdays and Sundays per employee in the reference month.
WITH reference_period AS (
    SELECT DATE '2026-10-19' AS start_date, DATE '2026-10-31' AS end_date
)
SELECT e.employee_id,
       e.name AS employee_name,
       ROUND((SUM(s.worked_minutes) / 60.0)::numeric, 2) AS weekend_hours
  FROM daily_summary s
  JOIN employee e ON e.employee_id = s.employee_id
  JOIN reference_period rp ON s.work_date BETWEEN rp.start_date AND rp.end_date
 WHERE EXTRACT(DOW FROM s.work_date) IN (0, 6)
 GROUP BY e.employee_id, e.name
HAVING SUM(s.worked_minutes) > 0
 ORDER BY weekend_hours DESC, e.employee_id;
