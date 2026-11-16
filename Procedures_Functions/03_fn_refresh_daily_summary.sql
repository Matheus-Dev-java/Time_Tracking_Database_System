-- Creates the upsert of one employee's daily summary from that day's punches and schedule.
CREATE OR REPLACE FUNCTION fn_refresh_daily_summary(p_employee_id integer, p_work_date date)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_daily_minutes integer;
    v_tolerance integer;
    v_day_off boolean;
    v_entry_time time;
    v_clock_in timestamp;
    v_break_start timestamp;
    v_break_end timestamp;
    v_clock_out timestamp;
    v_break integer;
    v_worked integer;
BEGIN
    SELECT s.daily_minutes, s.tolerance_minutes, d.day_off, d.entry_time
      INTO v_daily_minutes, v_tolerance, v_day_off, v_entry_time
      FROM employee e
      JOIN employee_schedule_history h ON h.employee_id = e.employee_id
                                      AND p_work_date BETWEEN h.start_date AND COALESCE(h.end_date, 'infinity')
      JOIN work_schedule s ON s.work_schedule_id = h.work_schedule_id
      JOIN work_schedule_day d ON d.work_schedule_id = s.work_schedule_id
                              AND d.weekday = EXTRACT(DOW FROM p_work_date)
     WHERE e.employee_id = p_employee_id
       AND p_work_date >= e.hire_date
       AND (e.termination_date IS NULL OR p_work_date <= e.termination_date);

    IF NOT FOUND THEN
        RETURN;
    END IF;

    SELECT MIN(p.punched_at) FILTER (WHERE t.name = 'Clock In'),
           MIN(p.punched_at) FILTER (WHERE t.name = 'Break Start'),
           MIN(p.punched_at) FILTER (WHERE t.name = 'Break End'),
           MAX(p.punched_at) FILTER (WHERE t.name = 'Clock Out')
      INTO v_clock_in, v_break_start, v_break_end, v_clock_out
      FROM time_punch p
      JOIN punch_type t ON t.punch_type_id = p.punch_type_id
     WHERE p.employee_id = p_employee_id
       AND p.punched_at >= p_work_date
       AND p.punched_at < p_work_date + 1;

    IF v_day_off AND v_clock_in IS NULL AND v_break_start IS NULL AND v_break_end IS NULL AND v_clock_out IS NULL THEN
        RETURN;
    END IF;

    v_break := COALESCE(EXTRACT(EPOCH FROM (v_break_end - v_break_start))::integer / 60, 0);
    v_worked := CASE
                    WHEN v_clock_in IS NOT NULL AND v_clock_out IS NOT NULL
                        THEN EXTRACT(EPOCH FROM (v_clock_out - v_clock_in))::integer / 60 - v_break
                    ELSE 0
                END;

    INSERT INTO daily_summary (
        employee_id, work_date, scheduled_minutes, worked_minutes, overtime_minutes, late_minutes,
        night_minutes, insufficient_break, missing_clock_out, absent, worked_on_day_off
    ) VALUES (
        p_employee_id,
        p_work_date,
        CASE WHEN v_day_off THEN 0 ELSE v_daily_minutes END,
        v_worked,
        CASE WHEN v_day_off THEN v_worked ELSE GREATEST(0, v_worked - v_daily_minutes) END,
        GREATEST(0, EXTRACT(EPOCH FROM (v_clock_in - (p_work_date + v_entry_time)))::integer / 60 - v_tolerance),
        fn_night_minutes(v_clock_in, COALESCE(v_break_start, v_clock_out)) + fn_night_minutes(v_break_end, v_clock_out),
        v_clock_in IS NOT NULL AND v_clock_out IS NOT NULL
            AND (v_break_start IS NULL OR v_break_end IS NULL OR v_break < 60),
        v_clock_in IS NOT NULL AND v_clock_out IS NULL,
        v_clock_in IS NULL AND v_break_start IS NULL AND v_break_end IS NULL AND v_clock_out IS NULL,
        v_day_off
    )
    ON CONFLICT (employee_id, work_date) DO UPDATE
       SET scheduled_minutes = EXCLUDED.scheduled_minutes,
           worked_minutes = EXCLUDED.worked_minutes,
           overtime_minutes = EXCLUDED.overtime_minutes,
           late_minutes = EXCLUDED.late_minutes,
           night_minutes = EXCLUDED.night_minutes,
           insufficient_break = EXCLUDED.insufficient_break,
           missing_clock_out = EXCLUDED.missing_clock_out,
           absent = EXCLUDED.absent,
           worked_on_day_off = EXCLUDED.worked_on_day_off;
END;
$$;
