-- Creates the punch registration with perimeter and network checks and daily summary refresh.
CREATE OR REPLACE PROCEDURE sp_registrar_marcacao_ponto(
    p_employee_id integer,
    p_device_id integer,
    p_punch_type_id integer,
    p_punched_at timestamp,
    p_latitude numeric,
    p_longitude numeric,
    p_ip_address inet
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_employer_id integer;
    v_active boolean;
    v_latitude numeric;
    v_longitude numeric;
    v_radius integer;
    v_network cidr;
    v_time_punch_id integer;
BEGIN
    SELECT e.employer_id, e.active, l.latitude, l.longitude, l.radius_meters, l.allowed_network
      INTO v_employer_id, v_active, v_latitude, v_longitude, v_radius, v_network
      FROM employee e
      JOIN work_location l ON l.work_location_id = e.work_location_id
     WHERE e.employee_id = p_employee_id;

    IF NOT FOUND OR v_active IS DISTINCT FROM TRUE THEN
        RAISE EXCEPTION 'Employee not found or inactive';
    END IF;

    IF p_punched_at IS NULL OR p_latitude IS NULL OR p_longitude IS NULL OR p_ip_address IS NULL THEN
        RAISE EXCEPTION 'Punch time, latitude, longitude and IP address are required';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM punch_type WHERE punch_type_id = p_punch_type_id) THEN
        RAISE EXCEPTION 'Invalid punch type';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM device
         WHERE device_id = p_device_id
           AND employer_id = v_employer_id
           AND active
    ) THEN
        RAISE EXCEPTION 'Device is not valid for the employer of the employee';
    END IF;

    INSERT INTO time_punch (
        employer_id, employee_id, device_id, punch_type_id, sequence_number, punched_at,
        latitude, longitude, ip_address, outside_perimeter
    ) VALUES (
        v_employer_id, p_employee_id, p_device_id, p_punch_type_id,
        (SELECT COALESCE(MAX(sequence_number), 0) + 1 FROM time_punch),
        p_punched_at, p_latitude, p_longitude, p_ip_address,
        fn_distance_meters(p_latitude, p_longitude, v_latitude, v_longitude) > v_radius
    )
    RETURNING time_punch_id INTO v_time_punch_id;

    IF NOT (p_ip_address <<= v_network) THEN
        INSERT INTO punch_audit (time_punch_id, employee_id, alert_type, description)
        VALUES (v_time_punch_id, p_employee_id, 'network_divergence',
                'IP address outside the allowed network of the work location');
    END IF;

    PERFORM fn_refresh_daily_summary(p_employee_id, p_punched_at::date);
END;
$$;
