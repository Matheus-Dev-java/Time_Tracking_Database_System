-- Creates the trigger that audits waiver inserts and updates.
CREATE TRIGGER tg_auditoria_justificativas_abono
AFTER INSERT OR UPDATE ON absence_waiver
FOR EACH ROW
EXECUTE FUNCTION fn_tg_audit_waiver();
