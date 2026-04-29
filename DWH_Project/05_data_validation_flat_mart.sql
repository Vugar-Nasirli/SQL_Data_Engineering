-- Step 5: Validating Flat Mart Data
SELECT '===== Data Validation for Flat Mart =====' AS info;
SELECT table_catalog, table_schema, table_name FROM information_schema.tables WHERE table_schema = 'flat_mart';

SELECT '===== Flat Mart Entry Count: =====' AS info;
SELECT COUNT(*) AS entry_count FROM flat_mart.job_postings;

SELECT '===== Flat Mart Sample: =====' AS info;
SELECT * FROM flat_mart.job_postings LIMIT 3;