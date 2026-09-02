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