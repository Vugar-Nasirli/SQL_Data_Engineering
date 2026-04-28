-- Creating and Loading Data into Temporary Table: senior_jobs_flat_temp
CREATE OR REPLACE TEMPORARY TABLE senior_jobs_flat_temp
AS
SELECT
    *
FROM
    main.priority_jobs_flat_view
WHERE
    job_title_short LIKE 'Senior%';