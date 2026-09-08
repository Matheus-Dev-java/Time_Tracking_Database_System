--Shifts
-- Lista todos os turnos ordenados pelo horário de entrada
SELECT id, name, clock_in_time, clock_out_time, tolerance_minutes
FROM shifts
ORDER BY clock_in_time;

-- Turnos com tolerância de atraso maior que 10 minutos
SELECT id, name, tolerance_minutes
FROM shifts
WHERE tolerance_minutes > 10;

-- Quantidade de colaboradores alocados em cada turno
SELECT s.shift_name, COUNT(s.employee_id) AS total_colaboradores
FROM schedules s
GROUP BY s.shift_name
ORDER BY total_colaboradores DESC;

-- Turno com a maior carga de trabalho média associada
SELECT s.shift_name, AVG(s.workload) AS carga_media
FROM schedules s
GROUP BY s.shift_name
ORDER BY carga_media DESC
LIMIT 1;

--Schedules

-- Lista todas as escalas com o nome do colaborador
SELECT sc.id, e.name AS employee_name, sc.shift_name, sc.workload
FROM schedules sc
JOIN employees e ON e.id = sc.employee_id
ORDER BY e.name;

-- Escala de um colaborador específico
SELECT sc.id, e.name AS employee_name, sc.shift_name, sc.workload
FROM schedules sc
JOIN employees e ON e.id = sc.employee_id
WHERE sc.employee_id = 1;

-- Colaboradores com carga de trabalho acima de 200 horas
SELECT e.name, sc.shift_name, sc.workload
FROM schedules sc
JOIN employees e ON e.id = sc.employee_id
WHERE sc.workload > 200
ORDER BY sc.workload DESC;

-- Total de colaboradores por faixa de carga horária
SELECT
    CASE
        WHEN workload >= 200 THEN 'Integral'
        WHEN workload >= 150 THEN 'Parcial Estendida'
        ELSE 'Parcial'
    END AS faixa_carga,
    COUNT(*) AS total
FROM schedules
GROUP BY faixa_carga
ORDER BY total DESC;
