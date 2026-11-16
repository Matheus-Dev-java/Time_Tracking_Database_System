-- Payroll report from the closed timesheets of the reference month.
WITH reference_period AS (
    SELECT DATE '2026-10-01' AS start_date, DATE '2026-10-31' AS end_date
)
SELECT er.legal_name AS employer,
       er.cnpj,
       e.registration_number,
       e.cpf,
       e.pis,
       e.name AS employee_name,
       ROUND((t.worked_minutes / 60.0)::numeric, 2) AS worked_hours,
       ROUND((t.overtime_minutes / 60.0)::numeric, 2) AS overtime_hours,
       ROUND((t.night_minutes / 60.0)::numeric, 2) AS night_hours,
       ROUND((t.absence_minutes / 60.0)::numeric, 2) AS absence_hours
  FROM timesheet t
  JOIN timesheet_status s ON s.timesheet_status_id = t.timesheet_status_id AND s.name = 'Closed'
  JOIN reference_period rp ON t.start_date = rp.start_date AND t.end_date = rp.end_date
  JOIN employee e ON e.employee_id = t.employee_id
  JOIN employer er ON er.employer_id = e.employer_id
 ORDER BY er.employer_id, e.employee_id;
