-- Average clock-in deviation from the scheduled entry time, in minutes, per employee.
WITH reference_period AS (
    SELECT DATE '2026-10-19' AS start_date, DATE '2026-10-31' AS end_date
)
SELECT e.employee_id,
       e.name AS employee_name,
       COUNT(*) AS clock_ins,
       ROUND(AVG(EXTRACT(EPOCH FROM (p.punched_at - (p.punched_at::date + wd.entry_time))) / 60.0)::numeric, 2) AS average_deviation_minutes
  FROM time_punch p
  JOIN punch_type t ON t.punch_type_id = p.punch_type_id AND t.name = 'Clock In'
  JOIN reference_period rp ON p.punched_at::date BETWEEN rp.start_date AND rp.end_date
  JOIN employee e ON e.employee_id = p.employee_id
  JOIN employee_schedule_history h ON h.employee_id = e.employee_id
                                  AND p.punched_at::date BETWEEN h.start_date AND COALESCE(h.end_date, 'infinity')
  JOIN work_schedule_day wd ON wd.work_schedule_id = h.work_schedule_id
                           AND wd.weekday = EXTRACT(DOW FROM p.punched_at)
                           AND NOT wd.day_off
 GROUP BY e.employee_id, e.name
 ORDER BY average_deviation_minutes DESC, e.employee_id;
