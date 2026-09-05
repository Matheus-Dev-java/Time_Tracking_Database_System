CREATE TABLE audit_logs (
    id BIGINT NOT NULL,
    user_id BIGINT NOT NULL, -- FK -> users.id (who made the change)
    action VARCHAR(255) NOT NULL, -- INSERT | UPDATE | DELETE
    affected_table VARCHAR(255) NOT NULL,   -- Name of the changed table
    record_id BIGINT NOT NULL, -- PK of the changed row
    old_data JSON NOT NULL, -- State before the change
    new_data JSON NOT NULL, -- State after the change
    changed_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL
);
ALTER TABLE audit_logs ADD PRIMARY KEY (id);