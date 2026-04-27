-- Creating Table: staging.priority_roles
CREATE OR REPLACE TABLE staging.priority_roles
(
    role_id INT PRIMARY KEY,
    role_name VARCHAR,
    priority_lvl INT
);

-- Loading Data into table
INSERT INTO staging.priority_roles
VALUES
    (1, 'Data Engineer', 1),
    (2, 'Senior Data Engineer', 1),
    (3, 'Software Engineer', 1),
    (4, 'Machine Learning Engineer', 1);

-- Checking Data
SELECT * FROM staging.priority_roles;