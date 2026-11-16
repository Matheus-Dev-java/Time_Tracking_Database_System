-- Punches registered outside the radius of the employee work location.
SELECT e.employee_id,
       e.name AS employee_name,
       l.name AS work_location,
       p.punched_at,
       p.latitude,
       p.longitude,
       fn_distance_meters(p.latitude, p.longitude, l.latitude, l.longitude) AS distance_meters
  FROM time_punch p
  JOIN employee e ON e.employee_id = p.employee_id
  JOIN work_location l ON l.work_location_id = e.work_location_id
 WHERE p.outside_perimeter
 ORDER BY e.employee_id, p.punched_at;
