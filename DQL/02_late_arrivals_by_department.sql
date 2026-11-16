-- Late arrivals and late minutes per department in the reference month.
WITH reference_period AS (
    SELECT DATE '2026-10-19' AS start_date, DATE '2026-10-31' AS end_date
)
SELECT er.trade_name AS employer,
       d.department_id,
       d.name AS department,
       COUNT(*) AS late_arrivals,
       SUM(s.late_minutes) AS late_minutes
  FROM daily_summary s
  JOIN reference_period rp ON s.work_date BETWEEN rp.start_date AND rp.end_date
  JOIN employee e ON e.employee_id = s.employee_id
  JOIN department d ON d.department_id = e.department_id
  JOIN employer er ON er.employer_id = d.employer_id
 WHERE s.late_minutes > 0
 GROUP BY er.trade_name, d.department_id, d.name
 ORDER BY late_arrivals DESC, d.department_id;
