-- DML 03 | Dados de exemplo para as procedures / Sample data for the procedures
-- Coordenadas e redes sao ficticias/aproximadas, apenas para teste.

UPDATE branches SET latitude = -23.56135, longitude = -46.65591, geofence_radius_m = 150, allowed_network = '10.10.0.0/16' WHERE id = 1;
UPDATE branches SET latitude = -22.90278, longitude = -43.17283, geofence_radius_m = 150, allowed_network = '10.20.0.0/16' WHERE id = 2;
UPDATE branches SET latitude = -22.90556, longitude = -47.06083, geofence_radius_m = 200, allowed_network = '10.30.0.0/16' WHERE id = 3;
UPDATE branches SET latitude = -23.35500, longitude = -46.87800, geofence_radius_m = 500, allowed_network = '10.40.0.0/16' WHERE id = 4;
UPDATE branches SET latitude = -23.57120, longitude = -46.64650, geofence_radius_m = 100, allowed_network = '10.50.0.0/16' WHERE id = 5;
UPDATE branches SET latitude = -23.96083, longitude = -46.33361, geofence_radius_m = 500, allowed_network = '10.60.0.0/16' WHERE id = 6;

UPDATE clock_devices SET requires_geolocation = TRUE WHERE id = 7;  -- REP-A (aplicativo)

-- Historico de jornadas vigentes (aproximacao dos nomes de escala em schedules)
INSERT INTO employee_shifts (id, employee_id, shift_id, start_date, end_date) VALUES
(1,  1, 1, '2026-01-01', NULL), (2,  2, 1, '2026-01-01', NULL), (3,  3, 2, '2026-01-01', NULL),
(4,  4, 2, '2026-01-01', NULL), (5,  5, 2, '2026-01-01', NULL), (6,  6, 4, '2026-01-01', NULL),
(7,  7, 1, '2026-01-01', NULL), (8,  8, 1, '2026-01-01', NULL), (9,  9, 3, '2026-01-01', NULL),
(10,10, 4, '2026-01-01', NULL), (11,11, 1, '2026-01-01', NULL), (12,12, 1, '2026-01-01', NULL),
(13,13, 3, '2026-01-01', NULL), (14,14, 3, '2026-01-01', NULL), (15,15, 1, '2026-01-01', NULL),
(16,16, 2, '2026-01-01', NULL), (17,17, 1, '2026-01-01', NULL), (18,18, 2, '2026-01-01', NULL),
(19,19, 5, '2026-01-01', NULL), (20,20, 3, '2026-01-01', NULL);

-- Folga compensada pelo banco de horas (debito)
INSERT INTO hour_bank_movements (id, employee_id, movement_date, movement_type, minutes, notes) VALUES
(1, 1, '2026-09-04', 'DAY_OFF_DEBIT', 40, 'Saida antecipada compensada');
