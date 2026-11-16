-- Employees who punched on more than one device.
SELECT e.employee_id,
       e.name AS employee_name,
       COUNT(DISTINCT p.device_id) AS devices_used,
       string_agg(DISTINCT d.serial_number || ' (' || dt.name || ')', ', ') AS devices
  FROM time_punch p
  JOIN employee e ON e.employee_id = p.employee_id
  JOIN device d ON d.device_id = p.device_id
  JOIN device_type dt ON dt.device_type_id = d.device_type_id
 GROUP BY e.employee_id, e.name
HAVING COUNT(DISTINCT p.device_id) > 1
 ORDER BY devices_used DESC, e.employee_id;
