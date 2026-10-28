-- =============================================================================
-- 01. Horas extras: saldo por employee_name (horas realizadas - carga prevista)
-- Regra: considera dias trabalhados, faltas e dias de folga trabalhados.
--        Afastamentos, justificados e feriados não geram débito/crédito.
-- =============================================================================
SELECT e.id AS employee_id,
       e.name AS employee_name,
       SUM(da.hours_worked) AS actual_minutes,
       SUM(da.hours_expected) AS expected_minutes,
       SUM(da.hours_worked - da.hours_expected)   AS balance_minutes,
       ROUND(SUM(da.hours_worked - da.hours_expected) / 60.0, 2) AS balance_hours
FROM daily_apurations da
INNER JOIN employees e ON e.id = da.employee_id
WHERE da.day_status IN ('WORKED', 'ABSENCE', 'DAY_OFF')
GROUP BY e.id, e.name
ORDER BY balance_minutes DESC, e.name;

-- =============================================================================
-- 02. Atrasos por department
-- Regra: atraso = marcação de ENTRADA em dia trabalhado posterior ao horário
--        de entrada do shift acrescido da tolerância (shifts.tolerance_minutes).
-- =============================================================================
SELECT d.name AS department,
       COUNT(late.punch_id) AS late_count
FROM departments d
LEFT JOIN (
    SELECT e.department_id, p.id AS punch_id
    FROM time_punches p
    INNER JOIN employees e ON e.id = p.employee_id
    INNER JOIN daily_apurations da ON da.employee_id = p.employee_id AND da.work_date   = p.punched_at::date AND da.day_status  = 'WORKED'
    INNER JOIN schedules sc ON sc.id = da.schedule_id
    INNER JOIN shifts s ON s.id = sc.shift_id
    WHERE p.punch_type = 'ENTRY'
      AND p.punched_at::time > s.clock_in_time + s.tolerance_minutes * INTERVAL '1 minute'
) late ON late.department_id = d.id
GROUP BY d.id, d.name
ORDER BY late_count DESC, d.name;

-- =============================================================================
-- 03. Colaboradores com escala ativa e sem registro de ponto no dia
-- Regra: dia com jornada prevista (WORKED/ABSENCE), escala vigente na record_date e
--        nenhuma marcação em time_punches naquela record_date.
-- =============================================================================
SELECT e.id AS employee_id,
       e.name AS employee_name,
       da.work_date AS record_date,
       s.name AS shift
FROM daily_apurations da
INNER JOIN employees e  ON e.id = da.employee_id
INNER JOIN schedules sc ON sc.id = da.schedule_id AND da.work_date >= sc.start_dateAND da.work_date <= COALESCE(sc.end_date, DATE 'infinity')
INNER JOIN shifts s  ON s.id = sc.shift_id
WHERE da.hours_expected > 0
  AND da.day_status IN ('WORKED', 'ABSENCE')
  AND NOT EXISTS (
      SELECT 1
      FROM time_punches p
      WHERE p.employee_id = da.employee_id
        AND p.punched_at::date = da.work_date
  )
ORDER BY da.work_date, e.name;

-- =============================================================================
-- 04. Marcações fora do perímetro permitido
-- Regra: distância (Haversine) entre a coordenada da marcação e o centro da
--        branch do equipamento maior que branches.geofence_radius_m.
--        Marcações sem coordenadas (REP-P físico) não são avaliadas.
-- =============================================================================
SELECT e.name AS employee_name,
       p.punched_at::date AS record_date,
       p.punch_type AS punch_kind,
       p.latitude,
       p.longitude,
       ROUND(g.meters::numeric)  AS distance_meters, b.geofence_radius_m AS allowed_radius_m
FROM time_punches p
INNER JOIN employees e ON e.id  = p.employee_id
INNER JOIN clock_devices cd ON cd.id = p.clock_device_id
INNER JOIN branches b ON b.id  = cd.branch_id
CROSS JOIN LATERAL (
    SELECT fn_distance_meters(p.latitude, p.longitude, b.latitude, b.longitude) AS meters
) 
WHERE p.latitude IS NOT NULL
  AND g.meters > b.geofence_radius_m
ORDER BY p.punched_at;

-- =============================================================================
-- 05. Fechamentos de espelho de ponto pendentes por employer
-- =============================================================================
SELECT c.name AS employer,
       COUNT(ap.id) AS pending_closings
FROM companies c
LEFT JOIN branches b ON b.company_id = c.id
LEFT JOIN apuration_periods ap ON ap.branch_id = b.id 
AND ap.is_closed = FALSE
GROUP BY c.id, c.name
ORDER BY pending_closings DESC, c.name;
