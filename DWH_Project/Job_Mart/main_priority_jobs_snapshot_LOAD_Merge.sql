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
WHEN MATCHED AND trgt.priority_lvl IS DISTINCT FROM src.priority_lvl
THEN UPDATE
SET
    priority_lvl = src.priority_lvl,
    updated_at = CURRENT_TIMESTAMP
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