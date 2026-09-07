-- =============================================================================
-- TIME TRACKING DATABASE SYSTEM - ALL-IN-ONE LOCAL SETUP SCRIPT
-- PostgreSQL 12+
-- Este script cria todas as tabelas (DDL), chaves estrangeiras e popula os dados (SEED)
-- Pode ser executado integralmente no DBeaver, pgAdmin, VS Code ou via psql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. LIMPEZA PREVENTIVA (DROP TABLE IF EXISTS ... CASCADE)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS occurrences CASCADE;
DROP TABLE IF EXISTS daily_apurations CASCADE;
DROP TABLE IF EXISTS time_punches CASCADE;
DROP TABLE IF EXISTS leaves CASCADE;
DROP TABLE IF EXISTS schedules CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS clock_devices CASCADE;
DROP TABLE IF EXISTS holidays CASCADE;
DROP TABLE IF EXISTS apuration_periods CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS branches CASCADE;
DROP TABLE IF EXISTS companies CASCADE;
DROP TABLE IF EXISTS permission_profiles CASCADE;
DROP TABLE IF EXISTS shifts CASCADE;
DROP TABLE IF EXISTS job_titles CASCADE;
DROP TABLE IF EXISTS occurrence_types CASCADE;
DROP TABLE IF EXISTS leave_types CASCADE;


-- =============================================================================
-- 1. DDL: CRIAÇÃO DE TABELAS, CHAVES PRIMÁRIAS E ÍNDICES
-- =============================================================================

-- --- Tabela: companies.sql ---
﻿CREATE TABLE companies (
    id   BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    cnpj VARCHAR(255) NOT NULL
);
ALTER TABLE companies ADD PRIMARY KEY (id);


-- --- Tabela: branches.sql ---
﻿CREATE TABLE branches (
    id         BIGINT       NOT NULL,
    name       VARCHAR(255) NOT NULL,
    company_id BIGINT       NOT NULL   -- FK -> companies.id
);
ALTER TABLE branches ADD PRIMARY KEY (id);
CREATE INDEX idx_branches_company_id ON branches (company_id);


-- --- Tabela: departments.sql ---
﻿CREATE TABLE departments (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    branch_id BIGINT NOT NULL   -- FK -> branches.id
);
ALTER TABLE departments ADD PRIMARY KEY (id);
CREATE INDEX idx_departments_branch_id ON departments (branch_id);


-- --- Tabela: job_titles.sql ---
CREATE TABLE job_titles (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    cbo VARCHAR(255) NOT NULL -- Brazilian Occupation Code
);
ALTER TABLE job_titles ADD PRIMARY KEY (id);


-- --- Tabela: shifts.sql ---
CREATE TABLE shifts (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    clock_in_time TIME(0) WITHOUT TIME ZONE NOT NULL,
    beak_start_time TIME(0) WITHOUT TIME ZONE NOT NULL,   
    break_end_time TIME(0) WITHOUT TIME ZONE NOT NULL,   
    clock_out_time TIME(0) WITHOUT TIME ZONE NOT NULL,  
    tolerance_minutes INTEGER NOT NULL                 
);

ALTER TABLE shifts ADD PRIMARY KEY (id);


-- --- Tabela: permission_profiles.sql ---
CREATE TABLE permission_profiles (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    access_level INTEGER NOT NULL -- 1=Admin | 2=HR | 3=Manager | 4=Employee
);
ALTER TABLE permission_profiles ADD PRIMARY KEY (id);


-- --- Tabela: ocurrences_types.sql ---
CREATE TABLE occurrence_types (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    grants_hours BOOLEAN NOT NULL, -- TRUE = absence is paid / hours are not deducted
    requires_doc BOOLEAN NOT NULL -- TRUE = employee must upload a proof document
);
ALTER TABLE occurrence_types ADD PRIMARY KEY (id);


-- --- Tabela: leave_types.sql ---
CREATE TABLE leave_types (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    code INTEGER NOT NULL,
    is_paid BOOLEAN NOT NULL -- TRUE = absence is paid / remunerated
);
ALTER TABLE leave_types ADD PRIMARY KEY (id);


-- --- Tabela: employees.sql ---
CREATE TABLE employees (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    department_id BIGINT NOT NULL,   -- FK -> departments.id
    id_document VARCHAR(255) NOT NULL,   -- CPF, RG or CNH
    birth_date DATE NOT NULL
);
COMMENT ON COLUMN employees.id_document IS 'CPF, RG or CNH';
ALTER TABLE employees ADD PRIMARY KEY (id);
CREATE INDEX idx_employees_department_id ON employees (department_id);


-- --- Tabela: users.sql ---
CREATE TABLE users (
    id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL, -- FK -> employees.id (NULL for standalone admins)
    profile_id BIGINT NOT NULL, -- FK -> permission_profiles.id
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL, -- Hashed with bcrypt / argon2; NEVER plain text
    is_active BOOLEAN NOT NULL,
    last_login TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL
);
ALTER TABLE users ADD PRIMARY KEY (id);


-- --- Tabela: schedules.sql ---
CREATE TABLE schedules (
    id BIGINT NOT NULL,
    shift_name VARCHAR(255) NOT NULL, 
    workload INTEGER NOT NULL, 
    employee_id BIGINT NOT NULL 
);

ALTER TABLE schedules ADD PRIMARY KEY (id);
CREATE INDEX idx_schedules_employee_id ON schedules (employee_id);

ALTER TABLE schedules
    ADD CONSTRAINT fk_schedules_employee
    FOREIGN KEY (employee_id) REFERENCES employees (id);


-- --- Tabela: clock_devices.sql ---
CREATE TABLE clock_devices (
    id BIGINT NOT NULL,
    branch_id BIGINT NOT NULL, -- FK -> branches.id
    department_id BIGINT NOT NULL, -- FK -> departments.id
    location VARCHAR(255) NOT NULL, -- Physical location description
    model_name VARCHAR(255) NOT NULL -- Device model / app name
);
ALTER TABLE clock_devices ADD PRIMARY KEY (id);
CREATE INDEX idx_clock_devices_branch_id ON clock_devices (branch_id);
CREATE INDEX idx_clock_devices_department_id ON clock_devices (department_id);


-- --- Tabela: time_punches.sql ---
CREATE TABLE time_punches (
    id BIGINT NOT NULL,
    punched_at DATE NOT NULL, -- Timestamp of the punch
    employee_id BIGINT NOT NULL, -- FK -> employees.id
    device_id BIGINT NOT NULL -- FK -> clock_devices.id
);
ALTER TABLE time_punches ADD PRIMARY KEY (id);
CREATE INDEX idx_time_punches_employee_id ON time_punches (employee_id);
CREATE INDEX idx_time_punches_device_id   ON time_punches (device_id);


-- --- Tabela: apuration_periods.sql ---
CREATE TABLE apuration_periods (
    id BIGINT NOT NULL,
    branch_id BIGINT NOT NULL, -- FK -> branches.id
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_closed BOOLEAN NOT NULL, -- TRUE = locked; no further edits allowed
    closed_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    closed_by_user BIGINT NOT NULL -- FK -> users.id
);
ALTER TABLE apuration_periods ADD PRIMARY KEY (id);
CREATE INDEX idx_apuration_periods_branch_id ON apuration_periods (branch_id);
CREATE INDEX idx_apuration_periods_closed_by_user ON apuration_periods (closed_by_user);


-- --- Tabela: daily_apurations.sql ---
CREATE TABLE daily_apurations (
    id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL, -- FK -> employees.id
    apuration_period_id INTEGER NOT NULL, -- FK -> apuration_periods.id
    schedule_id BIGINT NOT NULL, -- FK -> schedules.id (shift in effect that day)
    date DATE NOT NULL,
    hours_worked INTEGER NOT NULL, -- In minutes
    hours_expected INTEGER NOT NULL, -- In minutes
    overtime_50 INTEGER NOT NULL, -- Overtime at 50 % rate (minutes)
    overtime_100 INTEGER NOT NULL, -- Overtime at 100 % rate (minutes)
    hours_absence INTEGER NOT NULL, -- Missing/absent minutes
    night_hours INTEGER NOT NULL, -- Night-shift additional hours (minutes)
    day_status VARCHAR(255) NOT NULL -- WORKED | ABSENCE | JUSTIFIED | LEAVE | HOLIDAY | DAY_OFF
);
ALTER TABLE daily_apurations ADD PRIMARY KEY (id);
CREATE INDEX idx_daily_apurations_employee_id ON daily_apurations (employee_id);
CREATE INDEX idx_daily_apurations_schedule_id ON daily_apurations (schedule_id);


-- --- Tabela: ocurrences.sql ---
CREATE TABLE occurrences (
    id BIGINT NOT NULL,
    daily_apuration_id BIGINT NOT NULL, -- FK -> daily_apurations.id
    occurrence_type_id BIGINT NOT NULL, -- FK -> occurrence_types.id
    description VARCHAR(255) NOT NULL,
    attachment_url VARCHAR(255) NOT NULL,
    status VARCHAR(255) NOT NULL -- PENDING | APPROVED | REJECTED
);
ALTER TABLE occurrences ADD PRIMARY KEY (id);
CREATE INDEX idx_occurrences_daily_apuration_id ON occurrences (daily_apuration_id);
CREATE INDEX idx_occurrences_occurrence_type_id ON occurrences (occurrence_type_id);


-- --- Tabela: leaves.sql ---
CREATE TABLE leaves (
    id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL, -- FK -> employees.id
    leave_type_id BIGINT NOT NULL, -- FK -> leave_types.id
    start_date DATE NOT NULL,
    end_date DATE NOT NULL, -- May be NULL for open-ended INSS leaves
    cid VARCHAR(255) NOT NULL, -- ICD code (sensitive / LGPD)
    document_url VARCHAR(255) NOT NULL -- Medical certificate or vacation notice PDF
);
ALTER TABLE leaves ADD PRIMARY KEY (id);
CREATE INDEX idx_leaves_employee_id   ON leaves (employee_id);
CREATE INDEX idx_leaves_leave_type_id ON leaves (leave_type_id);


-- --- Tabela: holidays.sql ---
CREATE TABLE holidays (
    id BIGINT NOT NULL,
    date DATE NOT NULL,
    description VARCHAR(255) NOT NULL,
    type VARCHAR(255) NOT NULL, -- NATIONAL | STATE | MUNICIPAL | OPTIONAL
    state_code VARCHAR(255) NOT NULL, -- UF code; NULL for national holidays
    branch_id BIGINT NOT NULL, -- FK -> branches.id; NULL for non-municipal
    recurring BOOLEAN NOT NULL -- TRUE = repeats every year (e.g. Christmas)
);
ALTER TABLE holidays ADD PRIMARY KEY (id);
CREATE INDEX idx_holidays_branch_id ON holidays (branch_id);


-- --- Tabela: audit_logs.sql ---
CREATE TABLE audit_logs (
    id BIGINT NOT NULL,
    user_id BIGINT NOT NULL, -- FK -> users.id (who made the change)
    action VARCHAR(255) NOT NULL, -- INSERT | UPDATE | DELETE
    affected_table VARCHAR(255) NOT NULL,   -- Name of the changed table
    record_id BIGINT NOT NULL, -- PK of the changed row
    old_data JSON NOT NULL, -- State before the change
    new_data JSON NOT NULL, -- State after the change
    changed_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL
);
ALTER TABLE audit_logs ADD PRIMARY KEY (id);


-- =============================================================================
-- 2. DDL: CHAVES ESTRANGEIRAS (FOREIGN KEYS)
-- =============================================================================

-- --- Constraints de: fk_branches_departments_employees.sql ---
﻿ALTER TABLE branches
    ADD CONSTRAINT fk_branches_company
    FOREIGN KEY (company_id) REFERENCES companies (id);
-- departments -> branches
ALTER TABLE departments
    ADD CONSTRAINT fk_departments_branch
    FOREIGN KEY (branch_id) REFERENCES branches (id);
-- employees -> departments
ALTER TABLE employees
    ADD CONSTRAINT fk_employees_department
    FOREIGN KEY (department_id) REFERENCES departments (id);


-- --- Constraints de: fk_clockDevices_timePunches_apuration.sql ---
-- clock_devices -> branches
ALTER TABLE clock_devices
    ADD CONSTRAINT fk_clock_devices_branch
    FOREIGN KEY (branch_id) REFERENCES branches (id);

-- clock_devices -> departments
ALTER TABLE clock_devices
    ADD CONSTRAINT fk_clock_devices_department
    FOREIGN KEY (department_id) REFERENCES departments (id);

-- time_punches -> employees
ALTER TABLE time_punches
    ADD CONSTRAINT fk_time_punches_employee
    FOREIGN KEY (employee_id) REFERENCES employees (id);

-- time_punches -> clock_devices
ALTER TABLE time_punches
    ADD CONSTRAINT fk_time_punches_device
    FOREIGN KEY (device_id) REFERENCES clock_devices (id);
    
-- apuration_periods -> branches
ALTER TABLE apuration_periods
    ADD CONSTRAINT fk_apuration_periods_branch
    FOREIGN KEY (branch_id) REFERENCES branches (id);

-- apuration_periods -> users (who closed the period)
ALTER TABLE apuration_periods
    ADD CONSTRAINT fk_apuration_periods_closed_by
    FOREIGN KEY (closed_by_user) REFERENCES users (id);

-- daily_apurations -> employees
ALTER TABLE daily_apurations
    ADD CONSTRAINT fk_daily_apurations_employee
    FOREIGN KEY (employee_id) REFERENCES employees (id);

-- daily_apurations -> schedules (shift in effect that day)
ALTER TABLE daily_apurations
    ADD CONSTRAINT fk_daily_apurations_schedule
    FOREIGN KEY (schedule_id) REFERENCES schedules (id);


-- --- Constraints de: fk_occurrences_leaves_holidays_users_auditLogs.sql ---
-- occurrences -> daily_apurations
ALTER TABLE occurrences
    ADD CONSTRAINT fk_occurrences_daily_apuration
    FOREIGN KEY (daily_apuration_id) REFERENCES daily_apurations (id);

-- occurrences -> occurrence_types
ALTER TABLE occurrences
    ADD CONSTRAINT fk_occurrences_occurrence_type
    FOREIGN KEY (occurrence_type_id) REFERENCES occurrence_types (id);

-- leaves -> employees
ALTER TABLE leaves
    ADD CONSTRAINT fk_leaves_employee
    FOREIGN KEY (employee_id) REFERENCES employees (id);

-- leaves -> leave_types
ALTER TABLE leaves
    ADD CONSTRAINT fk_leaves_leave_type
    FOREIGN KEY (leave_type_id) REFERENCES leave_types (id);

-- holidays -> branches (for municipal/optional holidays)
ALTER TABLE holidays
    ADD CONSTRAINT fk_holidays_branch
    FOREIGN KEY (branch_id) REFERENCES branches (id);

-- users -> employees
ALTER TABLE users
    ADD CONSTRAINT fk_users_employee
    FOREIGN KEY (employee_id) REFERENCES employees (id);

-- users -> permission_profiles
ALTER TABLE users
    ADD CONSTRAINT fk_users_profile
    FOREIGN KEY (profile_id) REFERENCES permission_profiles (id);

-- audit_logs -> users
ALTER TABLE audit_logs
    ADD CONSTRAINT fk_audit_logs_user
    FOREIGN KEY (user_id) REFERENCES users (id);

-- daily_apurations -> apuration_periods
ALTER TABLE daily_apurations
    ADD CONSTRAINT fk_daily_apurations_period
    FOREIGN KEY (apuration_period_id) REFERENCES apuration_periods (id);


-- =============================================================================
-- 3. DML: CARGA INICIAL DE DADOS (SEED DATA)
-- =============================================================================

-- =============================================================================
-- SEED DATA (DML) - Time Tracking Database System
-- Povoamento de dados de teste com integridade referencial estrita
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. COMPANIES (Empresas)
-- -----------------------------------------------------------------------------
INSERT INTO companies (id, name, cnpj) VALUES
(1, 'TechCorp Soluções Tecnológicas S.A.', '12.345.678/0001-90'),
(2, 'Varejo Global Brasil Ltda.', '98.765.432/0001-10'),
(3, 'Logística & Transporte Veloz S.A.', '45.879.123/0001-55');

-- -----------------------------------------------------------------------------
-- 2. BRANCHES (Filiais)
-- -----------------------------------------------------------------------------
INSERT INTO branches (id, name, company_id) VALUES
(1, 'TechCorp - Matriz São Paulo', 1),
(2, 'TechCorp - Filial Rio de Janeiro', 1),
(3, 'TechCorp - Polo Tecnológico Campinas', 1),
(4, 'Varejo Global - Centro de Distribuição Cajamar', 2),
(5, 'Varejo Global - Loja Shopping Paulista', 2),
(6, 'Logística Veloz - Base Operacional Santos', 3);

-- -----------------------------------------------------------------------------
-- 3. DEPARTMENTS (Departamentos)
-- -----------------------------------------------------------------------------
INSERT INTO departments (id, name, branch_id) VALUES
(1, 'Engenharia de Software', 1),
(2, 'Recursos Humanos', 1),
(3, 'Financeiro e Controladoria', 1),
(4, 'Suporte Técnico e Operações', 2),
(5, 'Pesquisa e Desenvolvimento (P&D)', 3),
(6, 'Armazenamento e Separação', 4),
(7, 'Frente de Caixa e Vendas', 5),
(8, 'Operações Portuárias e Cargas', 6),
(9, 'Segurança do Trabalho (SESMT)', 1),
(10, 'Jurídico e Compliance', 1);

-- -----------------------------------------------------------------------------
-- 4. JOB TITLES (Cargos / CBO)
-- -----------------------------------------------------------------------------
INSERT INTO job_titles (id, name, cbo) VALUES
(1, 'Engenheiro de Software Pleno', '2124-05'),
(2, 'Analista de Recursos Humanos', '2524-05'),
(3, 'Analista Financeiro', '2525-05'),
(4, 'Operador de Logística', '7841-05'),
(5, 'Assistente de Vendas', '5211-10'),
(6, 'Especialista em Cibersegurança', '2124-20'),
(7, 'Gerente de Operações', '1414-05'),
(8, 'Auxiliar Administrativo', '4110-10');

-- -----------------------------------------------------------------------------
-- 5. SHIFTS (Turnos de Trabalho)
-- -----------------------------------------------------------------------------
INSERT INTO shifts (id, name, clock_in_time, beak_start_time, break_end_time, clock_out_time, tolerance_minutes) VALUES
(1, 'Comercial Padrão 8h (08h às 17h)', '08:00:00', '12:00:00', '13:00:00', '17:00:00', 10),
(2, 'Administrativo Flex (09h às 18h)', '09:00:00', '13:00:00', '14:00:00', '18:00:00', 15),
(3, 'Turno Manhã Operacional (06h às 14h)', '06:00:00', '10:00:00', '11:00:00', '14:00:00', 10),
(4, 'Turno Tarde Operacional (14h às 22h)', '14:00:00', '18:00:00', '19:00:00', '22:00:00', 10),
(5, 'Turno Noturno (22h às 06h)', '22:00:00', '02:00:00', '03:00:00', '06:00:00', 10);

-- -----------------------------------------------------------------------------
-- 6. PERMISSION PROFILES (Perfis de Acesso)
-- -----------------------------------------------------------------------------
INSERT INTO permission_profiles (id, name, access_level) VALUES
(1, 'Administrador Geral do Sistema', 1),
(2, 'Gestor de Recursos Humanos / DP', 2),
(3, 'Gerente de Equipe / Coordenador', 3),
(4, 'Colaborador Padrão', 4);

-- -----------------------------------------------------------------------------
-- 7. OCCURRENCE TYPES (Tipos de Ocorrência)
-- -----------------------------------------------------------------------------
INSERT INTO occurrence_types (id, name, grants_hours, requires_doc) VALUES
(1, 'Esquecimento de Marcação de Ponto', TRUE, FALSE),
(2, 'Consulta Médica / Exame de Rotina', TRUE, TRUE),
(3, 'Serviço Externo / Reunião com Cliente', TRUE, FALSE),
(4, 'Declaração de Acompanhamento Familiar', TRUE, TRUE),
(5, 'Atraso Justificado por Falha de Transporte', TRUE, FALSE),
(6, 'Saída Antecipada Particular (Não Abonada)', FALSE, FALSE);

-- -----------------------------------------------------------------------------
-- 8. LEAVE TYPES (Tipos de Afastamento)
-- -----------------------------------------------------------------------------
INSERT INTO leave_types (id, name, code, is_paid) VALUES
(1, 'Atestado Médico (até 15 dias)', 1, TRUE),
(2, 'Auxílio-Doença / INSS (acima de 15 dias)', 2, FALSE),
(3, 'Licença Maternidade (120/180 dias)', 3, TRUE),
(4, 'Licença Paternidade', 4, TRUE),
(5, 'Férias Regulamentares', 5, TRUE),
(6, 'Licença Casamento (Gala)', 6, TRUE),
(7, 'Licença Óbito (Luto)', 7, TRUE),
(8, 'Licença Não Remunerada (Interesse Particular)', 8, FALSE);

-- -----------------------------------------------------------------------------
-- 9. EMPLOYEES (Colaboradores)
-- -----------------------------------------------------------------------------
INSERT INTO employees (id, name, department_id, id_document, birth_date) VALUES
(1, 'Lucas Gabriel da Silva', 1, '111.222.333-44', '1992-05-14'),
(2, 'Mariana Oliveira Costa', 1, '222.333.444-55', '1995-08-22'),
(3, 'Carlos Eduardo Souza', 2, '333.444.555-66', '1988-11-30'),
(4, 'Beatriz Lima Fernandes', 2, '444.555.666-77', '1994-03-17'),
(5, 'Rafael Antunes Moreira', 3, '555.666.777-88', '1985-07-09'),
(6, 'Juliana Mendes Rocha', 4, '666.777.888-99', '1997-01-25'),
(7, 'Felipe Castro Ribeiro', 5, '777.888.999-00', '1990-09-12'),
(8, 'Amanda Ferreira Duarte', 5, '888.999.000-11', '1993-12-05'),
(9, 'Thiago Barbosa Lima', 6, '999.000.111-22', '1987-04-18'),
(10, 'Camila Santos Nogueira', 6, '123.456.789-01', '1996-06-29'),
(11, 'Rodrigo Pereira Carvalho', 7, '234.567.890-12', '1999-10-03'),
(12, 'Fernanda Alves Martins', 7, '345.678.901-23', '1991-02-19'),
(13, 'Bruno Henrique Gomes', 8, '456.789.012-34', '1984-08-11'),
(14, 'Patrícia Vieira Ramos', 8, '567.890.123-45', '1989-11-27'),
(15, 'Gustavo Meireles Pinto', 9, '678.901.234-56', '1986-03-08'),
(16, 'Vanessa Cardoso Dias', 10, '789.012.345-67', '1992-07-15'),
(17, 'André Luiz Machado', 1, '890.123.456-78', '1998-04-20'),
(18, 'Renata Cavalcanti Leite', 2, '901.234.567-89', '1990-12-31'),
(19, 'Diego Farias Borges', 4, '012.345.678-90', '1995-05-02'),
(20, 'Larissa Vasconcelos Prado', 6, '135.792.468-01', '1994-09-16');

-- -----------------------------------------------------------------------------
-- 10. USERS (Usuários de Acesso)
-- -----------------------------------------------------------------------------
INSERT INTO users (id, employee_id, profile_id, email, password_hash, is_active, last_login) VALUES
(1, 1, 1, 'lucas.silva@techcorp.com.br', '$2a$12$e8F0lD1Jc5Yx7Xw2Qk8B7eA9hO1mN2kP3rT4vU5wX6yZ7aB8cD9eF', TRUE, '2026-09-07 08:30:00'),
(2, 3, 2, 'carlos.souza@techcorp.com.br', '$2a$12$K8j7H6g5F4d3S2a1Q0w9E8r7T6y5U4i3O2p1A0s9D8f7G6h5J4k3L', TRUE, '2026-09-07 08:05:00'),
(3, 4, 2, 'beatriz.fernandes@techcorp.com.br', '$2a$12$m5N6b7V8c9X0z1A2s3D4f5G6h7J8k9L0q1W2e3R4t5Y6u7I8o9P0a', TRUE, '2026-09-06 17:45:00'),
(4, 5, 3, 'rafael.moreira@techcorp.com.br', '$2a$12$q1W2e3R4t5Y6u7I8o9P0a1S2d3F4g5H6j7K8l9Z0x1C2v3B4n5M6b', TRUE, '2026-09-07 09:12:00'),
(5, 7, 3, 'felipe.ribeiro@techcorp.com.br', '$2a$12$z9Y8x7W6v5U4t3S2r1Q0p9O8n7M6l5K4j3I2h1G0f9E8d7C6b5A4a', TRUE, '2026-09-07 08:50:00'),
(6, 9, 3, 'thiago.lima@varejoglobal.com.br', '$2a$12$b1N2m3V4c5X6z7A8s9D0f1G2h3J4k5L6q7W8e9R0t1Y2u3I4o5P6a', TRUE, '2026-09-05 14:20:00'),
(7, 13, 3, 'bruno.gomes@logveloc.com.br', '$2a$12$p0O9i8U7y6T5r4E3w2Q1a0S9d8F7g6H5j4K3l2Z1x0C9v8B7n6M5a', TRUE, '2026-09-07 06:15:00'),
(8, 16, 2, 'vanessa.dias@techcorp.com.br', '$2a$12$a1B2c3D4e5F6g7H8i9J0k1L2m3N4o5P6q7R8s9T0u1V2w3X4y5Z6a', TRUE, '2026-09-07 09:40:00');

-- -----------------------------------------------------------------------------
-- 11. SCHEDULES (Escalas dos Colaboradores)
-- -----------------------------------------------------------------------------
INSERT INTO schedules (id, shift_name, workload, employee_id) VALUES
(1, 'Comercial Padrão 40h/sem', 480, 1),
(2, 'Comercial Padrão 40h/sem', 480, 2),
(3, 'Administrativo Flexível', 480, 3),
(4, 'Administrativo Flexível', 480, 4),
(5, 'Administrativo Flexível', 480, 5),
(6, 'Turno Tarde Operacional', 480, 6),
(7, 'Comercial Padrão 40h/sem', 480, 7),
(8, 'Comercial Padrão 40h/sem', 480, 8),
(9, 'Turno Manhã Cajamar', 480, 9),
(10, 'Turno Tarde Cajamar', 480, 10),
(11, 'Comercial Loja Paulista', 480, 11),
(12, 'Comercial Loja Paulista', 480, 12),
(13, 'Operações Porto Santos 12x36', 720, 13),
(14, 'Operações Porto Santos 12x36', 720, 14),
(15, 'Comercial Padrão 40h/sem', 480, 15),
(16, 'Administrativo Jurídico', 480, 16),
(17, 'Comercial Padrão 40h/sem', 480, 17),
(18, 'Administrativo Flexível', 480, 18),
(19, 'Turno Noite Suporte', 480, 19),
(20, 'Turno Manhã Cajamar', 480, 20);

-- -----------------------------------------------------------------------------
-- 12. CLOCK DEVICES (Dispositivos / Relógios de Ponto)
-- -----------------------------------------------------------------------------
INSERT INTO clock_devices (id, branch_id, department_id, location, model_name) VALUES
(1, 1, 1, 'Hall de Entrada Principal - 3º Andar', 'REP-P Henry Prism Super Fácil'),
(2, 1, 2, 'Recepção RH - 2º Andar', 'REP-P Control iD iDClass Biometria'),
(3, 1, 3, 'Corredor Financeiro - 4º Andar', 'REP-P Dimep PrintPoint 3'),
(4, 2, 4, 'Portaria Suporte Rio de Janeiro', 'REP-P Control iD Facial iDFace'),
(5, 3, 5, 'Laboratório de P&D Campinas', 'REP-P Secullum Facial BioSafe'),
(6, 4, 6, 'Portaria 1 - Galpão Logística Cajamar', 'REP-P Madis Rodbel MD 0706'),
(7, 5, 7, 'Backoffice Loja Shopping Paulista', 'REP-A App Mobile PontoTech v3.2'),
(8, 6, 8, 'Cabine de Controle Cargas Porto Santos', 'REP-P Control iD iDClass Rugged');

-- -----------------------------------------------------------------------------
-- 13. HOLIDAYS (Feriados)
-- -----------------------------------------------------------------------------
INSERT INTO holidays (id, date, description, type, state_code, branch_id, recurring) VALUES
(1, '2026-01-01', 'Confraternização Universal', 'NATIONAL', 'BR', 1, TRUE),
(2, '2026-01-25', 'Aniversário da Cidade de São Paulo', 'MUNICIPAL', 'SP', 1, TRUE),
(3, '2026-04-21', 'Tiradentes', 'NATIONAL', 'BR', 1, TRUE),
(4, '2026-05-01', 'Dia Mundial do Trabalho', 'NATIONAL', 'BR', 1, TRUE),
(5, '2026-07-09', 'Revolução Constitucionalista', 'STATE', 'SP', 1, TRUE),
(6, '2026-09-07', 'Independência do Brasil', 'NATIONAL', 'BR', 1, TRUE),
(7, '2026-10-12', 'Nossa Senhora Aparecida', 'NATIONAL', 'BR', 1, TRUE),
(8, '2026-11-20', 'Dia Nacional de Zumbi e Consciência Negra', 'NATIONAL', 'BR', 1, TRUE);

-- -----------------------------------------------------------------------------
-- 14. APURATION PERIODS (Períodos de Apuração)
-- -----------------------------------------------------------------------------
INSERT INTO apuration_periods (id, branch_id, start_date, end_date, is_closed, closed_at, closed_by_user) VALUES
(1, 1, '2026-07-01', '2026-07-31', TRUE, '2026-08-05 18:00:00', 2),
(2, 1, '2026-08-01', '2026-08-31', TRUE, '2026-09-03 17:30:00', 2),
(3, 1, '2026-09-01', '2026-09-30', FALSE, '2026-09-30 23:59:59', 2),
(4, 4, '2026-08-01', '2026-08-31', TRUE, '2026-09-02 16:45:00', 6),
(5, 6, '2026-08-01', '2026-08-31', TRUE, '2026-09-04 19:10:00', 7);

-- -----------------------------------------------------------------------------
-- 15. LEAVES (Afastamentos e Licenças Médicas)
-- -----------------------------------------------------------------------------
INSERT INTO leaves (id, employee_id, leave_type_id, start_date, end_date, cid, document_url) VALUES
(1, 2, 1, '2026-08-10', '2026-08-14', 'J06.9', 'https://docs.techcorp.com/atestados/2026/mariana_j06.pdf'),
(2, 6, 1, '2026-08-18', '2026-08-20', 'M54.5', 'https://docs.techcorp.com/atestados/2026/juliana_m54.pdf'),
(3, 8, 5, '2026-08-01', '2026-08-30', 'N/A', 'https://docs.techcorp.com/ferias/2026/amanda_aviso.pdf'),
(4, 10, 3, '2026-07-01', '2026-10-28', 'Z39.0', 'https://docs.techcorp.com/licencas/2026/camila_maternidade.pdf'),
(5, 14, 6, '2026-08-25', '2026-08-27', 'N/A', 'https://docs.techcorp.com/licencas/2026/patricia_casamento.pdf'),
(6, 17, 1, '2026-09-02', '2026-09-03', 'K52.9', 'https://docs.techcorp.com/atestados/2026/andre_k52.pdf');

-- -----------------------------------------------------------------------------
-- 16. TIME PUNCHES (Registros de Ponto)
-- -----------------------------------------------------------------------------
INSERT INTO time_punches (id, punched_at, employee_id, device_id) VALUES
-- Dia 2026-09-01 (Lucas Silva - Matrícula 1)
(1, '2026-09-01', 1, 1),
(2, '2026-09-01', 1, 1),
(3, '2026-09-01', 1, 1),
(4, '2026-09-01', 1, 1),
-- Dia 2026-09-02 (Lucas Silva - Matrícula 1)
(5, '2026-09-02', 1, 1),
(6, '2026-09-02', 1, 1),
(7, '2026-09-02', 1, 1),
(8, '2026-09-02', 1, 1),
-- Dia 2026-09-01 (Mariana Costa - Matrícula 2)
(9, '2026-09-01', 2, 1),
(10, '2026-09-01', 2, 1),
(11, '2026-09-01', 2, 1),
(12, '2026-09-01', 2, 1),
-- Dia 2026-09-01 (Carlos Souza - Matrícula 3)
(13, '2026-09-01', 3, 2),
(14, '2026-09-01', 3, 2),
(15, '2026-09-01', 3, 2),
(16, '2026-09-01', 3, 2),
-- Dia 2026-09-01 (Juliana Mendes - Matrícula 6)
(17, '2026-09-01', 6, 4),
(18, '2026-09-01', 6, 4),
(19, '2026-09-01', 6, 4),
(20, '2026-09-01', 6, 4),
-- Dia 2026-09-01 (Thiago Lima - Matrícula 9 - Cajamar)
(21, '2026-09-01', 9, 6),
(22, '2026-09-01', 9, 6),
(23, '2026-09-01', 9, 6),
(24, '2026-09-01', 9, 6),
-- Dia 2026-09-01 (Rodrigo Carvalho - Matrícula 11 - Loja)
(25, '2026-09-01', 11, 7),
(26, '2026-09-01', 11, 7),
(27, '2026-09-01', 11, 7),
(28, '2026-09-01', 11, 7),
-- Dia 2026-09-01 (Bruno Gomes - Matrícula 13 - Santos)
(29, '2026-09-01', 13, 8),
(30, '2026-09-01', 13, 8),
(31, '2026-09-01', 13, 8),
(32, '2026-09-01', 13, 8);

-- -----------------------------------------------------------------------------
-- 17. DAILY APURATIONS (Apuração Diária / Espelho de Ponto)
-- -----------------------------------------------------------------------------
INSERT INTO daily_apurations (id, employee_id, apuration_period_id, schedule_id, date, hours_worked, hours_expected, overtime_50, overtime_100, hours_absence, night_hours, day_status) VALUES
(1, 1, 3, 1, '2026-09-01', 480, 480, 0, 0, 0, 0, 'WORKED'),
(2, 1, 3, 1, '2026-09-02', 540, 480, 60, 0, 0, 0, 'WORKED'),
(3, 1, 3, 1, '2026-09-03', 450, 480, 0, 0, 30, 0, 'WORKED'),
(4, 2, 3, 2, '2026-09-01', 480, 480, 0, 0, 0, 0, 'WORKED'),
(5, 2, 3, 2, '2026-09-02', 510, 480, 30, 0, 0, 0, 'WORKED'),
(6, 3, 3, 3, '2026-09-01', 480, 480, 0, 0, 0, 0, 'WORKED'),
(7, 4, 3, 4, '2026-09-01', 480, 480, 0, 0, 0, 0, 'WORKED'),
(8, 5, 3, 5, '2026-09-01', 480, 480, 0, 0, 0, 0, 'WORKED'),
(9, 6, 3, 6, '2026-09-01', 480, 480, 0, 0, 0, 0, 'WORKED'),
(10, 7, 3, 7, '2026-09-01', 480, 480, 0, 0, 0, 0, 'WORKED'),
(11, 8, 3, 8, '2026-09-01', 0, 480, 0, 0, 0, 0, 'LEAVE'),
(12, 9, 4, 9, '2026-09-01', 520, 480, 40, 0, 0, 0, 'WORKED'),
(13, 10, 4, 10, '2026-09-01', 0, 480, 0, 0, 0, 0, 'LEAVE'),
(14, 11, 3, 11, '2026-09-01', 480, 480, 0, 0, 0, 0, 'WORKED'),
(15, 12, 3, 12, '2026-09-01', 480, 480, 0, 0, 0, 0, 'WORKED'),
(16, 13, 5, 13, '2026-09-01', 720, 720, 0, 0, 0, 0, 'WORKED'),
(17, 14, 5, 14, '2026-09-01', 720, 720, 0, 0, 0, 0, 'WORKED'),
(18, 17, 3, 17, '2026-09-02', 0, 480, 0, 0, 0, 0, 'JUSTIFIED'),
(19, 19, 3, 19, '2026-09-01', 480, 480, 0, 0, 0, 420, 'WORKED'),
(20, 1, 3, 1, '2026-09-07', 0, 0, 0, 0, 0, 0, 'HOLIDAY');

-- -----------------------------------------------------------------------------
-- 18. OCCURRENCES (Ocorrências e Ajustes de Ponto)
-- -----------------------------------------------------------------------------
INSERT INTO occurrences (id, daily_apuration_id, occurrence_type_id, description, attachment_url, status) VALUES
(1, 3, 1, 'Esquecimento da marcação de retorno do almoço. Ponto corrigido.', 'https://docs.techcorp.com/justificativas/lucas_20260903.pdf', 'APPROVED'),
(2, 5, 3, 'Reunião extraordinária com cliente em Alphaville.', 'https://docs.techcorp.com/justificativas/mariana_ext_20260902.pdf', 'APPROVED'),
(3, 12, 5, 'Atraso devido à paralisação na linha 7 da CPTM.', 'https://docs.techcorp.com/justificativas/thiago_cptm_20260901.pdf', 'APPROVED'),
(4, 18, 2, 'Consulta médica com gastroenterologista.', 'https://docs.techcorp.com/atestados/andre_consulta_20260902.pdf', 'APPROVED'),
(5, 2, 1, 'Solicitação de ajuste de saída retroativo.', 'https://docs.techcorp.com/justificativas/pendente_01.pdf', 'PENDING');

-- -----------------------------------------------------------------------------
-- 19. AUDIT LOGS (Logs de Auditoria do Sistema)
-- -----------------------------------------------------------------------------
INSERT INTO audit_logs (id, user_id, action, affected_table, record_id, old_data, new_data, changed_at) VALUES
(1, 2, 'UPDATE', 'occurrences', 1, '{"status": "PENDING"}', '{"status": "APPROVED", "approved_by": 2}', '2026-09-04 10:15:22'),
(2, 2, 'INSERT', 'leaves', 6, '{}', '{"employee_id": 17, "leave_type_id": 1, "cid": "K52.9"}', '2026-09-02 14:02:40'),
(3, 1, 'UPDATE', 'apuration_periods', 2, '{"is_closed": false}', '{"is_closed": true, "closed_at": "2026-09-03 17:30:00"}', '2026-09-03 17:30:05'),
(4, 3, 'INSERT', 'occurrences', 5, '{}', '{"daily_apuration_id": 2, "status": "PENDING"}', '2026-09-03 09:20:11'),
(5, 1, 'UPDATE', 'employees', 1, '{"department_id": 2}', '{"department_id": 1}', '2026-08-01 11:00:00');

