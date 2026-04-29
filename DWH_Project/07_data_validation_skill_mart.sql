-- Step 7: Daata Validation for Skill Mart Tables

SELECT '===== Data Validation for Skill Mart =====' AS info;
SELECT table_catalog, table_schema, table_name FROM information_schema.tables WHERE table_schema = 'skill_mart';

SELECT '===== Tables Entry Count: =====' AS info;
SELECT 'dim_skills' AS table, COUNT(*) AS entry_count FROM skill_mart.dim_skills
UNION
SELECT 'dim_date_month', COUNT(*) FROM skill_mart.dim_date_month
UNION
SELECT 'fact_skill_demand_monthly', COUNT(*) AS entry_count FROM skill_mart.fact_skill_demand_monthly;


SELECT '===== Skills Dimension Sample Data: =====' AS info;
SELECT * FROM skill_mart.dim_skills LIMIT 3;

SELECT '===== Date Month Dimension Sample Data: =====' AS info;
SELECT * FROM skill_mart.dim_date_month LIMIT 3;

SELECT '===== Skill Demand Monthly Fact Table Sample Data: =====' AS info;
SELECT * FROM skill_mart.fact_skill_demand_monthly LIMIT 3;