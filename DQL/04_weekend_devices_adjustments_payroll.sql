-- #############################################################################
-- DQL - Consultas 16 a 20: fim de semana, devices, ajustes manuais, saída esquecida e folha
-- Pré-requisito: DDL e DML executados (banco com esquema e dados de teste).
-- #############################################################################

-- =============================================================================
-- 16. Total de horas trabalhadas por employee_name nos finais de semana
-- (ISODOW: 6 = sábado, 7 = domingo)
-- =============================================================================
SELECT e.id AS employee_id,
       e.name AS employee_name,
       SUM(da.hours_worked) AS worked_minutes,
       ROUND(SUM(da.hours_worked) / 60.0, 2) AS worked_hours
FROM daily_apurations da
INNER JOIN employees e ON e.id = da.employee_id
WHERE EXTRACT(ISODOW FROM da.work_date) IN (6, 7)
  AND da.hours_worked > 0
GROUP BY e.id, e.name
ORDER BY worked_hours DESC, e.name;

-- =============================================================================
-- 17. Divergência de devices: registros em mais de um equipamento de ponto
-- =============================================================================
SELECT e.id AS employee_id,
       e.name AS employee_name,
       COUNT(DISTINCT p.clock_device_id) AS device_count,
       STRING_AGG(DISTINCT cd.location, ' | ' ORDER BY cd.location) AS devices
FROM time_punches p
INNER JOIN employees e      ON e.id  = p.employee_id
INNER JOIN clock_devices cd ON cd.id = p.clock_device_id
GROUP BY e.id, e.name
HAVING COUNT(DISTINCT p.clock_device_id) > 1
ORDER BY device_count DESC, e.name;

-- =============================================================================
-- 18. Ajustes manuais de ponto aprovados
-- Data do ajuste = record_date do dia apurado ao qual a ocorrência se refere.
-- =============================================================================
SELECT e.name AS employee_name,
       ot.name AS adjustment_type,
       o.description AS reason,
       da.work_date AS adjustment_date
FROM occurrences o
INNER JOIN daily_apurations da ON da.id = o.daily_apuration_id
INNER JOIN employees e         ON e.id  = da.employee_id
INNER JOIN occurrence_types ot ON ot.id = o.occurrence_type_id
WHERE o.status = 'APPROVED'
ORDER BY da.work_date, e.name;

-- =============================================================================
-- 19. Esquecimento de marcação: registros de entrada sem saída correspondente
-- Regra: ENTRY sem nenhum EXIT nas 16 horas seguintes (cobre shift noturno).
-- =============================================================================
SELECT e.id AS employee_id,
       e.name AS employee_name,
       COUNT(*) AS missing_exit_count
FROM time_punches p
INNER JOIN employees e ON e.id = p.employee_id
WHERE p.punch_type = 'ENTRY'
  AND NOT EXISTS (
      SELECT 1
      FROM time_punches x
      WHERE x.employee_id = p.employee_id
        AND x.punch_type  = 'EXIT'
        AND x.punched_at  > p.punched_at
        AND x.punched_at <= p.punched_at + INTERVAL '16 hours'
  )
GROUP BY e.id, e.name
ORDER BY missing_exit_count DESC, e.name;

-- =============================================================================
-- 20. Relatório para folha de pagamento: CPF, nome e total de horas do mês
-- Para outro mês, altere as DUAS ocorrências de DATE '2026-09-01' (1º dia do mês).
-- =============================================================================
SELECT e.cpf,
       e.name AS employee_name,
       COALESCE(SUM(da.hours_worked), 0) AS worked_minutes,
       (COALESCE(SUM(da.hours_worked), 0) / 60)::text || ':' ||
       LPAD((COALESCE(SUM(da.hours_worked), 0) % 60)::text, 2, '0') AS total_hours_hhmm
FROM employees e
LEFT JOIN daily_apurations da ON da.employee_id = e.id
                             AND da.work_date >= DATE '2026-09-01'
                             AND da.work_date <  DATE '2026-09-01' + INTERVAL '1 month'
GROUP BY e.id, e.cpf, e.name
ORDER BY e.name;
