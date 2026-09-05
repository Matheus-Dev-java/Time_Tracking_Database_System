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
