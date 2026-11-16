-- Timesheets not yet closed, per employer and status.
SELECT er.employer_id,
       er.trade_name AS employer,
       s.name AS timesheet_status,
       COUNT(*) AS pending_timesheets
  FROM timesheet t
  JOIN timesheet_status s ON s.timesheet_status_id = t.timesheet_status_id
  JOIN employee e ON e.employee_id = t.employee_id
  JOIN employer er ON er.employer_id = e.employer_id
 WHERE s.name <> 'Closed'
 GROUP BY er.employer_id, er.trade_name, s.name
 ORDER BY er.employer_id, s.name;
