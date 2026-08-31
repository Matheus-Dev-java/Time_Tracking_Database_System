ALTER TABLE branches
    ADD CONSTRAINT fk_branches_company
    FOREIGN KEY (company_id) REFERENCES companies (id);
-- departments -> branches
ALTER TABLE departments
    ADD CONSTRAINT fk_departments_branch
    FOREIGN KEY (branch_id) REFERENCES branches (id);
-- employees -> departments
ALTER TABLE employees
    ADD CONSTRAINT fk_employees_department
    FOREIGN KEY (department_id) REFERENCES departments (id);

