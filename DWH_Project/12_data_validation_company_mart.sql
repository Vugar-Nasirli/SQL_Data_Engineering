-- Step 12: Validating Data Company Mart

SELECT
    table_catalog,
    table_schema,
    table_name,
    table_type
FROM
    information_schema.tables
WHERE
    table_schema = 'company_mart';

SELECT 'Company Dimension' AS table_name, COUNT(*) as record_count FROM company_mart.dim_company
UNION ALL
SELECT 'Job Title Short Dimension', COUNT(*) FROM company_mart.dim_job_title_short
UNION ALL
SELECT 'Job Title Dimension', COUNT(*) FROM company_mart.dim_job_title
UNION ALL
SELECT 'Location Dimension', COUNT(*) FROM company_mart.dim_location
UNION ALL
SELECT 'Date Month Dimension', COUNT(*) FROM company_mart.dim_date_month
UNION ALL
SELECT 'Company Location Bridge', COUNT(*) FROM company_mart.bridge_company_location
UNION ALL
SELECT 'Job Title Bridge', COUNT(*) FROM company_mart.bridge_job_title
UNION ALL
SELECT 'Company Hiring Fact', COUNT(*) FROM company_mart.fact_company_hiring_monthly;


-- Show sample data from each table
SELECT '=== Company Dimension Sample ===' AS info;
SELECT * FROM company_mart.dim_company LIMIT 5;

SELECT '=== Job Title Short Dimension Sample ===' AS info;
SELECT * FROM company_mart.dim_job_title_short LIMIT 10;

SELECT '=== Job Title Dimension Sample ===' AS info;
SELECT * FROM company_mart.dim_job_title LIMIT 10;

SELECT '=== Location Dimension Sample ===' AS info;
SELECT * FROM company_mart.dim_location LIMIT 10;

SELECT '=== Date Month Dimension Sample ===' AS info;
SELECT * FROM company_mart.dim_date_month ORDER BY month_start_date DESC LIMIT 10;

SELECT '=== Company Location Bridge Sample ===' AS info;
SELECT 
    bcl.company_id,
    dc.company_name,
    bcl.location_id,
    dl.job_country,
    dl.job_location
FROM company_mart.bridge_company_location bcl
JOIN company_mart.dim_company dc ON bcl.company_id = dc.company_id
JOIN company_mart.dim_location dl ON bcl.location_id = dl.location_id
LIMIT 10;

SELECT '=== Job Title Bridge Sample ===' AS info;
SELECT 
    bjt.job_title_short_id,
    djs.job_title_short,
    bjt.job_title_id,
    djt.job_title
FROM company_mart.bridge_job_title bjt
JOIN company_mart.dim_job_title_short djs ON bjt.job_title_short_id = djs.job_title_short_id
JOIN company_mart.dim_job_title djt ON bjt.job_title_id = djt.job_title_id
WHERE djs.job_title_short = 'Data Engineer'
LIMIT 10;

SELECT '=== Company Hiring Fact Sample ===' AS info;
SELECT 
    fchm.company_id,
    dc.company_name,
    djs.job_title_short,
    fchm.job_country,
    fchm.month_start_date,
    fchm.postings_count,
    fchm.median_salary_year
FROM company_mart.fact_company_hiring_monthly fchm
JOIN company_mart.dim_company dc ON fchm.company_id = dc.company_id
JOIN company_mart.dim_job_title_short djs ON fchm.job_title_short_id = djs.job_title_short_id
ORDER BY fchm.postings_count DESC, fchm.median_salary_year DESC 
LIMIT 10;