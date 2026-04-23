-- What are the most optimal skills?
WITH base_query
AS
(
  SELECT
    s.skill_id,
    s.skills,
    ROUND(MEDIAN(f.salary_year_avg), 0) AS median_year_salary,
    ROUND(MEDIAN(f.salary_hour_avg), 0) AS median_hour_salary,
    COUNT(f.salary_hour_avg) AS job_count_hour,
    COUNT(f.salary_year_avg) AS job_count_year
  FROM
    job_postings_fact AS f
    LEFT JOIN skills_job_dim AS sj ON sj.job_id = f.job_id
    LEFT JOIN skills_dim AS s ON s.skill_id = sj.skill_id
  GROUP BY
    s.skill_id,
    s.skills
),

optimal_scores
AS
(
  SELECT
    skill_id,
    skills,
    median_year_salary,
    median_hour_salary,
    job_count_hour,
    job_count_year,
    median_year_salary * job_count_year AS optimal_score_year,
    median_hour_salary * job_count_hour AS optimal_score_hour
  FROM
    base_query
)

SELECT
  skill_id,
  skills,
  median_year_salary,
  job_count_year
  --optimal_score_year,
  --median_hour_salary,
  --job_count_hour,
  --optimal_score_hour
FROM
  optimal_scores
ORDER BY
  optimal_score_year DESC,
  optimal_score_hour DESC
LIMIT 10;


/*
┌──────────┬───────────┬────────────────────┬────────────────┐
│ skill_id │  skills   │ median_year_salary │ job_count_year │
│  int32   │  varchar  │       double       │     int64      │
├──────────┼───────────┼────────────────────┼────────────────┤
│        1 │ python    │           127500.0 │          28943 │
│        0 │ sql       │           120000.0 │          29027 │
│       77 │ aws       │           136000.0 │          11308 │
│        2 │ r         │           121700.0 │          11166 │
│      183 │ tableau   │           112500.0 │          10830 │
│       92 │ spark     │           140000.0 │           8649 │
│       74 │ azure     │           130000.0 │           8625 │
│      184 │ excel     │            90143.0 │           9858 │
│       12 │ java      │           135000.0 │           6286 │
│       73 │ snowflake │           137378.0 │           6049 │
└──────────┴───────────┴────────────────────┴────────────────┘
  10 rows                                          4 columns
*/