-- Biometric failures per employee, with the devices involved and the reasons.
SELECT e.employee_id,
       e.name AS employee_name,
       COUNT(*) AS failures,
       MAX(f.failed_at) AS last_failure,
       string_agg(DISTINCT d.serial_number, ', ') AS devices,
       string_agg(DISTINCT f.reason, '; ') AS reasons
  FROM biometric_failure f
  JOIN employee e ON e.employee_id = f.employee_id
  JOIN device d ON d.device_id = f.device_id
 GROUP BY e.employee_id, e.name
 ORDER BY failures DESC, e.employee_id;
