CREATE TABLE time_punches (
    id BIGINT NOT NULL,
    punched_at DATE NOT NULL, -- Timestamp of the punch
    employee_id BIGINT NOT NULL, -- FK -> employees.id
    device_id BIGINT NOT NULL -- FK -> clock_devices.id
);
ALTER TABLE time_punches ADD PRIMARY KEY (id);
CREATE INDEX idx_time_punches_employee_id ON time_punches (employee_id);
CREATE INDEX idx_time_punches_device_id   ON time_punches (device_id);
