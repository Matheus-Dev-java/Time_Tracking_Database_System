-- Creates the waiver of absences and lateness, adjusting the daily summary and open timesheets.
CREATE OR REPLACE PROCEDURE sp_abonar_falta_atraso(
    p_employee_id integer,
    p_start_date date,
    p_end_date date,
    p_waiver_type_id integer,
    p_document varchar,
    p_responsible_user varchar,
    p_description varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_waived_minutes integer;
BEGIN
    IF p_document IS NULL OR btrim(p_document) = '' THEN
        RAISE EXCEPTION 'Supporting document is required';
    END IF;

    IF p_responsible_user IS NULL OR btrim(p_responsible_user) = '' THEN
        RAISE EXCEPTION 'Responsible user is required';
    END IF;

    IF p_start_date IS NULL OR p_end_date IS NULL OR p_end_date < p_start_date THEN
        RAISE EXCEPTION 'Invalid waiver period';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM employee WHERE employee_id = p_employee_id AND active) THEN
        RAISE EXCEPTION 'Employee not found or inactive';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM waiver_type WHERE waiver_type_id = p_waiver_type_id) THEN
        RAISE EXCEPTION 'Invalid waiver type';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM timesheet t
          JOIN timesheet_status s ON s.timesheet_status_id = t.timesheet_status_id
         WHERE t.employee_id = p_employee_id
           AND s.name = 'Closed'
           AND t.signed_at IS NOT NULL
           AND t.start_date <= p_end_date
           AND t.end_date >= p_start_date
    ) THEN
        RAISE EXCEPTION 'Period is blocked by a closed and signed timesheet';
    END IF;

    SELECT COALESCE(SUM(CASE WHEN absent THEN scheduled_minutes ELSE late_minutes END), 0)
      INTO v_waived_minutes
      FROM daily_summary
     WHERE employee_id = p_employee_id
       AND work_date BETWEEN p_start_date AND p_end_date
       AND (absent OR late_minutes > 0);

    INSERT INTO absence_waiver (
        employee_id, waiver_type_id, record_status_id, start_date, end_date,
        document, waived_minutes, responsible_user, description
    ) VALUES (
        p_employee_id, p_waiver_type_id,
        (SELECT record_status_id FROM record_status WHERE name = 'Approved'),
        p_start_date, p_end_date, p_document, v_waived_minutes, p_responsible_user, p_description
    );

    UPDATE daily_summary
       SET scheduled_minutes = CASE WHEN absent THEN 0 ELSE scheduled_minutes - late_minutes END,
           absent = FALSE,
           late_minutes = 0
     WHERE employee_id = p_employee_id
       AND work_date BETWEEN p_start_date AND p_end_date
       AND (absent OR late_minutes > 0);

    UPDATE timesheet t
       SET (worked_minutes, overtime_minutes, night_minutes, absence_minutes) = (
           SELECT COALESCE(SUM(d.worked_minutes), 0),
                  COALESCE(SUM(d.overtime_minutes), 0),
                  COALESCE(SUM(d.night_minutes), 0),
                  COALESCE(SUM(CASE WHEN d.absent THEN d.scheduled_minutes ELSE 0 END), 0)
             FROM daily_summary d
            WHERE d.employee_id = t.employee_id
              AND d.work_date BETWEEN t.start_date AND t.end_date
       )
      FROM timesheet_status s
     WHERE s.timesheet_status_id = t.timesheet_status_id
       AND s.name <> 'Closed'
       AND t.employee_id = p_employee_id
       AND t.start_date <= p_end_date
       AND t.end_date >= p_start_date;
END;
$$;
