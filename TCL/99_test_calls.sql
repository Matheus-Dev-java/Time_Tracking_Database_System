-- Chamadas de teste / Test calls (apos setup.sql). Cada bloco e independente do resultado esperado indicado.

-- 1) Marcacao valida (Matriz SP, dentro do raio e da rede)            -> VALID
CALL sp_registrar_marcacao_ponto(1, 1, 'ENTRY', -23.56140, -46.65600, '10.10.5.20', '2026-10-27 08:00:00', NULL, NULL);
-- 1b) Fora do raio e fora da rede                                      -> DIVERGENT + 2 alertas
CALL sp_registrar_marcacao_ponto(1, 1, 'EXIT',  -23.60000, -46.70000, '200.10.10.10', '2026-10-27 17:00:00', NULL, NULL);
-- 1c) App sem coordenadas (equipamento 7 exige geolocalizacao)         -> DIVERGENT
CALL sp_registrar_marcacao_ponto(11, 7, 'ENTRY', NULL, NULL, NULL, '2026-10-27 09:00:00', NULL, NULL);
SELECT p.id, p.punch_type, p.location_status, a.alert_type, a.distance_meters, a.description
  FROM time_punches p LEFT JOIN punch_alerts a ON a.time_punch_id = p.id WHERE p.id >= 1000 ORDER BY p.id, a.id;

-- 3) Abono: colaborador 1, dia 2026-09-03 (30 min de atraso), tipo 1 (nao exige documento) -> saldo devido do mes = 0
CALL sp_abonar_falta_atraso(1, '2026-09-03', 1, 2, NULL, NULL, 'Esquecimento de marcacao', NULL);

-- 4) Banco de horas set/2026 do colaborador 1: credito 60, debito 40  -> saldo 20
CALL sp_recalcular_banco_horas(1, '2026-09-01', '2026-09-30', NULL);

-- 5) Escala: colaboradores 1 e 2 passam para o turno 2 em 2026-11-01  -> 2
CALL sp_vincular_escala_trabalho(2, ARRAY[1,2], '2026-11-01', 1, NULL);
-- 5b) Repetir gera conflito (ja ha escala iniciando em 2026-11-01)     -> ERRO
-- CALL sp_vincular_escala_trabalho(3, ARRAY[1,2], '2026-11-01', 1, NULL);

-- 2) Fechamento de setembro/2026 do colaborador 3 (sem pendencias)    -> id do fechamento
CALL sp_fechar_espelho_ponto_mensal(3, '2026-09-15', 2, NULL);
-- 2b) Colaborador 1 tem ocorrencia PENDENTE                            -> ERRO
-- CALL sp_fechar_espelho_ponto_mensal(1, '2026-09-15', 2, NULL);
-- 2c) Apos fechar, alterar o mes e bloqueado                           -> ERRO
-- UPDATE daily_apurations SET hours_worked = 1 WHERE employee_id = 3;
