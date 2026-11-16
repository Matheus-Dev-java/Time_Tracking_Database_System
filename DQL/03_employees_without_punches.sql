-- Employees with no punch on a scheduled workday of the reference month.
WITH reference_period AS (
    SELECT DATE '2026-10-19' AS start_date, DATE '2026-10-31' AS end_date
),
expected_days AS (
    SELECT e.employee_id,
           e.name AS employee_name,
           d::date AS work_date
      FROM reference_period rp
     CROSS JOIN generate_series(rp.start_date::timestamp, rp.end_date::timestamp, INTERVAL '1 day') AS d
      JOIN employee e ON e.hire_date <= d::date
                     AND (e.termination_date IS NULL OR e.termination_date >= d::date)
      JOIN employee_schedule_history h ON h.employee_id = e.employee_id
                                      AND d::date BETWEEN h.start_date AND COALESCE(h.end_date, 'infinity')
      JOIN work_schedule_day wd ON wd.work_schedule_id = h.work_schedule_id
                               AND wd.weekday = EXTRACT(DOW FROM d)
                               AND NOT wd.day_off
)
SELECT x.employee_id,
       x.employee_name,
       x.work_date
  FROM expected_days x
 WHERE NOT EXISTS (
           SELECT 1
             FROM time_punch p
            WHERE p.employee_id = x.employee_id
              AND p.punched_at >= x.work_date
              AND p.punched_at < x.work_date + 1
       )
 ORDER BY x.employee_id, x.work_date;
