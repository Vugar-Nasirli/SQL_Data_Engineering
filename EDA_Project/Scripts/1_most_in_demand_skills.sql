-- What are the most in-demand skills?
SELECT
  s.skill_id,
  s.skills,
  COUNT(*) AS job_count 
FROM
  job_postings_fact AS f
  LEFT JOIN skills_job_dim AS sj ON sj.job_id = f.job_id
  LEFT JOIN skills_dim AS s ON s.skill_id = sj.skill_id
WHERE
  s.skills IS NOT NULL
GROUP BY
  s.skill_id,
  s.skills
ORDER BY
  job_count DESC
LIMIT 10;

-- Result:
/*
┌──────────┬──────────┬───────────┐
│ skill_id │  skills  │ job_count │
│  int32   │ varchar  │   int64   │
├──────────┼──────────┼───────────┤
│        1 │ python   │    759081 │
│        0 │ sql      │    758824 │
│       77 │ aws      │    302245 │
│       74 │ azure    │    280137 │
│      184 │ excel    │    245645 │
│      183 │ tableau  │    241876 │
│        2 │ r        │    237602 │
│       92 │ spark    │    222464 │
│      186 │ power bi │    205785 │
│       12 │ java     │    164723 │
└──────────┴──────────┴───────────┘
  10 rows               3 columns
*/

