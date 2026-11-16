-- Creates the work schedule in force for each active employee, with working hours and days off.
CREATE OR REPLACE VIEW vw_escalas_jornadas_vigentes AS
SELECT e.employee_id,
       e.name AS employee_name,
       s.work_schedule_id,
       s.name AS schedule_name,
       s.daily_minutes,
       MIN(d.entry_time) AS entry_time,
       MIN(d.break_start_time) AS break_start_time,
       MIN(d.break_end_time) AS break_end_time,
       MAX(d.exit_time) AS exit_time,
       string_agg(
           (ARRAY['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'])[d.weekday + 1],
           ', ' ORDER BY d.weekday
       ) FILTER (WHERE d.day_off) AS days_off
  FROM employee e
  JOIN employee_schedule_history h ON h.employee_id = e.employee_id
                                  AND h.start_date <= CURRENT_DATE
                                  AND (h.end_date IS NULL OR h.end_date >= CURRENT_DATE)
  JOIN work_schedule s ON s.work_schedule_id = h.work_schedule_id
  JOIN work_schedule_day d ON d.work_schedule_id = s.work_schedule_id
 WHERE e.active
 GROUP BY e.employee_id, e.name, s.work_schedule_id, s.name, s.daily_minutes;
