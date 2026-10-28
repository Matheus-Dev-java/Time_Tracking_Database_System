# Time Tracking Database System (Sistema de Ponto Eletrônico REP-P)

## Descrição

Banco de dados relacional (PostgreSQL) para controle de jornada e ponto eletrônico corporativo (REP-P): empregadores, colaboradores, escalas de trabalho, marcações de ponto (com geolocalização e biometria) e fechamento mensal de espelhos de ponto. O projeto segue a legislação trabalhista brasileira (CLT e Portaria 671/2021 do MTP), com scripts organizados por categoria (DDL, DML e DQL) e *stored procedures*.

## Objetivo

Modelar um banco de dados normalizado, com chaves primárias e estrangeiras, restrições de integridade de domínio (`constraints`) e nomenclatura padronizada (*Ovid Database Naming Standards*).

## Estrutura

| Pasta | Conteúdo |
|---|---|
| `DDL/` | `01_organization` · `02_access_control_audit` · `03_shifts_schedules` · `04_time_recording` · `05_apuration` · `06_occurrences_adjustments` · `07_leaves_holidays` · `08_procedures_support` |
| `DML/` | `01_foreign_keys` · `02_seed_data` · `03_seed_procedures_support` |
| `DQL/` | `01_overtime_delays_geofence_closings` (consultas 01–05) · `02_breaks_biometrics_night_absenteeism` (06–10) · `03_employer_hours_punctuality_deadlines` (11–15) · `04_weekend_devices_adjustments_payroll` (16–20) |
| `PROCEDURES/` | `01_register_time_punch` · `02_close_monthly_timesheet` · `03_excuse_absence_delay` · `04_recalculate_hour_bank` · `05_assign_work_schedule` · `99_test_calls` |
| `setup.sql` | Executa todos os scripts na ordem correta |

## Procedures (Grupo 3)

| Arquivo | Procedure | Função |
|---|---|---|
| `PROCEDURES/01_register_time_punch.sql` | `sp_registrar_marcacao_ponto` | Registra a marcação validando a geolocalização (raio da filial) e a rede (CIDR); divergências viram alertas em `punch_alerts`. |
| `PROCEDURES/02_close_monthly_timesheet.sql` | `sp_fechar_espelho_ponto_mensal` | Consolida horas trabalhadas, extras, adicional noturno e faltas em `timesheet_closings` e bloqueia o mês contra alterações (triggers). |
| `PROCEDURES/03_excuse_absence_delay.sql` | `sp_abonar_falta_atraso` | Abona falta ou atraso após validar o tipo de ocorrência e o documento; devolve as horas devidas restantes no mês. |
| `PROCEDURES/04_recalculate_hour_bank.sql` | `sp_recalcular_banco_horas` | Recalcula o saldo do banco de horas na janela de compensação (créditos de extras menos débitos de folgas). |
| `PROCEDURES/05_assign_work_schedule.sql` | `sp_vincular_escala_trabalho` | Vincula um turno a um grupo de colaboradores (tudo ou nada), sem conflitos, preservando o histórico em `employee_shifts`. |

> Os valores de `hours_*`, `overtime_*`, `night_hours` e os saldos estão em **minutos**.

## Módulo de ajustes de ponto e afastamentos

Tabelas `punch_adjustments` (`DDL/06`) e `leave_records` (`DDL/07`).

**`punch_adjustments`** — correções manuais de marcações esquecidas ou incorretas: `id` (PK), `adjusted_at`, `adjustment_type` (`inclusion` | `disregard`), `reason`, `status` (`pending` | `approved` | `rejected`).

**`leave_records`** — ausências justificadas, licenças e atestados: `id` (PK), `start_date`, `end_date`, `leave_kind`, `icd_code` (opcional, CID), `document_url`, `status`.

## Convenção de nomes

Arquivos, tabelas, colunas, variáveis e aliases estão em **inglês**. A única exceção são os 5 nomes de procedures, definidos no enunciado do trabalho (`sp_registrar_marcacao_ponto` e demais).
