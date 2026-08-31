CREATE TABLE branches (
    id         BIGINT       NOT NULL,
    name       VARCHAR(255) NOT NULL,
    company_id BIGINT       NOT NULL   -- FK -> companies.id
);
ALTER TABLE branches ADD PRIMARY KEY (id);
CREATE INDEX idx_branches_company_id ON branches (company_id);

