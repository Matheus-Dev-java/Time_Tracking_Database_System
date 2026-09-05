CREATE TABLE occurrence_types (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    grants_hours BOOLEAN NOT NULL, -- TRUE = absence is paid / hours are not deducted
    requires_doc BOOLEAN NOT NULL -- TRUE = employee must upload a proof document
);
ALTER TABLE occurrence_types ADD PRIMARY KEY (id);