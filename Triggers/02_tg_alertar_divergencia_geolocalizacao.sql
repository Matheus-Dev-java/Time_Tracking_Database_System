-- Creates the trigger that audits punches outside the work location radius.
CREATE TRIGGER tg_alertar_divergencia_geolocalizacao
AFTER INSERT OR UPDATE ON time_punch
FOR EACH ROW
EXECUTE FUNCTION fn_tg_alert_geolocation();
