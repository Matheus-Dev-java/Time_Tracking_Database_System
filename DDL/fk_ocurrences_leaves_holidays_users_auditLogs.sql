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
