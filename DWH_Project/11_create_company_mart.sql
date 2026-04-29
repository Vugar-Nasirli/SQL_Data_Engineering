-- Step 11: Create Company Mart

DROP SCHEMA IF EXISTS company_mart CASCADE;

CREATE SCHEMA company_mart;

SELECT '===== Creating Job Title Short Dimension and Loading into Data... =====' AS info;
CREATE TABLE company_mart.dim_job_title_short
(
    job_title_short_id      INTEGER     PRIMARY KEY,
    job_title_short         VARCHAR
);

INSERT INTO company_mart.dim_job_title_short(job_title_short_id, job_title_short)
SELECT
    ROW_NUMBER() OVER() AS job_title_short_id,
    job_title_short
FROM
(
SELECT DISTINCT
    job_title_short
FROM
    job_postings_fact
WHERE
    job_title_short IS NOT NULL
);

SELECT '===== Data Sample Job Title Short Dimension: =====' AS info;
SELECT * FROM company_mart.dim_job_title_short;


SELECT '===== Creating Job Title Dimension and Loading into Data... =====' AS info;
CREATE TABLE company_mart.dim_job_title
(
    job_title_id        INTEGER     PRIMARY KEY,
    job_title           VARCHAR
);

INSERT INTO company_mart.dim_job_title(job_title_id, job_title)
SELECT
    ROW_NUMBER() OVER() AS job_title_id,
    job_title
FROM
(
SELECT DISTINCT
    job_title
FROM
    job_postings_fact
WHERE
    job_title IS NOT NULL
);

SELECT '===== Data Sample Job Title Dimension: =====' AS info;
SELECT * FROM company_mart.dim_job_title LIMIT 10;


SELECT '===== Creating Job Title Bridge and Loading into Data... =====' AS info;
CREATE TABLE company_mart.bridge_job_title
(
    job_title_short_id      INTEGER,
    job_title_id            INTEGER,
    PRIMARY KEY (job_title_short_id, job_title_id),
    FOREIGN KEY (job_title_short_id) REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (job_title_id) REFERENCES company_mart.dim_job_title(job_title_id)
);

INSERT INTO company_mart.bridge_job_title(job_title_short_id, job_title_id)
SELECT DISTINCT
    jtsh.job_title_short_id,
    jt.job_title_id
FROM
    job_postings_fact AS f
    INNER JOIN company_mart.dim_job_title_short AS jtsh ON jtsh.job_title_short = f.job_title_short
    INNER JOIN company_mart.dim_job_title AS jt ON jt.job_title = f.job_title
WHERE
    f.job_title IS NOT NULL
    AND
    f.job_title_short IS NOT NULL
ORDER BY
    job_title_short_id;

SELECT '===== Data Sample Job Title Bridge: =====' AS info;
SELECT * FROM company_mart.bridge_job_title LIMIT 10;


SELECT '===== Creating Company Dimension and Loading into Data... =====' AS info;
CREATE TABLE company_mart.dim_company
(
    company_id      INTEGER     PRIMARY KEY,
    company_name    VARCHAR
);

INSERT INTO company_mart.dim_company(company_id, company_name)
SELECT
    company_id,
    name AS company_name
FROM
    company_dim;

SELECT '===== Data Sample Company Dimension: =====' AS info;
SELECT * FROM company_mart.dim_company LIMIT 10;


SELECT '===== Creating Location Dimension and Loading into Data... =====' AS info;
CREATE TABLE company_mart.dim_location
(
    location_id     INTEGER     PRIMARY KEY,
    job_country     VARCHAR,
    job_location     VARCHAR
);

INSERT INTO company_mart.dim_location(location_id, job_country, job_location)
SELECT
    ROW_NUMBER() OVER() AS location_id,
    job_country,
    job_location
FROM
(
SELECT DISTINCT
    job_country,
    job_location
FROM
    job_postings_fact
WHERE
    job_country IS NOT NULL
    AND
    job_location IS NOT NULL
);

SELECT '===== Data Sample Location Dimension: =====' AS info;
SELECT * FROM company_mart.dim_location LIMIT 10;


SELECT '===== Creating Company Location Bridge and Loading into Data... =====' AS info;
CREATE TABLE company_mart.bridge_company_location
(
    company_id      INTEGER,
    location_id     INTEGER,
    PRIMARY KEY (company_id, location_id),
    FOREIGN KEY (company_id) REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY (location_id) REFERENCES company_mart.dim_location(location_id)
);

INSERT INTO company_mart.bridge_company_location
SELECT DISTINCT
    c.company_id,
    l.location_id
FROM
    job_postings_fact AS f
    INNER JOIN company_mart.dim_company AS c ON c.company_id = f.company_id
    INNER JOIN company_mart.dim_location AS l ON l.job_location = f.job_location AND l.job_country = f.job_country
WHERE
    f.company_id IS NOT NULL
    AND
    f.job_location IS NOT NULL
    AND
    f.job_country IS NOT NULL;

SELECT '===== Data Sample Company Location Bridge: =====' AS info;
SELECT * FROM company_mart.bridge_company_location LIMIT 10;

SELECT '===== Creating Date Month Dimension and Loading into Data... =====' AS info;
CREATE TABLE company_mart.dim_date_month
(
    month_start_date        DATE        PRIMARY KEY,
    year                    INTEGER,
    month                   INTEGER
);

INSERT INTO company_mart.dim_date_month(month_start_date, year, month)
SELECT DISTINCT
    DATETRUNC('MONTH', job_posted_date)::DATE AS month_start_date,
    EXTRACT('YEAR' FROM job_posted_date) AS year,
    EXTRACT('MONTH' FROM job_posted_date) AS month
FROM
    job_postings_fact
ORDER BY
    month_start_date;

SELECT '===== Data Sample Date Month Dimension: =====' AS info;
SELECT * FROM company_mart.dim_date_month;


SELECT '===== Creating Company Hiring Monthly Fact Table and Loading into Data... =====' AS info;
CREATE TABLE company_mart.fact_company_hiring_monthly
(
    company_id                  INTEGER,
    job_title_short_id          INTEGER,
    month_start_date            DATE,
    job_country                 VARCHAR,
    postings_count              INTEGER,
    median_salary_year          DOUBLE,
    min_salary_year             DOUBLE,
    max_salary_year             DOUBLE,
    remote_share                INTEGER,
    health_insurance_share      INTEGER,
    no_degree_mention_share     INTEGER
);

INSERT INTO company_mart.fact_company_hiring_monthly
(
    company_id,
    job_title_short_id,
    month_start_date,
    job_country,
    postings_count,
    median_salary_year,
    min_salary_year,
    max_salary_year,
    remote_share,
    health_insurance_share,
    no_degree_mention_share
)
WITH base_query
AS
(
SELECT
    f.job_id,
    f.company_id,
    jtsh.job_title_short_id,
    DATETRUNC('MONTH', f.job_posted_date) AS month_start_date,
    f.job_country,
    f.salary_year_avg,
    CASE f.job_work_from_home WHEN TRUE THEN 1 ELSE 0 END AS is_remote_job,
    CASE f.job_health_insurance WHEN TRUE THEN 1 ELSE 0 END AS has_health_insurance,
    CASE f.job_no_degree_mention WHEN TRUE THEN 1 ELSE 0 END AS no_degree_required
FROM
    job_postings_fact AS f
    LEFT JOIN company_mart.dim_job_title_short AS jtsh ON jtsh.job_title_short = f.job_title_short
WHERE
    f.company_id IS NOT NULL
    AND
    f.job_title_short IS NOT NULL
    AND
    f.job_posted_date IS NOT NULL
    AND
    f.job_country IS NOT NULL
)

SELECT
    company_id,
    job_title_short_id,
    month_start_date,
    job_country,
    COUNT(job_id) AS postings_count,
    MEDIAN(salary_year_avg) AS median_salary_year,
    MIN(salary_year_avg) AS min_salary_year,
    MAX(salary_year_avg) AS max_salary_year,
    SUM(is_remote_job) AS remote_share,
    SUM(has_health_insurance) AS health_insurance_share,
    SUM(no_degree_required) AS no_degree_mention_share
FROM
    base_query
GROUP BY
    company_id,
    job_title_short_id,
    month_start_date,
    job_country
ORDER BY
    company_id,
    job_title_short_id,
    month_start_date,
    job_country;


SELECT '===== Data Sample Company Hiring Monthly Fact Table: =====' AS info;
SELECT * FROM company_mart.fact_company_hiring_monthly LIMIT 10;