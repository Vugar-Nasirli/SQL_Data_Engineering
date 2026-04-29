-- Step 6: Marts - Skill Mart - Create Skills Mart Schema, Tables and Load Data Into

DROP SCHEMA IF EXISTS skill_mart CASCADE;

CREATE SCHEMA skill_mart;


-- Table: dim_skills
-- Create Table:
CREATE TABLE skill_mart.dim_skills
(
    Skill_id    INTEGER     PRIMARY KEY,
    skills      VARCHAR,
    type        VARCHAR
);

-- Load Data into Table:
INSERT INTO skill_mart.dim_skills(skill_id, skills, type)
SELECT
    skill_id,
    Skills,
    type
FROM
    Skills_dim;


-- Table: dim_date_month
-- Create Table:
CREATE TABLE skill_mart.dim_date_month
(
    month_start_date    DATE    PRIMARY KEY,
    year                INTEGER,
    month               INTEGER,
    quarter             INTEGER,
    quarter_name        VARCHAR,
    year_quarter        VARCHAR
);
-- Load Data into Table:
INSERT INTO skill_mart.dim_date_month(month_start_date, year, month, quarter, quarter_name, year_quarter)
SELECT DISTINCT
    DATE_TRUNC('MONTH', job_posted_date)::DATE AS month_start_date,
    EXTRACT('YEAR' FROM job_posted_date) AS year,
    EXTRACT('MONTH' FROM job_posted_date) AS month,
    EXTRACT('QUARTER' FROM job_posted_date) AS quarter,
    'Q-' || EXTRACT('QUARTER' FROM job_posted_date)::VARCHAR AS quarter_name,
    EXTRACT('YEAR' FROM job_posted_date)::VARCHAR || ' - Q-' || EXTRACT('QUARTER' FROM job_posted_date) AS year_quarter
FROM
    job_postings_fact
ORDER BY
    month_start_date;


-- Table: fact_skill_demand_monthly
-- Create Table:
CREATE TABLE skill_mart.fact_skill_demand_monthly
(
    skill_id                        INTEGER,
    month_start_date                DATE,
    job_title_short                 VARCHAR,
    postings_count                  INTEGER,
    remote_postings_count           INTEGER,
    health_insurance_postings_count INTEGER,
    no_degree_postings_count        INTEGER,
    PRIMARY KEY (skill_id, month_start_date, job_title_short),
    FOREIGN KEY (skill_id) REFERENCES skill_mart.dim_skills(skill_id),
    FOREIGN KEY (month_start_date) REFERENCES skill_mart.dim_date_month(month_start_date)
);
-- Insert Data into Table:
INSERT INTO skill_mart.fact_skill_demand_monthly
(
    skill_id,
    month_start_date,
    job_title_short,
    postings_count,
    remote_postings_count,
    health_insurance_postings_count,
    no_degree_postings_count
)
WITH base_query
AS
(
SELECT
    b.skill_id,
    DATE_TRUNC('MONTH', f.job_posted_date) AS month_start_date,
    f.job_title_short,
    CASE job_work_from_home WHEN TRUE THEN 1 ELSE 0 END AS is_remote_job,
    CASE job_health_insurance WHEN TRUE THEN 1 ELSE 0 END AS has_health_insurance,
    CASE job_no_degree_mention WHEN TRUE THEN 1 ELSE 0 END AS no_degree_required
FROM
    job_postings_fact AS f
    INNER JOIN skills_job_dim AS b ON b.job_id = f.job_id
)

SELECT
    skill_id,
    month_start_date,
    job_title_short,
    COUNT(*) AS postings_count,
    SUM(is_remote_job) AS remote_postings_count,
    SUM(has_health_insurance) AS health_insurance_postings_count,
    SUM(no_degree_required) AS no_degree_postings_count
FROM
    base_query
GROUP BY
    skill_id,
    month_start_date,
    job_title_short
ORDER BY
    skill_id,
    month_start_date,
    job_title_short;




