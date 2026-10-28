-- sp_recalcular_banco_horas
-- Recalcula o saldo do banco de horas na janela de compensacao: regera os creditos
-- (extras 50% + 100% de daily_apurations) e soma os debitos de folgas
-- (hour_bank_movements.DAY_OFF_DEBIT). Idempotente. Saldo em minutos; pode ficar negativo.
-- Recomputes the hour-bank balance for the compensation window (idempotent).
CREATE OR REPLACE PROCEDURE sp_recalcular_banco_horas(
    p_employee_id  BIGINT,
    p_window_start DATE,
    p_window_end   DATE,
    INOUT p_balance_minutes INTEGER DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_credit INTEGER;
    v_debit  INTEGER;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM employees WHERE id = p_employee_id) THEN
        RAISE EXCEPTION 'Colaborador % nao encontrado.', p_employee_id;
    END IF;
    IF p_window_start IS NULL OR p_window_end IS NULL OR p_window_end < p_window_start THEN
        RAISE EXCEPTION 'Periodo de compensacao invalido (% a %).', p_window_start, p_window_end;
    END IF;
    -- CLT art. 59, par. 2: compensacao em ate 12 meses (acordo coletivo)
    IF p_window_end > (p_window_start + INTERVAL '12 months')::date THEN
        RAISE EXCEPTION 'Periodo de compensacao excede 12 meses.';
    END IF;

    -- Creditos: regerados a partir da apuracao diaria
    DELETE FROM hour_bank_movements
     WHERE employee_id = p_employee_id AND movement_type = 'OVERTIME_CREDIT'
       AND movement_date BETWEEN p_window_start AND p_window_end;

    INSERT INTO hour_bank_movements (employee_id, movement_date, movement_type, minutes, source_daily_apuration_id, notes)
    SELECT da.employee_id, da.date, 'OVERTIME_CREDIT', da.overtime_50 + da.overtime_100, da.id, 'Horas excedentes da apuracao diaria'
      FROM daily_apurations da
     WHERE da.employee_id = p_employee_id
       AND da.date BETWEEN p_window_start AND p_window_end
       AND da.overtime_50 + da.overtime_100 > 0;

    SELECT COALESCE(sum(minutes) FILTER (WHERE movement_type = 'OVERTIME_CREDIT'), 0),
           COALESCE(sum(minutes) FILTER (WHERE movement_type = 'DAY_OFF_DEBIT'), 0)
      INTO v_credit, v_debit
      FROM hour_bank_movements
     WHERE employee_id = p_employee_id AND movement_date BETWEEN p_window_start AND p_window_end;

    p_balance_minutes := v_credit - v_debit;

    INSERT INTO hour_bank_balances (employee_id, window_start, window_end, credit_minutes, debit_minutes, balance_minutes)
    VALUES (p_employee_id, p_window_start, p_window_end, v_credit, v_debit, p_balance_minutes)
    ON CONFLICT (employee_id, window_start, window_end) DO UPDATE
       SET credit_minutes = EXCLUDED.credit_minutes, debit_minutes = EXCLUDED.debit_minutes,
           balance_minutes = EXCLUDED.balance_minutes, recalculated_at = LOCALTIMESTAMP(0);

    IF p_balance_minutes < 0 THEN
        RAISE NOTICE 'Saldo negativo (% min): colaborador usou mais folgas do que acumulou.', p_balance_minutes;
    END IF;
END $$;
