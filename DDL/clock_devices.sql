CREATE TABLE clock_devices (
    id BIGINT  NOT NULL,
    branch_id BIGINT NOT NULL, 
    department_id BIGINT NOT NULL,   
    location VARCHAR(255) NOT NULL,
    model_name VARCHAR(255) NOT NULL   
);

ALTER TABLE clock_devices ADD PRIMARY KEY (id);
CREATE INDEX idx_clock_devices_branch_id ON clock_devices (branch_id);
CREATE INDEX idx_clock_devices_department_id ON clock_devices (department_id);

ALTER TABLE clock_devices
    ADD CONSTRAINT fk_clock_devices_branch
    FOREIGN KEY (branch_id) REFERENCES branches (id);

ALTER TABLE clock_devices
    ADD CONSTRAINT fk_clock_devices_department
    FOREIGN KEY (department_id) REFERENCES departments (id);
