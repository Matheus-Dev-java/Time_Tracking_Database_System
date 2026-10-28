-- DDL 05 | Apuracao de ponto / Time apuration

-- ----------------------------------------------------------------------------
-- apuration_periods
-- ----------------------------------------------------------------------------
CREATE TABLE apuration_periods (
    id BIGINT NOT NULL,
    branch_id BIGINT NOT NULL, -- FK -> branches.id
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_closed BOOLEAN NOT NULL, -- TRUE = locked; no further edits allowed
    closed_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    closed_by_user BIGINT NOT NULL -- FK -> users.id
);
ALTER TABLE apuration_periods ADD PRIMARY KEY (id);
CREATE INDEX idx_apuration_periods_branch_id ON apuration_periods (branch_id);
CREATE INDEX idx_apuration_periods_closed_by_user ON apuration_periods (closed_by_user);
-- ----------------------------------------------------------------------------
-- daily_apurations
-- ----------------------------------------------------------------------------
CREATE TABLE daily_apurations (
    id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL, -- FK -> employees.id
    apuration_period_id INTEGER NOT NULL, -- FK -> apuration_periods.id
    schedule_id BIGINT NOT NULL, -- FK -> schedules.id (shift in effect that day)
    date DATE NOT NULL,
    hours_worked INTEGER NOT NULL, -- In minutes
    hours_expected INTEGER NOT NULL, -- In minutes
    overtime_50 INTEGER NOT NULL, -- Overtime at 50 % rate (minutes)
    overtime_100 INTEGER NOT NULL, -- Overtime at 100 % rate (minutes)
    hours_absence INTEGER NOT NULL, -- Missing/absent minutes
    night_hours INTEGER NOT NULL, -- Night-shift additional hours (minutes)
    day_status VARCHAR(255) NOT NULL -- WORKED | ABSENCE | JUSTIFIED | LEAVE | HOLIDAY | DAY_OFF
);
ALTER TABLE daily_apurations ADD PRIMARY KEY (id);
CREATE INDEX idx_daily_apurations_employee_id ON daily_apurations (employee_id);
CREATE INDEX idx_daily_apurations_schedule_id ON daily_apurations (schedule_id);
-- ----------------------------------------------------------------------------
-- daily_time_records
-- ----------------------------------------------------------------------------
CREATE TABLE daily_time_records (
    id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    record_date DATE NOT NULL,
    worked_minutes INTEGER NOT NULL DEFAULT 0,
    expected_minutes INTEGER NOT NULL DEFAULT 0,
    overtime_minutes INTEGER NOT NULL DEFAULT 0, 
    absence_minutes INTEGER NOT NULL DEFAULT 0,   
    status VARCHAR(50) NOT NULL                  
);
ALTER TABLE daily_time_records ADD PRIMARY KEY (id);
ALTER TABLE daily_time_records ADD CONSTRAINT uq_employee_daily_record UNIQUE (employee_id, record_date);

ALTER TABLE daily_time_records 
    ADD CONSTRAINT fk_daily_time_records_employees 
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE;

