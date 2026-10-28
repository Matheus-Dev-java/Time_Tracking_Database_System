-- DDL 02 | Controle de acesso e auditoria / Access control and audit

-- ----------------------------------------------------------------------------
-- permission_profiles
-- ----------------------------------------------------------------------------
CREATE TABLE permission_profiles (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    access_level INTEGER NOT NULL -- 1=Admin | 2=HR | 3=Manager | 4=Employee
);
ALTER TABLE permission_profiles ADD PRIMARY KEY (id);
-- ----------------------------------------------------------------------------
-- users
-- ----------------------------------------------------------------------------
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
-- ----------------------------------------------------------------------------
-- users: ajustes (antigo arquivo DDL/permission_profiles, sem extensao)
-- ----------------------------------------------------------------------------
-- A FK users.profile_id -> permission_profiles ja existe em DML/01_foreign_keys.sql (fk_users_profile);
-- a duplicata fk_users_permission_profiles foi removida na reorganizacao.
ALTER TABLE users ADD CONSTRAINT uq_users_email UNIQUE (email);
ALTER TABLE users
    ALTER COLUMN employee_id DROP NOT NULL,   -- admins sem colaborador
    ALTER COLUMN last_login  DROP NOT NULL;   -- usuario que nunca logou

-- ----------------------------------------------------------------------------
-- audit_logs
-- ----------------------------------------------------------------------------
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
