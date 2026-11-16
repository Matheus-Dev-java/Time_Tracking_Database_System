-- Creates the trigger that refreshes the hour bank when a daily summary changes.
CREATE TRIGGER tg_atualizar_banco_horas_diario
AFTER INSERT OR UPDATE ON daily_summary
FOR EACH ROW
EXECUTE FUNCTION fn_tg_update_hour_bank();
