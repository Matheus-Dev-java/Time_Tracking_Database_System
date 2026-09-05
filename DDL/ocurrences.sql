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
