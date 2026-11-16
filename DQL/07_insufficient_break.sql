-- Days with a break shorter than one hour or without break punches, per employee.
WITH reference_period AS (
    SELECT DATE '2026-10-19' AS start_date, DATE '2026-10-31' AS end_date
)
SELECT e.employee_id,
       e.name AS employee_name,
       COUNT(*) AS days_with_insufficient_break,
       MIN(s.work_date) AS first_day,
       MAX(s.work_date) AS last_day
  FROM daily_summary s
  JOIN employee e ON e.employee_id = s.employee_id
  JOIN reference_period rp ON s.work_date BETWEEN rp.start_date AND rp.end_date
 WHERE s.insufficient_break
 GROUP BY e.employee_id, e.name
 ORDER BY days_with_insufficient_break DESC, e.employee_id;
