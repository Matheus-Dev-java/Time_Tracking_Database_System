-- Average monthly overtime hours per employee, grouped by job title.
WITH reference_period AS (
    SELECT DATE '2026-10-19' AS start_date, DATE '2026-10-31' AS end_date
),
employee_overtime AS (
    SELECT e.job_title_id,
           e.employee_id,
           SUM(s.overtime_minutes) / 60.0 AS overtime_hours
      FROM employee e
      JOIN daily_summary s ON s.employee_id = e.employee_id
      JOIN reference_period rp ON s.work_date BETWEEN rp.start_date AND rp.end_date
     GROUP BY e.job_title_id, e.employee_id
)
SELECT j.job_title_id,
       j.name AS job_title,
       COUNT(*) AS employees,
       ROUND(AVG(o.overtime_hours)::numeric, 2) AS average_overtime_hours
  FROM employee_overtime o
  JOIN job_title j ON j.job_title_id = o.job_title_id
 GROUP BY j.job_title_id, j.name
 ORDER BY j.job_title_id;
