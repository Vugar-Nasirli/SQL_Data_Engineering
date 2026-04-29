-- Step 3: Data Validation

SELECT '===== Data Validation for Data Warehouse =====' AS info;
SELECT table_catalog, table_schema, table_name FROM information_schema.tables;

-- 1. Checking Data Entry Counts
SELECT '===== Table Entry Counts: =====' AS info;
SELECT 'company_dim' AS table, COUNT(*) AS entry_count FROM company_dim
UNION
SELECT 'skills_dim', COUNT(*) FROM skills_dim
UNION
SELECT 'skills_job_dim', COUNT(*) FROM skills_job_dim
UNION
SELECT 'job_postings_fact', COUNT(*) FROM job_postings_fact;

-- 2. Checking Data Samples
SELECT '===== Company_Dim Samples: =====' AS info;
SELECT * FROM company_dim LIMIT 3;
SELECT '===== Skills_Dim Samples: =====' AS info;
SELECT * FROM skills_dim LIMIT 3;
SELECT '===== Skills_Job_Dim Samples: =====' AS info;
SELECT * FROM skills_job_dim LIMIT 3;
SELECT '===== Job_Postings_Fact Samples: =====' AS info;
SELECT * FROM job_postings_fact LIMIT 3;