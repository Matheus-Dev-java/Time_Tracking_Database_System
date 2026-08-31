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
