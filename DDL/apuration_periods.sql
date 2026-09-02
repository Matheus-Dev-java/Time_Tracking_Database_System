CREATE TABLE apuration_periods (
    id BIGINT NOT NULL,
    branch_id BIGINT NOT NULL, -- FK -> branches.id
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_closed BOOLEAN NOT NULL, -- TRUE = locked; no further edits allowed
    closed_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    closed_by_user BIGINT NOT NULL -- FK -> users.id
);
ALTER TABLE apuration_periods ADD PRIMARY KEY (id);
CREATE INDEX idx_apuration_periods_branch_id ON apuration_periods (branch_id);
CREATE INDEX idx_apuration_periods_closed_by_user ON apuration_periods (closed_by_user);