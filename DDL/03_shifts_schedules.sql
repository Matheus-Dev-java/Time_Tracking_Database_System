-- DDL 03 | Turnos, escalas e historico de jornadas / Shifts, schedules, shift history

-- ----------------------------------------------------------------------------
-- shifts
-- ----------------------------------------------------------------------------
CREATE TABLE shifts (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    clock_in_time TIME(0) WITHOUT TIME ZONE NOT NULL,
    break_start_time TIME(0) WITHOUT TIME ZONE NOT NULL,   
    break_end_time TIME(0) WITHOUT TIME ZONE NOT NULL,   
    clock_out_time TIME(0) WITHOUT TIME ZONE NOT NULL,  
    tolerance_minutes INTEGER NOT NULL                 
);

ALTER TABLE shifts ADD PRIMARY KEY (id);

-- ----------------------------------------------------------------------------
-- schedules
-- ----------------------------------------------------------------------------
CREATE TABLE schedules (
    id BIGINT NOT NULL,
    shift_name VARCHAR(255) NOT NULL, 
    workload INTEGER NOT NULL, 
    employee_id BIGINT NOT NULL 
);

ALTER TABLE schedules ADD PRIMARY KEY (id);
CREATE INDEX idx_schedules_employee_id ON schedules (employee_id);

ALTER TABLE schedules
    ADD CONSTRAINT fk_schedules_employee
    FOREIGN KEY (employee_id) REFERENCES employees (id);

-- ----------------------------------------------------------------------------
-- employee_shifts (historico de jornadas contratuais)
-- ----------------------------------------------------------------------------
CREATE TABLE employee_shifts (
    id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    shift_id BIGINT NOT NULL,
    start_date DATE NOT NULL,
end_date DATE 
);
ALTER TABLE employee_shifts ADD PRIMARY KEY (id);
ALTER TABLE employee_shifts 
    ADD CONSTRAINT fk_employee_shifts_employees 
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE;
ALTER TABLE employee_shifts 
    ADD CONSTRAINT fk_employee_shifts_shifts 
    FOREIGN KEY (shift_id) REFERENCES shifts(id);

