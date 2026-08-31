CREATE TABLE departments (
    id        BIGINT       NOT NULL,
    name      VARCHAR(255) NOT NULL,
    branch_id BIGINT       NOT NULL   -- FK -> branches.id
);
ALTER TABLE departments ADD PRIMARY KEY (id);
CREATE INDEX idx_departments_branch_id ON departments (branch_id);

