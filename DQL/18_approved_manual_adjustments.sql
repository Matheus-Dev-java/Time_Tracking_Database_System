-- Approved manual punch adjustments.
SELECT e.employee_id,
       e.name AS employee_name,
       a.adjustment_date,
       t.name AS adjustment_type,
       a.reference_at,
       a.reason
  FROM punch_adjustment a
  JOIN employee e ON e.employee_id = a.employee_id
  JOIN adjustment_type t ON t.adjustment_type_id = a.adjustment_type_id
  JOIN record_status s ON s.record_status_id = a.record_status_id
 WHERE s.name = 'Approved'
 ORDER BY e.employee_id, a.adjustment_date;
