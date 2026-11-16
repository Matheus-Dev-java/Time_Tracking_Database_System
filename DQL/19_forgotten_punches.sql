-- Days with clock-in but no clock-out, per employee in the reference month.
WITH reference_period AS (
    SELECT DATE '2026-10-19' AS start_date, DATE '2026-10-31' AS end_date
)
SELECT e.employee_id,
       e.name AS employee_name,
       COUNT(*) AS days_without_clock_out,
       string_agg(to_char(s.work_date, 'YYYY-MM-DD'), ', ' ORDER BY s.work_date) AS days
  FROM daily_summary s
  JOIN employee e ON e.employee_id = s.employee_id
  JOIN reference_period rp ON s.work_date BETWEEN rp.start_date AND rp.end_date
 WHERE s.missing_clock_out
 GROUP BY e.employee_id, e.name
 ORDER BY days_without_clock_out DESC, e.employee_id;
