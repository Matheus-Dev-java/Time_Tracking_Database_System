-- Timesheets closed after the legal deadline.
SELECT er.employer_id,
       er.trade_name AS employer,
       e.employee_id,
       e.name AS employee_name,
       t.legal_deadline,
       t.closed_at,
       t.closed_at::date - t.legal_deadline AS days_late
  FROM timesheet t
  JOIN employee e ON e.employee_id = t.employee_id
  JOIN employer er ON er.employer_id = e.employer_id
 WHERE t.closed_at::date > t.legal_deadline
 ORDER BY er.employer_id, e.employee_id;
