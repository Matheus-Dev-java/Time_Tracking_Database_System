CREATE TABLE leave_types (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    code INTEGER NOT NULL,
    is_paid BOOLEAN NOT NULL -- TRUE = absence is paid / remunerated
);
ALTER TABLE leave_types ADD PRIMARY KEY (id);
