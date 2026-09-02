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