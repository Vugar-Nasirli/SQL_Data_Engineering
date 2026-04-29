-- Step 10: Data Validation of Priorty Mart

SELECT '===== Priority Mart Validation: =====' AS info;

SELECT
    table_catalog,
    table_schema,
    table_name,
    table_type 
FROM
    information_schema.tables
WHERE
    table_schema = 'priority_mart'
    OR
    table_catalog = 'temp';

SELECT 'priority_roles' AS table, COUNT(*) AS entry_count FROM priority_mart.priority_roles
UNION
SELECT 'priority_jobs_snapshot', COUNT(*) FROM priority_mart.priority_jobs_snapshot; 