-- Creates the recalculation of hour bank movements and balance for a period.
CREATE OR REPLACE PROCEDURE sp_recalcular_banco_horas(
    p_employee_id integer,
    p_start_date date,
    p_end_date date
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_start_date IS NULL OR p_end_date IS NULL OR p_end_date < p_start_date THEN
        RAISE EXCEPTION 'Invalid recalculation period';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM employee WHERE employee_id = p_employee_id) THEN
        RAISE EXCEPTION 'Employee not found';
    END IF;

    DELETE FROM hour_bank_movement
     WHERE employee_id = p_employee_id
       AND movement_date BETWEEN p_start_date AND p_end_date;

    INSERT INTO hour_bank_movement (employee_id, movement_date, minutes)
    SELECT employee_id, work_date, worked_minutes - scheduled_minutes
      FROM daily_summary
     WHERE employee_id = p_employee_id
       AND work_date BETWEEN p_start_date AND p_end_date;

    INSERT INTO hour_bank (employee_id, balance_minutes, updated_at, expires_at)
    SELECT p_employee_id, COALESCE(SUM(minutes), 0), CURRENT_DATE, CURRENT_DATE + 180
      FROM hour_bank_movement
     WHERE employee_id = p_employee_id
    ON CONFLICT (employee_id) DO UPDATE
       SET balance_minutes = EXCLUDED.balance_minutes,
           updated_at = EXCLUDED.updated_at;
END;
$$;
