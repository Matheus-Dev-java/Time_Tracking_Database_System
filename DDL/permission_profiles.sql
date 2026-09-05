CREATE TABLE permission_profiles (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    access_level INTEGER NOT NULL -- 1=Admin | 2=HR | 3=Manager | 4=Employee
);
ALTER TABLE permission_profiles ADD PRIMARY KEY (id);