-- Creates the daily timesheet detail with punch times, lateness and overtime.
CREATE OR REPLACE VIEW vw_espelho_ponto_detalhado AS
WITH daily_punches AS (
    SELECT p.employee_id,
           p.punched_at::date AS work_date,
           MIN(p.punched_at) FILTER (WHERE t.name = 'Clock In') AS clock_in,
           MIN(p.punched_at) FILTER (WHERE t.name = 'Break Start') AS break_start,
           MIN(p.punched_at) FILTER (WHERE t.name = 'Break End') AS break_end,
           MAX(p.punched_at) FILTER (WHERE t.name = 'Clock Out') AS clock_out
      FROM time_punch p
      JOIN punch_type t ON t.punch_type_id = p.punch_type_id
     GROUP BY p.employee_id, p.punched_at::date
)
SELECT e.employee_id,
       e.name AS employee_name,
       to_char(s.work_date, 'YYYY-MM') AS year_month,
       s.work_date,
       dp.clock_in::time AS clock_in_time,
       dp.break_start::time AS break_start_time,
       dp.break_end::time AS break_end_time,
       dp.clock_out::time AS clock_out_time,
       s.worked_minutes,
       s.late_minutes,
       s.overtime_minutes
  FROM daily_summary s
  JOIN employee e ON e.employee_id = s.employee_id
  LEFT JOIN daily_punches dp ON dp.employee_id = s.employee_id
                            AND dp.work_date = s.work_date;
