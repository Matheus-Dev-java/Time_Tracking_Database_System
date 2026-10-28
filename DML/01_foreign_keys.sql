-- DML 01 | Chaves estrangeiras / Foreign keys (rodar apos todos os DDL)

-- ----------------------------------------------------------------------------
-- organization
-- ----------------------------------------------------------------------------
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


-- ----------------------------------------------------------------------------
-- time recording and apuration
-- ----------------------------------------------------------------------------
-- clock_devices -> branches
ALTER TABLE clock_devices
    ADD CONSTRAINT fk_clock_devices_branch
    FOREIGN KEY (branch_id) REFERENCES branches (id);

-- clock_devices -> departments
ALTER TABLE clock_devices
    ADD CONSTRAINT fk_clock_devices_department
    FOREIGN KEY (department_id) REFERENCES departments (id);

-- time_punches -> employees
ALTER TABLE time_punches
    ADD CONSTRAINT fk_time_punches_employee
    FOREIGN KEY (employee_id) REFERENCES employees (id);

-- time_punches -> clock_devices
ALTER TABLE time_punches
    ADD CONSTRAINT fk_time_punches_device
    FOREIGN KEY (device_id) REFERENCES clock_devices (id);
    
-- apuration_periods -> branches
ALTER TABLE apuration_periods
    ADD CONSTRAINT fk_apuration_periods_branch
    FOREIGN KEY (branch_id) REFERENCES branches (id);

-- apuration_periods -> users (who closed the period)
ALTER TABLE apuration_periods
    ADD CONSTRAINT fk_apuration_periods_closed_by
    FOREIGN KEY (closed_by_user) REFERENCES users (id);

-- daily_apurations -> employees
ALTER TABLE daily_apurations
    ADD CONSTRAINT fk_daily_apurations_employee
    FOREIGN KEY (employee_id) REFERENCES employees (id);

-- daily_apurations -> schedules (shift in effect that day)
ALTER TABLE daily_apurations
    ADD CONSTRAINT fk_daily_apurations_schedule
    FOREIGN KEY (schedule_id) REFERENCES schedules (id);

-- ----------------------------------------------------------------------------
-- occurrences, leaves, holidays, users, audit
-- ----------------------------------------------------------------------------
-- occurrences -> daily_apurations
ALTER TABLE occurrences
    ADD CONSTRAINT fk_occurrences_daily_apuration
    FOREIGN KEY (daily_apuration_id) REFERENCES daily_apurations (id);

-- occurrences -> occurrence_types
ALTER TABLE occurrences
    ADD CONSTRAINT fk_occurrences_occurrence_type
    FOREIGN KEY (occurrence_type_id) REFERENCES occurrence_types (id);

-- leaves -> employees
ALTER TABLE leaves
    ADD CONSTRAINT fk_leaves_employee
    FOREIGN KEY (employee_id) REFERENCES employees (id);

-- leaves -> leave_types
ALTER TABLE leaves
    ADD CONSTRAINT fk_leaves_leave_type
    FOREIGN KEY (leave_type_id) REFERENCES leave_types (id);

-- holidays -> branches (for municipal/optional holidays)
ALTER TABLE holidays
    ADD CONSTRAINT fk_holidays_branch
    FOREIGN KEY (branch_id) REFERENCES branches (id);

-- users -> employees
ALTER TABLE users
    ADD CONSTRAINT fk_users_employee
    FOREIGN KEY (employee_id) REFERENCES employees (id);

-- users -> permission_profiles
ALTER TABLE users
    ADD CONSTRAINT fk_users_profile
    FOREIGN KEY (profile_id) REFERENCES permission_profiles (id);

-- audit_logs -> users
ALTER TABLE audit_logs
    ADD CONSTRAINT fk_audit_logs_user
    FOREIGN KEY (user_id) REFERENCES users (id);

-- daily_apurations -> apuration_periods
ALTER TABLE daily_apurations
    ADD CONSTRAINT fk_daily_apurations_period
    FOREIGN KEY (apuration_period_id) REFERENCES apuration_periods (id);

