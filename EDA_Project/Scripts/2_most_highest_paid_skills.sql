-- What are the highest paying skills?
SELECT
  s.skill_id,
  s.skills,
  ROUND(MEDIAN(f.salary_year_avg), 0) AS median_year_salary,
  COUNT(f.salary_year_avg) AS job_count_year
  --ROUND(MEDIAN(f.salary_hour_avg), 0) AS median_hour_salary,
  --COUNT(f.salary_hour_avg) AS job_count_hour
FROM
  job_postings_fact AS f
  LEFT JOIN skills_job_dim AS sj ON sj.job_id = f.job_id
  LEFT JOIN skills_dim AS s ON s.skill_id = sj.skill_id
GROUP BY
  s.skill_id,
  s.skills
ORDER BY
  median_year_salary DESC
  --median_hour_salary DESC
LIMIT 10;

/*
┌──────────┬───────────────┬────────────────────┬────────────────┐
│ skill_id │    skills     │ median_year_salary │ job_count_year │
│  int32   │    varchar    │       double       │     int64      │
├──────────┼───────────────┼────────────────────┼────────────────┤
│      181 │ fedora        │           182350.0 │              1 │
│       11 │ mongo         │           173500.0 │            511 │
│      177 │ debian        │           173000.0 │              4 │
│       41 │ haskell       │           165000.0 │              4 │
│       49 │ apl           │           160000.0 │             21 │
│      105 │ hugging face  │           157957.0 │            130 │
│      222 │ puppet        │           157500.0 │            124 │
│       81 │ watson        │           155391.0 │             52 │
│      149 │ ruby on rails │           155000.0 │             41 │
│       32 │ rust          │           155000.0 │            206 │
└──────────┴───────────────┴────────────────────┴────────────────┘
  10 rows                                              4 columns
*/