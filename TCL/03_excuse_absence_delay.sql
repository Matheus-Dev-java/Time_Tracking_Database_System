-- sp_abonar_falta_atraso
-- Abona (total ou parcialmente) a ausencia/atraso de um dia: valida o tipo de ocorrencia
-- e o documento comprobatorio, grava a ocorrencia APPROVED, reduz hours_absence do dia e
-- devolve o total de horas ainda devidas no mes (minutos).
-- Excuses an absence/delay after validating the justification, and returns the remaining
-- minutes owed in the month.
CREATE OR REPLACE PROCEDURE sp_abonar_falta_atraso(
    p_employee_id        BIGINT,
    p_date               DATE,
    p_occurrence_type_id BIGINT,
    p_user_id            BIGINT,                    -- quem aprova
    p_minutes            INTEGER DEFAULT NULL,      -- NULL = abona todo o debito do dia
    p_attachment_url     VARCHAR DEFAULT NULL,      -- atestado / justificativa
    p_description        VARCHAR DEFAULT NULL,
    INOUT p_month_due_minutes INTEGER DEFAULT NULL  -- horas devidas restantes no mes
)
LANGUAGE plpgsql AS $$
DECLARE
    v_da     daily_apurations%ROWTYPE;
    v_type   occurrence_types%ROWTYPE;
    v_branch BIGINT;
    v_excused  INTEGER;
    v_new_absence INTEGER;
    v_occ_id BIGINT;
BEGIN
    SELECT d.branch_id INTO v_branch
      FROM employees e JOIN departments d ON d.id = e.department_id WHERE e.id = p_employee_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Colaborador % nao encontrado.', p_employee_id; END IF;
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = p_user_id AND is_active) THEN
        RAISE EXCEPTION 'Usuario % inexistente ou inativo.', p_user_id;
    END IF;

    SELECT * INTO v_type FROM occurrence_types WHERE id = p_occurrence_type_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Tipo de ocorrencia % nao encontrado.', p_occurrence_type_id; END IF;
    IF NOT v_type.grants_hours THEN
        RAISE EXCEPTION 'O tipo "%" nao concede abono.', v_type.name;
    END IF;
    IF v_type.requires_doc AND COALESCE(btrim(p_attachment_url), '') = '' THEN
        RAISE EXCEPTION 'O tipo "%" exige atestado/documento comprobatorio.', v_type.name;
    END IF;

    SELECT * INTO v_da FROM daily_apurations
     WHERE employee_id = p_employee_id AND date = p_date FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nao ha apuracao diaria do colaborador % em %.', p_employee_id, p_date;
    END IF;
    IF v_da.day_status NOT IN ('WORKED','ABSENCE') THEN
        RAISE EXCEPTION 'Dia % com status % nao admite abono.', p_date, v_da.day_status;
    END IF;
    IF v_da.hours_absence <= 0 THEN
        RAISE EXCEPTION 'Nao ha falta/atraso a abonar em % (hours_absence = 0).', p_date;
    END IF;

    IF EXISTS (SELECT 1 FROM timesheet_closings WHERE employee_id = p_employee_id
                  AND p_date BETWEEN period_start AND period_end)
       OR EXISTS (SELECT 1 FROM apuration_periods WHERE branch_id = v_branch AND is_closed
                  AND p_date BETWEEN start_date AND end_date) THEN
        RAISE EXCEPTION 'O periodo de % esta fechado; abono nao permitido.', p_date;
    END IF;

    v_excused := COALESCE(p_minutes, v_da.hours_absence);
    IF v_excused <= 0 OR v_excused > v_da.hours_absence THEN
        RAISE EXCEPTION 'Minutos a abonar (%) invalidos: o debito do dia e de % min.', v_excused, v_da.hours_absence;
    END IF;
    v_new_absence := v_da.hours_absence - v_excused;

    INSERT INTO occurrences (daily_apuration_id, occurrence_type_id, description, attachment_url, status)
    VALUES (v_da.id, p_occurrence_type_id,
            COALESCE(p_description, format('Abono de %s min (%s)', v_excused, v_type.name)),
            COALESCE(p_attachment_url, ''), 'APPROVED')
    RETURNING id INTO v_occ_id;

    UPDATE daily_apurations
       SET hours_absence = v_new_absence,
           day_status    = CASE WHEN v_new_absence = 0 AND day_status = 'ABSENCE' THEN 'JUSTIFIED' ELSE day_status END
     WHERE id = v_da.id;

    SELECT COALESCE(sum(hours_absence), 0) INTO p_month_due_minutes
      FROM daily_apurations
     WHERE employee_id = p_employee_id
       AND date BETWEEN date_trunc('month', p_date)::date
                    AND (date_trunc('month', p_date) + INTERVAL '1 month - 1 day')::date;

    INSERT INTO audit_logs (user_id, action, affected_table, record_id, old_data, new_data, changed_at)
    VALUES (p_user_id, 'UPDATE', 'daily_apurations', v_da.id,
            json_build_object('hours_absence', v_da.hours_absence, 'day_status', v_da.day_status),
            json_build_object('hours_absence', v_new_absence, 'occurrence_id', v_occ_id, 'minutes_excused', v_excused),
            LOCALTIMESTAMP(0));
END $$;
