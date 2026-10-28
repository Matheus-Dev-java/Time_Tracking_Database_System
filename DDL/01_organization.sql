-- DDL 01 | Estrutura organizacional / Organizational structure

-- ----------------------------------------------------------------------------
-- companies
-- ----------------------------------------------------------------------------
CREATE TABLE companies (
    id   BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    cnpj VARCHAR(255) NOT NULL
);
ALTER TABLE companies ADD PRIMARY KEY (id);


-- ----------------------------------------------------------------------------
-- branches
-- ----------------------------------------------------------------------------
CREATE TABLE branches (
    id         BIGINT       NOT NULL,
    name       VARCHAR(255) NOT NULL,
    company_id BIGINT       NOT NULL   -- FK -> companies.id
);
ALTER TABLE branches ADD PRIMARY KEY (id);
CREATE INDEX idx_branches_company_id ON branches (company_id);


-- ----------------------------------------------------------------------------
-- departments
-- ----------------------------------------------------------------------------
CREATE TABLE departments (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    branch_id BIGINT NOT NULL   -- FK -> branches.id
);
ALTER TABLE departments ADD PRIMARY KEY (id);
CREATE INDEX idx_departments_branch_id ON departments (branch_id);


-- ----------------------------------------------------------------------------
-- job_titles
-- ----------------------------------------------------------------------------
CREATE TABLE job_titles (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    cbo VARCHAR(255) NOT NULL -- Brazilian Occupation Code
);
ALTER TABLE job_titles ADD PRIMARY KEY (id);

-- ----------------------------------------------------------------------------
-- employees
-- ----------------------------------------------------------------------------
CREATE TABLE employees (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    department_id BIGINT NOT NULL,   -- FK -> departments.id
    id_document VARCHAR(255) NOT NULL,   -- CPF, RG or CNH
    birth_date DATE NOT NULL
);
COMMENT ON COLUMN employees.id_document IS 'CPF, RG or CNH';
ALTER TABLE employees ADD PRIMARY KEY (id);
CREATE INDEX idx_employees_department_id ON employees (department_id);
