CREATE TABLE leaves (
    id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL, -- FK -> employees.id
    leave_type_id BIGINT NOT NULL, -- FK -> leave_types.id
    start_date DATE NOT NULL,
    end_date DATE NOT NULL, -- May be NULL for open-ended INSS leaves
    cid VARCHAR(255) NOT NULL, -- ICD code (sensitive / LGPD)
    document_url VARCHAR(255) NOT NULL -- Medical certificate or vacation notice PDF
);
ALTER TABLE leaves ADD PRIMARY KEY (id);
CREATE INDEX idx_leaves_employee_id   ON leaves (employee_id);
CREATE INDEX idx_leaves_leave_type_id ON leaves (leave_type_id);