-- #############################################################################
-- DQL - Consultas 11 a 15: horas por employer, extras acima de 2h, pontualidade, prazo de fechamento e folgas
-- Pré-requisito: DDL e DML executados (banco com esquema e dados de teste).
-- #############################################################################

-- =============================================================================
-- 11. Total de horas trabalhadas por employer
-- =============================================================================
SELECT c.name AS employer,
       COALESCE(SUM(da.hours_worked), 0) AS worked_minutes,
       ROUND(COALESCE(SUM(da.hours_worked), 0) / 60.0, 2) AS worked_hours
FROM companies c
LEFT JOIN branches b          ON b.company_id = c.id
LEFT JOIN departments d       ON d.branch_id = b.id
LEFT JOIN employees e         ON e.department_id = d.id
LEFT JOIN daily_apurations da ON da.employee_id = e.id
GROUP BY c.id, c.name
ORDER BY worked_hours DESC, c.name;

-- =============================================================================
-- 12. Colaboradores com mais de 2 horas extras em um único dia
-- =============================================================================
SELECT e.id AS employee_id,
       e.name AS employee_name,
       da.work_date AS record_date,
       da.overtime_50 + da.overtime_100 AS overtime_minutes,
       ROUND((da.overtime_50 + da.overtime_100) / 60.0, 2) AS overtime_hours
FROM daily_apurations da
INNER JOIN employees e ON e.id = da.employee_id
WHERE da.overtime_50 + da.overtime_100 > 120
ORDER BY da.work_date, e.name;

-- =============================================================================
-- 13. Pontualidade: desvio médio entre a entrada registrada e a prevista
-- Interpretação: valor positivo = atraso médio; negativo = antecipação média.
-- Regra: considera apenas dias trabalhados (WORKED) e a escala vigente no dia.
-- =============================================================================
WITH deviations AS (
    SELECT p.employee_id,
           EXTRACT(EPOCH FROM (p.punched_at::time - s.clock_in_time)) / 60 AS deviation_min
    FROM time_punches p
    INNER JOIN daily_apurations da ON da.employee_id = p.employee_id
                                  AND da.work_date   = p.punched_at::date
                                  AND da.day_status  = 'WORKED'
    INNER JOIN schedules sc        ON sc.id = da.schedule_id
    INNER JOIN shifts s            ON s.id = sc.shift_id
    WHERE p.punch_type = 'ENTRY'
)
SELECT e.id AS employee_id,
       e.name AS employee_name,
       COUNT(*) AS evaluated_entries,
       ROUND(AVG(dv.deviation_min), 2)      AS avg_deviation_minutes,
       ROUND(AVG(ABS(dv.deviation_min)), 2) AS avg_abs_deviation_minutes
FROM deviations dv
INNER JOIN employees e ON e.id = dv.employee_id
GROUP BY e.id, e.name
ORDER BY avg_deviation_minutes DESC, e.name;

-- =============================================================================
-- 14. Fechamentos de espelho de ponto realizados após o prazo legal
-- =============================================================================
SELECT c.name AS employer,
       b.name AS branch,
       ap.start_date,
       ap.end_date,
       ap.closing_deadline AS legal_deadline,
       ap.closed_at        AS closed_on,
       ap.closed_at::date - ap.closing_deadline AS days_late
FROM apuration_periods ap
INNER JOIN branches b  ON b.id = ap.branch_id
INNER JOIN companies c ON c.id = b.company_id
WHERE ap.is_closed
  AND ap.closed_at::date > ap.closing_deadline
ORDER BY days_late DESC, c.name, b.name;

-- =============================================================================
-- 15. Trabalho em dias classificados como folga
-- =============================================================================
SELECT e.id AS employee_id,
       e.name AS employee_name,
       da.work_date AS record_date,
       ROUND(da.hours_worked / 60.0, 2) AS worked_hours
FROM daily_apurations da
INNER JOIN employees e ON e.id = da.employee_id
WHERE da.day_status = 'DAY_OFF'
  AND da.hours_worked > 0
ORDER BY da.work_date, e.name;
