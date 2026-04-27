-- What are the most optimal skills?
WITH base_query
AS
(
  SELECT
    s.skill_id,
    s.skills,
    ROUND(MEDIAN(f.salary_year_avg), 0) AS median_salary,
    COUNT(f.job_id) AS job_count
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
    median_salary,
    job_count,
    ROUND(LN(median_salary * job_count / 10_000_000), 2) AS optimal_score
  FROM
    base_query
  WHERE
    skill_id IS NOT NULL
)

SELECT
  skill_id,
  skills,
  median_salary,
  job_count,
  optimal_score
FROM
  optimal_scores
ORDER BY
  optimal_score DESC
LIMIT 10;


/*
┌──────────┬──────────┬───────────────┬───────────┬───────────────┐
│ skill_id │  skills  │ median_salary │ job_count │ optimal_score │
│  int32   │ varchar  │    double     │   int64   │    double     │
├──────────┼──────────┼───────────────┼───────────┼───────────────┤
│        1 │ python   │      127500.0 │    759081 │          9.18 │
│        0 │ sql      │      120000.0 │    758824 │          9.12 │
│       77 │ aws      │      136000.0 │    302245 │          8.32 │
│       74 │ azure    │      130000.0 │    280137 │           8.2 │
│       92 │ spark    │      140000.0 │    222464 │          8.04 │
│        2 │ r        │      121700.0 │    237602 │          7.97 │
│      183 │ tableau  │      112500.0 │    241876 │          7.91 │
│       12 │ java     │      135000.0 │    164723 │          7.71 │
│      184 │ excel    │       90143.0 │    245645 │           7.7 │
│      186 │ power bi │      102500.0 │    205785 │          7.65 │
└──────────┴──────────┴───────────────┴───────────┴───────────────┘
  10 rows                                               5 columns
*/