# Time Tracking Database System (Sistema de Ponto Eletrônico REP-P)

## 🇧🇷 Descrição

Banco de dados relacional (PostgreSQL) para controle de jornada e ponto eletrônico corporativo (REP-P): empregadores, colaboradores, escalas, marcações de ponto (geolocalização/biometria) e fechamento mensal de espelhos de ponto. Baseado na CLT e na Portaria 671/2021 do MTP, com scripts organizados por categoria (DDL, DML, DQL) e *stored procedures*.

**Objetivo:** modelo normalizado, com chaves primárias/estrangeiras, *constraints* de domínio e nomenclatura padronizada (*Ovid Database Naming Standards*).

## 🇺🇸 Description

PostgreSQL relational database for corporate time and attendance control (REP-P): employers, employees, work schedules, time punches (geolocation/biometrics) and monthly timesheet closing. Based on Brazilian labor law (CLT, MTP Ordinance 671/2021); scripts are organized by category (DDL, DML, DQL) plus stored procedures.

## Estrutura / Structure

| Pasta / Folder | Conteúdo / Content |
|---|---|
| `DDL/` | `01_organization` · `02_access_control_audit` · `03_shifts_schedules` · `04_time_recording` · `05_apuration` · `06_occurrences_adjustments` · `07_leaves_holidays` · `08_procedures_support` |
| `DML/` | `01_foreign_keys` · `02_seed_data` · `03_seed_procedures_support` |
| `DQL/` | 20 consultas em 4 arquivos (01–05, 06–10, 11–15, 16–20) / 20 queries in 4 files |
| `PROCEDURES/` | `01_register_time_punch` · `02_close_monthly_timesheet` · `03_excuse_absence_delay` · `04_recalculate_hour_bank` · `05_assign_work_schedule` · `99_test_calls` |
| `setup.sql` | Executa tudo na ordem correta / Runs everything in order |

## Como executar / How to run

```bash
createdb ponto
psql -d ponto -f setup.sql          # na raiz do repositório / from the repo root
psql -d ponto -f PROCEDURES/99_test_calls.sql
```

## Procedures (Grupo 3)

| Procedure | Função / Purpose |
|---|---|
| `sp_registrar_marcacao_ponto` | Registra a marcação validando geolocalização (raio da filial) e rede (CIDR); divergências viram `punch_alerts`. / Registers a punch, validates geolocation and network, logs alerts. |
| `sp_fechar_espelho_ponto_mensal` | Consolida horas trabalhadas, extras, adicional noturno e faltas em `timesheet_closings` e bloqueia o mês (triggers). / Closes the month and locks it. |
| `sp_abonar_falta_atraso` | Abona falta/atraso após validar tipo e documento; devolve horas devidas restantes no mês. / Excuses absence/delay and returns remaining owed hours. |
| `sp_recalcular_banco_horas` | Recalcula o saldo na janela de compensação (créditos de extras − débitos de folgas). / Recomputes the hour-bank balance. |
| `sp_vincular_escala_trabalho` | Vincula turno a um grupo (tudo ou nada), sem conflitos, preservando o histórico em `employee_shifts`. / Assigns a shift to a group with no conflicts, keeping history. |

> Valores de `hours_*`, `overtime_*`, `night_hours` e saldos estão em **minutos** / are in **minutes**.

## Módulo de ajustes de ponto e afastamentos / Adjustments and leaves module

Tabelas / Tables: `punch_adjustments` (`DDL/06`) e/and `leave_records` (`DDL/07`).

**`punch_adjustments`** — correções manuais de marcações / manual punch corrections: `id` (PK), `adjusted_at`, `adjustment_type` (`inclusion` | `disregard`), `reason`, `status` (`pending` | `approved` | `rejected`).

**`leave_records`** — ausências justificadas / justified absences: `id` (PK), `start_date`, `end_date`, `leave_kind`, `icd_code` (opcional/optional), `document_url`, `status`.

## Convenção de nomes / Naming convention

Arquivos, tabelas, colunas, variáveis e aliases em **inglês** / files, tables, columns, variables and aliases in **English**. Única exceção / only exception: os 5 nomes de procedures definidos no enunciado do trabalho / the 5 procedure names fixed by the assignment (`sp_registrar_marcacao_ponto`, ...).
