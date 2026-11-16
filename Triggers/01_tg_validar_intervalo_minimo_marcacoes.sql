-- Creates the trigger that blocks punches less than 5 minutes apart.
CREATE TRIGGER tg_validar_intervalo_minimo_marcacoes
BEFORE INSERT OR UPDATE ON time_punch
FOR EACH ROW
EXECUTE FUNCTION fn_tg_validate_min_interval();
