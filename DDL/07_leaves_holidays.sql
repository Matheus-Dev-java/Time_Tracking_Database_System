-- DDL 07 | Afastamentos e feriados / Leaves and holidays

-- ----------------------------------------------------------------------------
-- leave_types
-- ----------------------------------------------------------------------------
CREATE TABLE leave_types (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    code INTEGER NOT NULL,
    is_paid BOOLEAN NOT NULL -- TRUE = absence is paid / remunerated
);
ALTER TABLE leave_types ADD PRIMARY KEY (id);

-- ----------------------------------------------------------------------------
-- leaves
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
-- leave_records (formerly the root file 'ajuste de ponto')
-- ----------------------------------------------------------------------------
CREATE TABLE leave_records (
    id  BIGINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    leave_kind VARCHAR(100) NOT NULL,
    icd_code VARCHAR(20),
    document_url VARCHAR(255),
    status VARCHAR(50)  NOT NULL
);
ALTER TABLE leave_records ADD PRIMARY KEY (id);

-- ----------------------------------------------------------------------------
-- holidays
-- ----------------------------------------------------------------------------
CREATE TABLE holidays (
    id BIGINT NOT NULL,
    date DATE NOT NULL,
    description VARCHAR(255) NOT NULL,
    type VARCHAR(255) NOT NULL, -- NATIONAL | STATE | MUNICIPAL | OPTIONAL
    state_code VARCHAR(255) NOT NULL, -- UF code; NULL for national holidays
    branch_id BIGINT NOT NULL, -- FK -> branches.id; NULL for non-municipal
    recurring BOOLEAN NOT NULL -- TRUE = repeats every year (e.g. Christmas)
);
ALTER TABLE holidays ADD PRIMARY KEY (id);
CREATE INDEX idx_holidays_branch_id ON holidays (branch_id);

