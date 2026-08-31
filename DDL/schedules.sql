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
