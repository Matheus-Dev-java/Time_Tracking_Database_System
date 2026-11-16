-- Creates the monthly timesheet closing, summing the daily summary of a finished month.
CREATE OR REPLACE PROCEDURE sp_fechar_espelho_ponto_mensal(
    p_employee_id integer,
    p_year integer,
    p_month integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_date date;
    v_end_date date;
    v_current_status varchar;
    v_days integer;
    v_worked integer;
    v_overtime integer;
    v_night integer;
    v_absence integer;
BEGIN
    IF p_year IS NULL OR p_month IS NULL OR p_month NOT BETWEEN 1 AND 12 THEN
        RAISE EXCEPTION 'Invalid year or month';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM employee WHERE employee_id = p_employee_id) THEN
        RAISE EXCEPTION 'Employee not found';
    END IF;

    v_start_date := make_date(p_year, p_month, 1);
    v_end_date := (v_start_date + INTERVAL '1 month')::date - 1;

    IF v_end_date >= CURRENT_DATE THEN
        RAISE EXCEPTION 'The month has not ended yet';
    END IF;

    SELECT s.name
      INTO v_current_status
      FROM timesheet t
      JOIN timesheet_status s ON s.timesheet_status_id = t.timesheet_status_id
     WHERE t.employee_id = p_employee_id
       AND t.start_date = v_start_date;

    IF v_current_status = 'Closed' THEN
        RAISE EXCEPTION 'The timesheet for the period is already closed';
    END IF;

    SELECT COUNT(*),
           COALESCE(SUM(worked_minutes), 0),
           COALESCE(SUM(overtime_minutes), 0),
           COALESCE(SUM(night_minutes), 0),
           COALESCE(SUM(CASE WHEN absent THEN scheduled_minutes ELSE 0 END), 0)
      INTO v_days, v_worked, v_overtime, v_night, v_absence
      FROM daily_summary
     WHERE employee_id = p_employee_id
       AND work_date BETWEEN v_start_date AND v_end_date;

    IF v_days = 0 THEN
        RAISE EXCEPTION 'No daily summary found for the period';
    END IF;

    INSERT INTO timesheet (
        employee_id, timesheet_status_id, start_date, end_date, worked_minutes, overtime_minutes,
        night_minutes, absence_minutes, legal_deadline, closed_at, signed_at
    ) VALUES (
        p_employee_id,
        (SELECT timesheet_status_id FROM timesheet_status WHERE name = 'Closed'),
        v_start_date, v_end_date, v_worked, v_overtime, v_night, v_absence,
        (v_start_date + INTERVAL '1 month 4 days')::date,
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    )
    ON CONFLICT (employee_id, start_date) DO UPDATE
       SET timesheet_status_id = EXCLUDED.timesheet_status_id,
           worked_minutes = EXCLUDED.worked_minutes,
           overtime_minutes = EXCLUDED.overtime_minutes,
           night_minutes = EXCLUDED.night_minutes,
           absence_minutes = EXCLUDED.absence_minutes,
           legal_deadline = EXCLUDED.legal_deadline,
           closed_at = EXCLUDED.closed_at,
           signed_at = EXCLUDED.signed_at;
END;
$$;
