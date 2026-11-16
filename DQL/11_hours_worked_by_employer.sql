-- Hours worked per employer in the reference month.
WITH reference_period AS (
    SELECT DATE '2026-10-19' AS start_date, DATE '2026-10-31' AS end_date
)
SELECT er.employer_id,
       er.cnpj,
       er.trade_name AS employer,
       ROUND((SUM(s.worked_minutes) / 60.0)::numeric, 2) AS worked_hours
  FROM daily_summary s
  JOIN reference_period rp ON s.work_date BETWEEN rp.start_date AND rp.end_date
  JOIN employee e ON e.employee_id = s.employee_id
  JOIN employer er ON er.employer_id = e.employer_id
 GROUP BY er.employer_id, er.cnpj, er.trade_name
 ORDER BY worked_hours DESC, er.employer_id;
