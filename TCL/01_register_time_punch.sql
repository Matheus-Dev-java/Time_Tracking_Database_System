-- sp_registrar_marcacao_ponto
-- Registra o batimento de ponto validando geolocalizacao e rede contra a filial do
-- colaborador. A marcacao e SEMPRE gravada (registro de ponto nao pode ser descartado);
-- divergencias geram linhas em punch_alerts e location_status = 'DIVERGENT'.
-- Registers a punch, validates geolocation and network against the employee's branch;
-- divergences are recorded as alerts, the punch itself is always kept.
CREATE OR REPLACE PROCEDURE sp_registrar_marcacao_ponto(
    p_employee_id     BIGINT,
    p_device_id       BIGINT,
    p_punch_type      VARCHAR,                
    p_latitude        NUMERIC   DEFAULT NULL,
    p_longitude       NUMERIC   DEFAULT NULL,
    p_ip_address      INET      DEFAULT NULL,
    p_punched_at      TIMESTAMP DEFAULT NULL,        
    INOUT p_punch_id        BIGINT  DEFAULT NULL,
    INOUT p_location_status VARCHAR DEFAULT NULL     
)
LANGUAGE plpgsql AS $$
DECLARE
    v_branch      branches%ROWTYPE;
    v_requires_geo BOOLEAN;
    v_when        TIMESTAMP(0);
    v_distance    INTEGER;
    v_evaluated   BOOLEAN := FALSE;
    v_alerts      INTEGER := 0;
    v_geo_alert   VARCHAR(500);
    v_net_alert   VARCHAR(500);
BEGIN
    IF p_punch_type IS NULL OR p_punch_type NOT IN ('ENTRY','BREAK_START','BREAK_END','EXIT') THEN
        RAISE EXCEPTION 'Tipo de marcacao invalido: %. Use ENTRY, BREAK_START, BREAK_END ou EXIT.', p_punch_type;
    END IF;
    IF (p_latitude IS NULL) <> (p_longitude IS NULL) THEN
        RAISE EXCEPTION 'Informe latitude e longitude juntas, ou nenhuma das duas.';
    END IF;
    IF p_latitude NOT BETWEEN -90 AND 90 OR p_longitude NOT BETWEEN -180 AND 180 THEN
        RAISE EXCEPTION 'Coordenadas fora do intervalo valido (%, %).', p_latitude, p_longitude;
    END IF;

    -- Filial permitida = filial do departamento do colaborador
    SELECT b.* INTO v_branch
      FROM employees e
      JOIN departments d ON d.id = e.department_id
      JOIN branches b    ON b.id = d.branch_id
     WHERE e.id = p_employee_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Colaborador % nao encontrado.', p_employee_id;
    END IF;

    SELECT requires_geolocation INTO v_requires_geo FROM clock_devices WHERE id = p_device_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Equipamento de ponto % nao encontrado.', p_device_id;
    END IF;

    v_when := COALESCE(p_punched_at, LOCALTIMESTAMP)::timestamp(0);
    IF v_when > LOCALTIMESTAMP + INTERVAL '5 minutes' THEN
        RAISE EXCEPTION 'Horario da marcacao (%) esta no futuro.', v_when;
    END IF;

    -- Periodo fechado (filial ou colaborador)
    IF EXISTS (SELECT 1 FROM apuration_periods ap
                WHERE ap.branch_id = v_branch.id AND ap.is_closed
                  AND v_when::date BETWEEN ap.start_date AND ap.end_date)
       OR EXISTS (SELECT 1 FROM timesheet_closings tc
                   WHERE tc.employee_id = p_employee_id
                     AND v_when::date BETWEEN tc.period_start AND tc.period_end) THEN
        RAISE EXCEPTION 'Periodo de apuracao de % ja esta fechado; marcacao nao permitida.', v_when::date;
    END IF;

    -- Geolocalizacao
    IF p_latitude IS NOT NULL AND v_branch.latitude IS NOT NULL AND v_branch.geofence_radius_m IS NOT NULL THEN
        v_evaluated := TRUE;
        v_distance  := round(fn_distance_meters(p_latitude, p_longitude, v_branch.latitude, v_branch.longitude));
        IF v_distance > v_branch.geofence_radius_m THEN
            v_geo_alert := format('Marcacao a %s m da filial "%s" (raio permitido: %s m).',
                                  v_distance, v_branch.name, v_branch.geofence_radius_m);
        END IF;
    ELSIF p_latitude IS NULL AND v_requires_geo THEN
        v_evaluated := TRUE;
        v_geo_alert := 'Equipamento exige geolocalizacao, mas a marcacao veio sem coordenadas.';
    END IF;

    -- Rede
    IF p_ip_address IS NOT NULL AND v_branch.allowed_network IS NOT NULL THEN
        v_evaluated := TRUE;
        IF NOT (p_ip_address <<= v_branch.allowed_network) THEN
            v_net_alert := format('Endereco %s fora da rede permitida da filial "%s" (%s).',
                                  host(p_ip_address), v_branch.name, v_branch.allowed_network);
        END IF;
    END IF;

    p_location_status := CASE WHEN v_geo_alert IS NOT NULL OR v_net_alert IS NOT NULL THEN 'DIVERGENT'
                              WHEN v_evaluated THEN 'VALID'
                              ELSE 'NOT_EVALUATED' END;

    INSERT INTO time_punches (punched_at, employee_id, device_id, punch_type,
                              latitude, longitude, ip_address, location_status)
    VALUES (v_when, p_employee_id, p_device_id, p_punch_type,
            p_latitude, p_longitude, p_ip_address, p_location_status)
    RETURNING id INTO p_punch_id;

    IF v_geo_alert IS NOT NULL THEN
        INSERT INTO punch_alerts (time_punch_id, employee_id, alert_type, description, distance_meters)
        VALUES (p_punch_id, p_employee_id, 'GEOLOCATION', v_geo_alert, v_distance);
    END IF;
    IF v_net_alert IS NOT NULL THEN
        INSERT INTO punch_alerts (time_punch_id, employee_id, alert_type, description)
        VALUES (p_punch_id, p_employee_id, 'NETWORK', v_net_alert);
    END IF;
END $$;
