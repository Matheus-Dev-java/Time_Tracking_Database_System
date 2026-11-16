-- Creates the trigger function that refreshes the hour bank for the changed summary day.
CREATE OR REPLACE FUNCTION fn_tg_update_hour_bank()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    CALL sp_recalcular_banco_horas(NEW.employee_id, NEW.work_date, NEW.work_date);

    RETURN NEW;
END;
$$;
