-- sp_fechar_espelho_ponto_mensal
-- Fecha o mes de um colaborador: consolida horas trabalhadas, extras, adicional noturno
-- e faltas em timesheet_closings e bloqueia o periodo (triggers em daily_apurations e
-- time_punches). Todos os valores em minutos, como em daily_apurations.
-- Closes an employee's month, consolidating totals and locking the period.
CREATE OR REPLACE PROCEDURE sp_fechar_espelho_ponto_mensal(
    p_employee_id    BIGINT,
    p_reference_month DATE,                 -- qualquer data dentro do mes
    p_user_id        BIGINT,                -- quem fecha (users.id)
    INOUT p_closing_id BIGINT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_start   DATE := date_trunc('month', p_reference_month)::date;
    v_end     DATE := (date_trunc('month', p_reference_month) + INTERVAL '1 month - 1 day')::date;
    v_branch  BIGINT;
    v_period  apuration_periods%ROWTYPE;
    v_rows    INTEGER;
    v_worked  INTEGER; v_overtime INTEGER; v_night INTEGER; v_abs_min INTEGER; v_abs_days INTEGER;
    v_closed_at TIMESTAMP(0) := LOCALTIMESTAMP(0);
    v_hash    CHAR(64);
BEGIN
    SELECT d.branch_id INTO v_branch
      FROM employees e JOIN departments d ON d.id = e.department_id
     WHERE e.id = p_employee_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Colaborador % nao encontrado.', p_employee_id; END IF;
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = p_user_id AND is_active) THEN
        RAISE EXCEPTION 'Usuario % inexistente ou inativo.', p_user_id;
    END IF;
    IF v_end >= CURRENT_DATE THEN
        RAISE EXCEPTION 'O mes %/% ainda nao terminou; fechamento nao permitido.',
            to_char(v_start,'MM'), to_char(v_start,'YYYY');
    END IF;

    SELECT * INTO v_period FROM apuration_periods
     WHERE branch_id = v_branch AND start_date <= v_start AND end_date >= v_end
     ORDER BY start_date DESC LIMIT 1;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Nao ha periodo de apuracao cadastrado para a filial % em %/%.',
            v_branch, to_char(v_start,'MM'), to_char(v_start,'YYYY');
    END IF;
    IF v_period.is_closed THEN
        RAISE EXCEPTION 'O periodo de apuracao % da filial ja foi encerrado.', v_period.id;
    END IF;
    IF EXISTS (SELECT 1 FROM timesheet_closings
                WHERE employee_id = p_employee_id AND period_start = v_start) THEN
        RAISE EXCEPTION 'Espelho de %/% do colaborador % ja esta fechado.',
            to_char(v_start,'MM'), to_char(v_start,'YYYY'), p_employee_id;
    END IF;

    -- Nao fecha com justificativas pendentes de aprovacao
    IF EXISTS (SELECT 1 FROM occurrences o
                 JOIN daily_apurations da ON da.id = o.daily_apuration_id
                WHERE da.employee_id = p_employee_id AND da.date BETWEEN v_start AND v_end
                  AND o.status = 'PENDING') THEN
        RAISE EXCEPTION 'Existem ocorrencias PENDENTES para o colaborador % no periodo; resolva antes de fechar.', p_employee_id;
    END IF;

    SELECT count(*),
           COALESCE(sum(hours_worked),0),
           COALESCE(sum(overtime_50 + overtime_100),0),
           COALESCE(sum(night_hours),0),
           COALESCE(sum(hours_absence),0),
           count(*) FILTER (WHERE day_status = 'ABSENCE')
      INTO v_rows, v_worked, v_overtime, v_night, v_abs_min, v_abs_days
      FROM daily_apurations
     WHERE employee_id = p_employee_id AND date BETWEEN v_start AND v_end;
    IF v_rows = 0 THEN
        RAISE EXCEPTION 'Nao ha apuracao diaria do colaborador % entre % e %.', p_employee_id, v_start, v_end;
    END IF;

    v_hash := encode(sha256(convert_to(concat_ws('|', p_employee_id, v_start, v_end, v_worked,
                                v_overtime, v_night, v_abs_min, v_abs_days, p_user_id, v_closed_at), 'UTF8')), 'hex');

    INSERT INTO timesheet_closings (employee_id, apuration_period_id, period_start, period_end,
            worked_minutes, overtime_minutes, night_minutes, absence_minutes, absence_days,
            closed_at, closed_by_user, integrity_hash)
    VALUES (p_employee_id, v_period.id, v_start, v_end, v_worked, v_overtime, v_night, v_abs_min, v_abs_days,
            v_closed_at, p_user_id, v_hash)
    RETURNING id INTO p_closing_id;

    INSERT INTO audit_logs (user_id, action, affected_table, record_id, old_data, new_data, changed_at)
    VALUES (p_user_id, 'INSERT', 'timesheet_closings', p_closing_id, '{}',
            json_build_object('employee_id', p_employee_id, 'period_start', v_start, 'period_end', v_end,
                              'worked_minutes', v_worked, 'overtime_minutes', v_overtime,
                              'night_minutes', v_night, 'absence_minutes', v_abs_min),
            v_closed_at);
END $$;
