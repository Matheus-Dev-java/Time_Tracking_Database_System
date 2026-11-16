-- Creates the trigger function that blocks punch changes inside a closed and signed timesheet.
CREATE OR REPLACE FUNCTION fn_tg_block_closed_timesheet()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_employee_id integer;
    v_date date;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_employee_id := OLD.employee_id;
        v_date := OLD.punched_at::date;
    ELSE
        v_employee_id := NEW.employee_id;
        v_date := NEW.punched_at::date;
    END IF;

    IF EXISTS (
        SELECT 1
          FROM timesheet t
          JOIN timesheet_status s ON s.timesheet_status_id = t.timesheet_status_id
         WHERE t.employee_id = v_employee_id
           AND s.name = 'Closed'
           AND t.signed_at IS NOT NULL
           AND v_date BETWEEN t.start_date AND t.end_date
    ) THEN
        RAISE EXCEPTION 'Timesheet is closed and signed';
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$;
