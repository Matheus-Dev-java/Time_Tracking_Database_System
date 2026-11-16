-- Creates the trigger function that audits waiver inserts and updates with the responsible user.
CREATE OR REPLACE FUNCTION fn_tg_audit_waiver()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO waiver_audit (absence_waiver_id, employee_id, operation, responsible_user, audited_at, detail)
    VALUES (NEW.absence_waiver_id, NEW.employee_id, lower(TG_OP), NEW.responsible_user, CURRENT_TIMESTAMP, NEW.description);

    RETURN NEW;
END;
$$;
