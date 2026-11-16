-- Creates the trigger that blocks punch changes in a closed and signed timesheet.
CREATE TRIGGER tg_bloquear_alteracao_espelho_fechado
BEFORE INSERT OR UPDATE OR DELETE ON time_punch
FOR EACH ROW
EXECUTE FUNCTION fn_tg_block_closed_timesheet();
