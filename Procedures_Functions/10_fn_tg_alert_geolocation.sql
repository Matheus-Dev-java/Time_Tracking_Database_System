-- Creates the trigger function that audits punches made outside the work location radius.
CREATE OR REPLACE FUNCTION fn_tg_alert_geolocation()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
          FROM employee e
          JOIN work_location l ON l.work_location_id = e.work_location_id
         WHERE e.employee_id = NEW.employee_id
           AND fn_distance_meters(NEW.latitude, NEW.longitude, l.latitude, l.longitude) > l.radius_meters
    ) AND NOT EXISTS (
        SELECT 1
          FROM punch_audit
         WHERE time_punch_id = NEW.time_punch_id
           AND alert_type = 'geolocation_divergence'
    ) THEN
        INSERT INTO punch_audit (time_punch_id, employee_id, alert_type, description)
        VALUES (NEW.time_punch_id, NEW.employee_id, 'geolocation_divergence',
                'Coordinates outside the allowed radius of the work location');
    END IF;

    RETURN NEW;
END;
$$;
