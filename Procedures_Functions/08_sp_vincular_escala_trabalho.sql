-- Creates the link of a work schedule to a group of employees, closing their current history.
CREATE OR REPLACE PROCEDURE sp_vincular_escala_trabalho(
    p_work_schedule_id integer,
    p_employee_ids integer[],
    p_start_date date
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_employer_id integer;
BEGIN
    SELECT employer_id INTO v_employer_id
      FROM work_schedule
     WHERE work_schedule_id = p_work_schedule_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Work schedule not found';
    END IF;

    IF p_employee_ids IS NULL OR cardinality(p_employee_ids) = 0 THEN
        RAISE EXCEPTION 'At least one employee is required';
    END IF;

    IF p_start_date IS NULL THEN
        RAISE EXCEPTION 'Start date is required';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM unnest(p_employee_ids) AS informed(employee_id)
         WHERE NOT EXISTS (SELECT 1 FROM employee e WHERE e.employee_id = informed.employee_id)
    ) THEN
        RAISE EXCEPTION 'Some informed employees do not exist';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM employee
         WHERE employee_id = ANY (p_employee_ids)
           AND employer_id <> v_employer_id
    ) THEN
        RAISE EXCEPTION 'Employee does not belong to the employer of the work schedule';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM employee_schedule_history h
         WHERE h.employee_id = ANY (p_employee_ids)
           AND h.work_schedule_id = p_work_schedule_id
           AND p_start_date BETWEEN h.start_date AND COALESCE(h.end_date, DATE 'infinity')
    ) THEN
        RAISE EXCEPTION 'Employee already linked to this work schedule';
    END IF;

    IF EXISTS (
        SELECT 1
          FROM employee_schedule_history h
         WHERE h.employee_id = ANY (p_employee_ids)
           AND daterange(h.start_date, h.end_date, '[]') && daterange(p_start_date, NULL)
           AND NOT (h.end_date IS NULL AND h.start_date < p_start_date)
    ) THEN
        RAISE EXCEPTION 'Work schedule conflicts with the schedule history';
    END IF;

    UPDATE employee_schedule_history
       SET end_date = p_start_date - 1
     WHERE employee_id = ANY (p_employee_ids)
       AND end_date IS NULL;

    INSERT INTO employee_schedule_history (employee_id, work_schedule_id, start_date)
    SELECT DISTINCT informed.employee_id, p_work_schedule_id, p_start_date
      FROM unnest(p_employee_ids) AS informed(employee_id);
END;
$$;
