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