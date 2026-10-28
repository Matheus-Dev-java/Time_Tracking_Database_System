-- DDL 06 | Ocorrencias e ajustes de ponto / Occurrences and time adjustments

-- ----------------------------------------------------------------------------
-- occurrence_types
-- ----------------------------------------------------------------------------
CREATE TABLE occurrence_types (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    grants_hours BOOLEAN NOT NULL, -- TRUE = absence is paid / hours are not deducted
    requires_doc BOOLEAN NOT NULL -- TRUE = employee must upload a proof document
);
ALTER TABLE occurrence_types ADD PRIMARY KEY (id);
-- ----------------------------------------------------------------------------
-- occurrences
-- ----------------------------------------------------------------------------
CREATE TABLE occurrences (
    id BIGINT NOT NULL,
    daily_apuration_id BIGINT NOT NULL, -- FK -> daily_apurations.id
    occurrence_type_id BIGINT NOT NULL, -- FK -> occurrence_types.id
    description VARCHAR(255) NOT NULL,
    attachment_url VARCHAR(255) NOT NULL,
    status VARCHAR(255) NOT NULL -- PENDING | APPROVED | REJECTED
);
ALTER TABLE occurrences ADD PRIMARY KEY (id);
CREATE INDEX idx_occurrences_daily_apuration_id ON occurrences (daily_apuration_id);
CREATE INDEX idx_occurrences_occurrence_type_id ON occurrences (occurrence_type_id);

-- ----------------------------------------------------------------------------
-- time_adjustments
-- ----------------------------------------------------------------------------
CREATE TABLE time_adjustments (
    id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    daily_record_id BIGINT NOT NULL,
    reason VARCHAR(255) NOT NULL,        
    document_proof_url VARCHAR(500),     
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    reviewed_by BIGINT,                 
    created_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE time_adjustments ADD PRIMARY KEY (id);
ALTER TABLE time_adjustments 
    ADD CONSTRAINT fk_time_adjustments_employees 
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE;
ALTER TABLE time_adjustments 
    ADD CONSTRAINT fk_time_adjustments_daily_records 
    FOREIGN KEY (daily_record_id) REFERENCES daily_time_records(id) ON DELETE CASCADE;
ALTER TABLE time_adjustments 
    ADD CONSTRAINT fk_time_adjustments_reviewer 
    FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL;

-- ----------------------------------------------------------------------------
-- punch_adjustments (formerly the root file 'ajuste de ponto')
-- ----------------------------------------------------------------------------
CREATE TABLE punch_adjustments (
    id BIGINT NOT NULL,
    adjusted_at TIMESTAMP NOT NULL,
    adjustment_type VARCHAR(50) NOT NULL,
    reason TEXT NOT NULL,
    status VARCHAR(50) NOT NULL 
);
ALTER TABLE punch_adjustments ADD PRIMARY KEY (id);

