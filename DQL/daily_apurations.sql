-- =============================================================================
-- DQL: daily_apurations
-- Queries for retrieving daily work hour summaries
-- =============================================================================

-- Mirror of point (Espelho de Ponto) for a specific employee and period
SELECT
    da.date,
    da.day_status,
    da.hours_expected  AS expected_min,
    da.hours_worked    AS worked_min,
    da.overtime_50     AS overtime_50_min,
    da.overtime_100    AS overtime_100_min,
    da.hours_absence   AS absence_min,
    da.night_hours     AS night_min
FROM daily_apurations da
WHERE da.employee_id = :employee_id
  AND da.apuration_period_id = :period_id
ORDER BY da.date;

-- Summary totals for an employee in a period (for payroll)
SELECT
    e.name AS employee_name,
    SUM(da.hours_worked)    AS total_worked_min,
    SUM(da.overtime_50)     AS total_overtime_50_min,
    SUM(da.overtime_100)    AS total_overtime_100_min,
    SUM(da.hours_absence)   AS total_absence_min,
    SUM(da.night_hours)     AS total_night_min
FROM daily_apurations da
INNER JOIN employees e ON e.id = da.employee_id
WHERE da.employee_id = :employee_id
  AND da.apuration_period_id = :period_id
GROUP BY e.name;

-- Employees with absences in a period
SELECT
    e.name AS employee_name,
    da.date,
    da.day_status
FROM daily_apurations da
INNER JOIN employees e ON e.id = da.employee_id
WHERE da.apuration_period_id = :period_id
  AND da.day_status IN ('ABSENCE', 'JUSTIFIED')
ORDER BY e.name, da.date;
