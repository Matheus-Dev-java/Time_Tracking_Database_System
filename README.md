# Time Tracking Database System

## Descrição do projeto

Banco de dados relacional em PostgreSQL para controle de jornada e ponto eletrônico (REP-P). O sistema reúne empregadores, departamentos, locais de trabalho com raio e rede permitidos, colaboradores, dispositivos, escalas, marcações, resumo diário, banco de horas, espelho de ponto mensal, ajustes, abonos, falhas de biometria e auditorias.

## Objetivo da solução

Registrar a marcação de ponto com integridade referencial, apurar horas trabalhadas, horas extras, atrasos, adicional noturno e faltas, e fechar o espelho do mês sem permitir alteração depois da assinatura. DDL, DML, procedures, functions, triggers, views e consultas trabalham sobre o mesmo modelo.

## Integrantes

- Matheus da Costa Pereira
- Luis Filipe Silva Lima
- Brendha Maria Costa Seixas

## Estrutura de pastas

```
time-tracking-database-system/
  README.md
  install.sql                  executa todos os scripts na ordem
  ddl/                         01_cleanup, 02_tables, 03_indexes
  dml/                         um arquivo por tabela (01 a 25) e 26_sequences
  procedures_functions/        funções auxiliares, funções de trigger e as 5 procedures
  triggers/                    os 5 triggers
  views/                       as 5 views
  dql/                         as 20 consultas, numeradas de 01 a 20
```

## Resumo do modelo

**Tabelas auxiliares** (3 ou mais registros): `device_type`, `punch_type`, `timesheet_status`, `record_status`, `adjustment_type`, `waiver_type` e `job_title`.

**Tabelas principais** (30 ou mais registros): `employer`, `department`, `work_location`, `employee`, `device`, `work_schedule`, `work_schedule_day`, `employee_schedule_history`, `time_punch`, `daily_summary`, `hour_bank_movement`, `hour_bank`, `timesheet`, `biometric_failure`, `punch_audit`, `punch_adjustment`, `absence_waiver` e `waiver_audit`.

Os dados cobrem as duas últimas semanas de outubro de 2026 (19 a 31/10), com 30 colaboradores em 30 empregadores. O espelho mensal segue de 01 a 31/10. As tabelas derivadas (`daily_summary`, `hour_bank_movement`, `hour_bank`, `timesheet`, `punch_audit`, `absence_waiver` e `waiver_audit`) foram geradas pelas próprias procedures, functions e triggers do banco. O IP da marcação usa `INET` e a rede permitida do local usa `CIDR`.

## Procedures

- `sp_registrar_marcacao_ponto`: grava a marcação, sinaliza divergência de raio e de rede e atualiza o resumo diário.
- `sp_fechar_espelho_ponto_mensal`: soma o resumo diário de um mês já encerrado, fecha e assina o espelho.
- `sp_abonar_falta_atraso`: exige documento, registra o abono e recalcula o resumo diário e os espelhos abertos.
- `sp_recalcular_banco_horas`: refaz os movimentos e o saldo do banco de horas de um período.
- `sp_vincular_escala_trabalho`: vincula uma escala a um grupo de colaboradores, recusando conflito de vigência.

## Triggers

- `tg_validar_intervalo_minimo_marcacoes`: bloqueia duas marcações do mesmo colaborador com menos de 5 minutos de diferença.
- `tg_alertar_divergencia_geolocalizacao`: grava auditoria quando a marcação está fora do raio do local.
- `tg_bloquear_alteracao_espelho_fechado`: impede inclusão, alteração e exclusão de marcações em espelho fechado e assinado.
- `tg_atualizar_banco_horas_diario`: atualiza movimento e saldo do banco de horas quando o resumo do dia muda.
- `tg_auditoria_justificativas_abono`: audita inclusão e alteração de abono com o usuário responsável.

## Views

- `vw_espelho_ponto_detalhado`: espelho diário com horários das marcações, atraso e hora extra.
- `vw_resumo_banco_horas_colaboradores`: saldo e vencimento do banco de horas dos colaboradores ativos por departamento.
- `vw_relatorio_inconsistencias_ponto`: alertas de auditoria, dias com marcações ímpares e intervalos insuficientes.
- `vw_demonstrativo_adicional_noturno`: minutos e horas trabalhados entre 22h e 5h por colaborador e mês.
- `vw_escalas_jornadas_vigentes`: escala vigente de cada colaborador ativo, com horários e dias de folga.

## Correções realizadas

- Todos os nomes de pastas, arquivos, tabelas, colunas, constraints, índices, variáveis, parâmetros, mensagens e valores auxiliares passaram para o inglês, exceto os nomes dos 5 procedures, 5 triggers e 5 views.
- DML dividido em um arquivo por tabela, na ordem de dependência, com IDs explícitos, crescentes e sem lacunas; DQL dividido em 20 arquivos.
- Volume de dados reduzido para 40 colaboradores e um mês de marcações, com nomes realistas e CPFs com dígitos verificadores válidos.
- `INET` para o IP da marcação e `CIDR` para a rede permitida do local.
- Chaves compostas garantem que o local do colaborador e o dispositivo da marcação pertençam ao mesmo empregador.
- `ON DELETE CASCADE` apenas em `work_schedule_day`; as demais chaves estrangeiras usam `RESTRICT`.
- `sp_fechar_espelho_ponto_mensal` recusa mês que ainda não terminou e mês sem resumo diário.
- A consulta de colaboradores sem registro cobre todos os dias de trabalho previstos do mês de referência.
- Removidas colunas e funções sem uso e o conteúdo alheio ao sistema.
- Volume enxugado para 30 colaboradores e marcações de 19 a 31/10/2026, com tabelas derivadas refeitas pelas funções do banco; `sp_vincular_escala_trabalho` recusa a mesma escala na data informada.
