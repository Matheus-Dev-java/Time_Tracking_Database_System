CREATE TABLE employees (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    department_id BIGINT NOT NULL,   -- FK -> departments.id
    id_document VARCHAR(255) NOT NULL,   -- CPF, RG or CNH
    birth_date DATE NOT NULL
);
COMMENT ON COLUMN employees.id_document IS 'CPF, RG or CNH';
ALTER TABLE employees ADD PRIMARY KEY (id);
CREATE INDEX idx_employees_department_id ON employees (department_id);