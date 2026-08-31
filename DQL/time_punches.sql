-- =============================================================================
-- DQL: time_punches
-- Queries for retrieving clock punch records
-- =============================================================================

-- List all punches for a specific employee on a given date
SELECT
    tp.id,
    e.name AS employee_name,
    tp.punched_at,
    cd.model_name AS device
FROM time_punches tp
INNER JOIN employees e ON e.id = tp.employee_id
INNER JOIN clock_devices cd ON cd.id = tp.device_id
WHERE tp.employee_id = :employee_id
  AND DATE(tp.punched_at) = :date
ORDER BY tp.punched_at;

-- List all punches for a department on a given day
SELECT
    e.name AS employee_name,
    tp.punched_at,
    cd.model_name AS device
FROM time_punches tp
INNER JOIN employees e ON e.id = tp.employee_id
INNER JOIN departments d ON d.id = e.department_id
INNER JOIN clock_devices cd ON cd.id = tp.device_id
WHERE d.id = :department_id
  AND DATE(tp.punched_at) = :date
ORDER BY e.name, tp.punched_at;

-- Count punches per employee in a date range
SELECT
    e.id,
    e.name AS employee_name,
    COUNT(tp.id) AS total_punches
FROM time_punches tp
INNER JOIN employees e ON e.id = tp.employee_id
WHERE tp.punched_at BETWEEN :start_date AND :end_date
GROUP BY e.id, e.name
ORDER BY total_punches DESC;
