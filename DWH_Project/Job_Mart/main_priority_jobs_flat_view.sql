-- Creating and Loading Data into View: main.priority_jobs_flat_view
CREATE OR REPLACE VIEW main.priority_jobs_flat_view
AS
SELECT
    f.*
FROM
    staging.job_postings_flat AS f
    LEFT JOIN staging.priority_roles AS p ON p.role_name = f.job_title_short
WHERE
    p.priority_lvl = 1;

-- Checking Data
SELECT * FROM main.priority_jobs_flat_view;