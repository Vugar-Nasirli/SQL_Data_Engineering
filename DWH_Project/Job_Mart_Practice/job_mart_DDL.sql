--========================
-- Creating DB and Schemas
--========================
USE data_jobs;

-- Droping DB
DROP DATABASE IF EXISTS job_mart;
-- Creating DB
CREATE DATABASE IF NOT EXISTS job_mart;

-- Checking for DB
SHOW DATABASES;

USE job_mart;

-- Creating Schemas
CREATE SCHEMA IF NOT EXISTS main;

CREATE SCHEMA IF NOT EXISTS staging;

-- Checking for Schemas
SELECT
    catalog_name,
    schema_name
FROM
    INFORMATION_SCHEMA.schemata
WHERE
    catalog_name = 'job_mart';

-------------------------------------------------------------
--==========================
-- Creating Tables and Views
--==========================

--================================
-- Creating Staging Schema Objects
--================================

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
    (3, 'Software Engineer', 3);


-- Creating and Loading Data into Table: staging.job_postings_flat
CREATE OR REPLACE TABLE staging.job_postings_flat
AS
SELECT
  f.job_id,
  f.company_id,
  c.name AS company_name,
  f.job_title_short,
  f.job_title,
  f.job_location,
  f.job_work_from_home,
  f.search_location,
  f.job_via,
  f.job_country,
  f.job_schedule_type,
  f.job_posted_date,
  f.job_no_degree_mention,
  f.job_health_insurance,
  f.salary_rate,
  f.salary_year_avg,
  f.salary_hour_avg
FROM
  data_jobs.job_postings_fact AS f
  LEFT JOIN data_jobs.company_dim AS c ON c.company_id = f.company_id;

--=============================
-- Creating Main Schema Objects
--=============================

-- Creating and Loading Data into View: main.priority_jobs_flat_view
CREATE OR REPLACE VIEW main.priority_jobs_flat_view
AS
SELECT
    f.*
FROM
    staging.job_postings_flat AS f
    LEFT JOIN staging.priority_roles AS p ON p.role_name = f.job_title_short
WHERE
    p.priority_lvl = 1;

-- Creaating Table: main.priority_jobs_snapshot
CREATE OR REPLACE TABLE main.priority_jobs_snapshot
(
    job_id INTEGER PRIMARY KEY,
    job_title_short VARCHAR,
    company_name VARCHAR,
    job_posted_date TIMESTAMP,
    salary_year_avg DOUBLE,
    priority_lvl INTEGER,
    updated_at TIMESTAMP
);

-- Inital Load Data into Table
INSERT INTO main.priority_jobs_snapshot
SELECT
    f.job_id,
    f.job_title_short,
    c.name AS company_name,
    f.job_posted_date,
    f.salary_year_avg,
    p.priority_lvl,
    CURRENT_TIMESTAMP
FROM
    data_jobs.job_postings_fact AS f
    LEFT JOIN data_jobs.company_dim AS c ON c.company_id = f.company_id
    INNER JOIN staging.priority_roles AS p ON p.role_name = f.job_title_short;

-- BATCH PROCESSING INCREMENTAL LOAD PROCESS: MERGE = UPDATE + INSERT + DELETE
/*
-- Method 1: UPDATE + INSERT + DELETE
-- 1. Create Temporary Source Table
CREATE OR REPLACE TEMPORARY TABLE src_priority_jobs
AS
SELECT
    f.job_id,
    f.job_title_short,
    c.name AS company_name,
    f.job_posted_date,
    f.salary_year_avg,
    p.priority_lvl,
    CURRENT_TIMESTAMP AS updated_at
FROM
    data_jobs.job_postings_fact AS f
    LEFT JOIN data_jobs.company_dim AS c ON c.company_id = f.company_id
    INNER JOIN staging.priority_roles AS p ON p.role_name = f.job_title_short;

-- 2. UPDATE Target Table
UPDATE main.priority_jobs_snapshot AS trgt
SET
    priority_lvl = src.priority_lvl,
    updated_at = src.updated_at
FROM
    src_priority_jobs AS src
WHERE
    trgt.job_id = src.job_id
    AND
    trgt.priority_lvl IS DISTINCT FROM src.priority_lvl;

-- 3. INSERT into Target Table
INSERT INTO main.priority_jobs_snapshot
SELECT
    *
FROM
    src_priority_jobs AS src
WHERE NOT EXISTS
    (
        SELECT
            1
        FROM
            main.priority_jobs_snapshot AS trgt
        WHERE
            trgt.job_id = src.job_id
    );

-- 4. DELETE From Target Table
DELETE FROM main.priority_jobs_snapshot AS trgt
WHERE NOT EXISTS
    (
        SELECT
            1
        FROM
            src_priority_jobs AS src
        WHERE
            src.job_id = trgt.job_id
    );
*/

-- Method 2: MERGE
-- 1. Create Temporary Source Table
CREATE OR REPLACE TEMPORARY TABLE src_priority_jobs
AS
SELECT
    f.job_id,
    f.job_title_short,
    c.name AS company_name,
    f.job_posted_date,
    f.salary_year_avg,
    p.priority_lvl,
    CURRENT_TIMESTAMP AS updated_at
FROM
    data_jobs.job_postings_fact AS f
    LEFT JOIN data_jobs.company_dim AS c ON c.company_id = f.company_id
    INNER JOIN staging.priority_roles AS p ON p.role_name = f.job_title_short;

-- 2. MERGE from Source to Target
MERGE INTO
    main.priority_jobs_snapshot AS trgt
USING
    src_priority_jobs AS src
ON
    trgt.job_id = src.job_id 
WHEN MATCHED AND trgt.priority_lvl IS DISTINCT FOR src.priority_lvl
THEN UPDATE
SET
    trgt.priority_lvl = src.priority_lvl,
    trgt.updated_at = CURRENT_TIMESTAMP
WHEN NOT MATCHED 
THEN INSERT 
(
    job_id,
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_lvl,
    updated_at
)
VALUES
(
    src.job_id,
    src.job_title_short,
    src.company_name,
    src.job_posted_date,
    src.salary_year_avg,
    src.priority_lvl,
    src.updated_at
)
WHEN NOT MATCHED BY SOURCE
THEN DELETE;


-- Checking for Data
SELECT
    job_title_short,
    COUNT(job_id) AS job_count,
    MIN(priority_lvl),
    MIN(updated_at)
FROM
    main.priority_jobs_snapshot
GROUP BY
    job_title_short
ORDER BY
    job_count DESC;

--===========================
-- Creating Temporary Objects
--===========================

-- Creating and Loading Data into Temporary Table: senior_jobs_flat_temp
CREATE OR REPLACE TEMPORARY TABLE senior_jobs_flat_temp
AS
SELECT
    *
FROM
    main.priority_jobs_flat_view
WHERE
    job_title_short LIKE 'Senior%';