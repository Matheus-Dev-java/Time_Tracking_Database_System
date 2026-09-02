CREATE TABLE job_titles (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    cbo VARCHAR(255) NOT NULL -- Brazilian Occupation Code
);
ALTER TABLE job_titles ADD PRIMARY KEY (id);
