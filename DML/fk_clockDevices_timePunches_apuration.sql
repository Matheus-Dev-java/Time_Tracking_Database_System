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
