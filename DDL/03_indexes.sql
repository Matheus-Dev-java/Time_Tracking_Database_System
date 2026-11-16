-- Indexes for the punch lookups, period filters and the joins used by queries and views.
CREATE INDEX idx_time_punch_employee_punched_at ON time_punch (employee_id, punched_at);
CREATE INDEX idx_employee_department ON employee (department_id);
CREATE INDEX idx_employee_job_title ON employee (job_title_id);
CREATE INDEX idx_daily_summary_work_date ON daily_summary (work_date);
CREATE INDEX idx_employee_schedule_history_employee ON employee_schedule_history (employee_id, start_date);
CREATE INDEX idx_timesheet_status ON timesheet (timesheet_status_id);
CREATE INDEX idx_biometric_failure_employee ON biometric_failure (employee_id);
CREATE INDEX idx_punch_audit_time_punch ON punch_audit (time_punch_id);
