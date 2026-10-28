-- DDL 04 | Registro de ponto / Time recording

-- ----------------------------------------------------------------------------
-- clock_devices
-- ----------------------------------------------------------------------------
CREATE TABLE clock_devices (
    id BIGINT NOT NULL,
    branch_id BIGINT NOT NULL, -- FK -> branches.id
    department_id BIGINT NOT NULL, -- FK -> departments.id
    location VARCHAR(255) NOT NULL, -- Physical location description
    model_name VARCHAR(255) NOT NULL -- Device model / app name
);
ALTER TABLE clock_devices ADD PRIMARY KEY (id);
CREATE INDEX idx_clock_devices_branch_id ON clock_devices (branch_id);
CREATE INDEX idx_clock_devices_department_id ON clock_devices (department_id);
-- ----------------------------------------------------------------------------
-- time_punches
-- ----------------------------------------------------------------------------
CREATE TABLE time_punches (
    id BIGINT NOT NULL,
    punched_at DATE NOT NULL, -- Timestamp of the punch
    employee_id BIGINT NOT NULL, -- FK -> employees.id
    device_id BIGINT NOT NULL -- FK -> clock_devices.id
);
ALTER TABLE time_punches ADD PRIMARY KEY (id);
CREATE INDEX idx_time_punches_employee_id ON time_punches (employee_id);
CREATE INDEX idx_time_punches_device_id   ON time_punches (device_id);

-- ----------------------------------------------------------------------------
-- time_clocks
-- ----------------------------------------------------------------------------
CREATE TABLE time_clocks (
    id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    clock_time TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    clock_type VARCHAR(20) NOT NULL, 
    origin VARCHAR(50) NOT NULL,    
    latitude DECIMAL(10, 8),       
    longitude DECIMAL(11, 8)
);
ALTER TABLE time_clocks ADD PRIMARY KEY (id);
ALTER TABLE time_clocks 
    ADD CONSTRAINT fk_time_clocks_employees 
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE;

