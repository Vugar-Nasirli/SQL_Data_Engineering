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

-- Checking Data
SELECT * FROM staging.job_postings_flat LIMIT 10;