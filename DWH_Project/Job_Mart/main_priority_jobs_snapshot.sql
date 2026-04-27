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

-- Checking Data
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