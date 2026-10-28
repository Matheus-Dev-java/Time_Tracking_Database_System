-- sp_vincular_escala_trabalho
-- Atribui um turno (shifts) a um grupo de colaboradores a partir de uma data. Tudo ou nada:
-- se qualquer colaborador tiver conflito, nada e gravado e a excecao lista todos eles.
-- Encerra a jornada vigente (end_date = inicio - 1), grava o novo historico em
-- employee_shifts e cria a escala correspondente em schedules.
-- Assigns a shift to a group of employees, all-or-nothing, preserving shift history.
CREATE OR REPLACE PROCEDURE sp_vincular_escala_trabalho(
    p_shift_id     BIGINT,
    p_employee_ids BIGINT[],
    p_start_date   DATE,
    p_user_id      BIGINT,
    INOUT p_linked_count INTEGER DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_shift     shifts%ROWTYPE;
    v_ids       BIGINT[];
    v_missing   TEXT;
    v_conflicts TEXT;
    v_workload  INTEGER;
    v_emp       BIGINT;
    v_es_id     BIGINT;
BEGIN
    IF p_employee_ids IS NULL OR cardinality(p_employee_ids) = 0 OR p_start_date IS NULL THEN
        RAISE EXCEPTION 'Informe ao menos um colaborador e a data de inicio.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = p_user_id AND is_active) THEN
        RAISE EXCEPTION 'Usuario % inexistente ou inativo.', p_user_id;
    END IF;
    SELECT * INTO v_shift FROM shifts WHERE id = p_shift_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Turno % nao encontrado.', p_shift_id; END IF;

    SELECT array_agg(DISTINCT x ORDER BY x) INTO v_ids FROM unnest(p_employee_ids) x;

    SELECT string_agg(x::text, ', ') INTO v_missing
      FROM unnest(v_ids) x WHERE NOT EXISTS (SELECT 1 FROM employees WHERE id = x);
    IF v_missing IS NOT NULL THEN
        RAISE EXCEPTION 'Colaboradores inexistentes: %.', v_missing;
    END IF;

    -- Conflitos (todos listados de uma vez)
    SELECT string_agg(format('colaborador %s (%s)', c.employee_id, c.reason), '; ' ORDER BY c.employee_id)
      INTO v_conflicts
      FROM (
        SELECT x AS employee_id, 'ja possui escala iniciando em ' || es.start_date || ' ou depois' AS reason
          FROM unnest(v_ids) x JOIN employee_shifts es ON es.employee_id = x AND es.start_date >= p_start_date
        UNION
        SELECT x, 'ja esta vigente nesta escala'
          FROM unnest(v_ids) x JOIN employee_shifts es ON es.employee_id = x
           AND es.shift_id = p_shift_id AND es.start_date < p_start_date
           AND (es.end_date IS NULL OR es.end_date >= p_start_date)
        UNION
        SELECT x, 'espelho fechado ate ' || tc.period_end
          FROM unnest(v_ids) x JOIN timesheet_closings tc ON tc.employee_id = x AND tc.period_end >= p_start_date
      ) c;
    IF v_conflicts IS NOT NULL THEN
        RAISE EXCEPTION 'Conflito de escala, nenhuma alteracao gravada: %', v_conflicts;
    END IF;

    -- Carga diaria liquida em minutos (trata turno que cruza a meia-noite)
    v_workload := (EXTRACT(EPOCH FROM ((v_shift.clock_out_time - v_shift.clock_in_time) + INTERVAL '24 hours'))::int % 86400
                 - EXTRACT(EPOCH FROM ((v_shift.break_end_time - v_shift.break_start_time) + INTERVAL '24 hours'))::int % 86400) / 60;

    p_linked_count := 0;
    FOREACH v_emp IN ARRAY v_ids LOOP
        UPDATE employee_shifts SET end_date = p_start_date - 1
         WHERE employee_id = v_emp AND start_date < p_start_date
           AND (end_date IS NULL OR end_date >= p_start_date);

        INSERT INTO employee_shifts (employee_id, shift_id, start_date, end_date)
        VALUES (v_emp, p_shift_id, p_start_date, NULL) RETURNING id INTO v_es_id;

        INSERT INTO schedules (shift_name, workload, employee_id) VALUES (v_shift.name, v_workload, v_emp);

        INSERT INTO audit_logs (user_id, action, affected_table, record_id, old_data, new_data, changed_at)
        VALUES (p_user_id, 'INSERT', 'employee_shifts', v_es_id, '{}',
                json_build_object('employee_id', v_emp, 'shift_id', p_shift_id, 'start_date', p_start_date),
                LOCALTIMESTAMP(0));
        p_linked_count := p_linked_count + 1;
    END LOOP;
END $$;
