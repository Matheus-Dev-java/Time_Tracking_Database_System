-- Creates the trigger function that rejects punches less than 5 minutes apart.
CREATE OR REPLACE FUNCTION fn_tg_validate_min_interval()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
          FROM time_punch p
         WHERE p.employee_id = NEW.employee_id
           AND p.time_punch_id IS DISTINCT FROM NEW.time_punch_id
           AND p.punched_at > NEW.punched_at - INTERVAL '5 minutes'
           AND p.punched_at < NEW.punched_at + INTERVAL '5 minutes'
    ) THEN
        RAISE EXCEPTION 'Minimum interval of 5 minutes between punches';
    END IF;

    RETURN NEW;
END;
$$;
