-- #############################################################################
-- DQL - Consultas 06 a 10: intervalo, biometria, jornada noturna, absenteísmo e extras por cargo
-- Pré-requisito: DDL e DML executados (banco com esquema e dados de teste).
-- #############################################################################

-- =============================================================================
-- 06. Média de horas extras por cargo
-- Regra: média, em horas, das extras (50% + 100%) por dia efetivamente
--        trabalhado (WORKED ou DAY_OFF com trabalho).
-- =============================================================================
SELECT jt.name AS cargo,
       COUNT(*) AS dias_apurados,
       ROUND(AVG(da.overtime_50 + da.overtime_100) / 60.0, 2) AS media_horas_extras_dia
FROM job_titles jt
INNER JOIN employees e         ON e.job_title_id = jt.id
INNER JOIN daily_apurations da ON da.employee_id = e.id
WHERE da.day_status IN ('WORKED', 'DAY_OFF')
GROUP BY jt.id, jt.name
ORDER BY media_horas_extras_dia DESC, jt.name;

-- =============================================================================
-- 07. Intervalo insuficiente (menor que 1 hora)
-- Regra: por colaborador/dia, intervalo = última BREAK_END - primeira BREAK_START.
--        Dias sem o par completo de marcações de intervalo não são avaliados.
-- =============================================================================
WITH breaks AS (
    SELECT employee_id,
           punched_at::date AS punch_date,
           MIN(punched_at) FILTER (WHERE punch_type = 'BREAK_START') AS break_start,
           MAX(punched_at) FILTER (WHERE punch_type = 'BREAK_END')   AS break_end
    FROM time_punches
    GROUP BY employee_id, punched_at::date
)
SELECT e.id AS matricula,
       e.name AS colaborador,
       b.punch_date AS data,
       ROUND(EXTRACT(EPOCH FROM (b.break_end - b.break_start)) / 60) AS intervalo_minutos
FROM breaks b
INNER JOIN employees e ON e.id = b.employee_id
WHERE b.break_start IS NOT NULL
  AND b.break_end   IS NOT NULL
  AND b.break_end - b.break_start < INTERVAL '1 hour'
ORDER BY b.punch_date, e.name;

-- =============================================================================
-- 08. Falhas de autenticação biométrica por colaborador
-- =============================================================================
SELECT e.id AS matricula,
       e.name AS colaborador,
       COUNT(ba.id) FILTER (WHERE NOT ba.is_success) AS qtd_falhas
FROM employees e
LEFT JOIN biometric_attempts ba ON ba.employee_id = e.id
GROUP BY e.id, e.name
HAVING COUNT(ba.id) FILTER (WHERE NOT ba.is_success) > 0
ORDER BY qtd_falhas DESC, e.name;

-- =============================================================================
-- 09. Jornada noturna: entrada antes das 05h ou saída após as 22h
-- =============================================================================
SELECT e.id AS matricula,
       e.name AS colaborador,
       COUNT(*) FILTER (WHERE p.punch_type = 'ENTRY' AND p.punched_at::time < TIME '05:00') AS entradas_antes_5h,
       COUNT(*) FILTER (WHERE p.punch_type = 'EXIT'  AND p.punched_at::time > TIME '22:00') AS saidas_apos_22h
FROM time_punches p
INNER JOIN employees e ON e.id = p.employee_id
WHERE (p.punch_type = 'ENTRY' AND p.punched_at::time < TIME '05:00')
   OR (p.punch_type = 'EXIT'  AND p.punched_at::time > TIME '22:00')
GROUP BY e.id, e.name
ORDER BY e.name;

-- =============================================================================
-- 10. Absenteísmo por departamento
-- Fórmula: minutos de ausência / minutos previstos x 100.
-- Regra: considera dias WORKED, ABSENCE e JUSTIFIED; afastamentos, feriados e
--        folgas não entram no denominador.
-- =============================================================================
SELECT d.name AS departamento,
       COALESCE(SUM(da.hours_absence), 0)  AS minutos_ausencia,
       COALESCE(SUM(da.hours_expected), 0) AS minutos_previstos,
       ROUND(100.0 * COALESCE(SUM(da.hours_absence), 0)
             / NULLIF(SUM(da.hours_expected), 0), 2) AS percentual_absenteismo
FROM departments d
LEFT JOIN employees e         ON e.department_id = d.id
LEFT JOIN daily_apurations da ON da.employee_id = e.id
                             AND da.day_status IN ('WORKED', 'ABSENCE', 'JUSTIFIED')
GROUP BY d.id, d.name
ORDER BY percentual_absenteismo DESC NULLS LAST, d.name;
