-- #############################################################################
-- DQL - Consultas 11 a 15: horas por empregador, extras acima de 2h, pontualidade, prazo de fechamento e folgas
-- Pré-requisito: DDL e DML executados (banco com esquema e dados de teste).
-- #############################################################################

-- =============================================================================
-- 11. Total de horas trabalhadas por empregador
-- =============================================================================
SELECT c.name AS empregador,
       COALESCE(SUM(da.hours_worked), 0) AS minutos_trabalhados,
       ROUND(COALESCE(SUM(da.hours_worked), 0) / 60.0, 2) AS horas_trabalhadas
FROM companies c
LEFT JOIN branches b          ON b.company_id = c.id
LEFT JOIN departments d       ON d.branch_id = b.id
LEFT JOIN employees e         ON e.department_id = d.id
LEFT JOIN daily_apurations da ON da.employee_id = e.id
GROUP BY c.id, c.name
ORDER BY horas_trabalhadas DESC, c.name;

-- =============================================================================
-- 12. Colaboradores com mais de 2 horas extras em um único dia
-- =============================================================================
SELECT e.id AS matricula,
       e.name AS colaborador,
       da.work_date AS data,
       da.overtime_50 + da.overtime_100 AS minutos_extras,
       ROUND((da.overtime_50 + da.overtime_100) / 60.0, 2) AS horas_extras
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
SELECT e.id AS matricula,
       e.name AS colaborador,
       COUNT(*) AS entradas_avaliadas,
       ROUND(AVG(dv.deviation_min), 2)      AS desvio_medio_minutos,
       ROUND(AVG(ABS(dv.deviation_min)), 2) AS desvio_medio_absoluto_minutos
FROM deviations dv
INNER JOIN employees e ON e.id = dv.employee_id
GROUP BY e.id, e.name
ORDER BY desvio_medio_minutos DESC, e.name;

-- =============================================================================
-- 14. Fechamentos de espelho de ponto realizados após o prazo legal
-- =============================================================================
SELECT c.name AS empregador,
       b.name AS filial,
       ap.start_date,
       ap.end_date,
       ap.closing_deadline AS prazo_legal,
       ap.closed_at        AS fechado_em,
       ap.closed_at::date - ap.closing_deadline AS dias_de_atraso
FROM apuration_periods ap
INNER JOIN branches b  ON b.id = ap.branch_id
INNER JOIN companies c ON c.id = b.company_id
WHERE ap.is_closed
  AND ap.closed_at::date > ap.closing_deadline
ORDER BY dias_de_atraso DESC, c.name, b.name;

-- =============================================================================
-- 15. Trabalho em dias classificados como folga
-- =============================================================================
SELECT e.id AS matricula,
       e.name AS colaborador,
       da.work_date AS data,
       ROUND(da.hours_worked / 60.0, 2) AS horas_trabalhadas
FROM daily_apurations da
INNER JOIN employees e ON e.id = da.employee_id
WHERE da.day_status = 'DAY_OFF'
  AND da.hours_worked > 0
ORDER BY da.work_date, e.name;
