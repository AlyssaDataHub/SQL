-- DATA ANALYSIS
	-- In this session we will be performing data analytics on the employee_data_cleaned.
-- SETUP
CREATE DATABASE employee_performance;
Use employee_performance;

CREATE TABLE employee_data_cleaned (
	employee_id VARCHAR(20),
	department VARCHAR(20),
    region VARCHAR(20),
    education VARCHAR(25),
    gender VARCHAR(20),
    recruitment_channel VARCHAR(20),
    no_of_trainings INT,
    age INT,
    previous_year_rating VARCHAR(20),
    length_of_service INT,
    KPIs_met_more_than_80 INT,
    awards_won INT,
    avg_training_score INT
    );
    
LOAD DATA INFILE '/Users/alyssajuarez/mysql-secure-folder/employee_data_cleaned.csv'
INTO TABLE employee_data_cleaned
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM employee_data_cleaned; -- GOOD TO GO

-- ANALYSIS -----------------------------------------------------------------------------

	-- BASIC STATS
SELECT 
    COUNT(*) AS total_employees,
    AVG(age) AS average_age,
    MAX(length_of_service) AS max_service_years,
    MIN(avg_training_score) AS min_training_score
FROM employee_data;

	-- GENERAL PERCENTAGES
-- Percentage of total employees by department
SELECT 
    department,
    COUNT(*) AS employee_count,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employee_data)), 2) AS percentage
FROM employee_data
GROUP BY department
ORDER BY percentage DESC;

-- Percentage of KPI's met
SELECT 
    KPIs_met_more_than_80,
    COUNT(*) AS employee_count,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employee_data)), 2) AS percentage
FROM employee_data
GROUP BY KPIs_met_more_than_80;

-- Percentage of high performers in each department
SELECT 
    department,
    COUNT(CASE WHEN avg_training_score > 80 THEN 1 END) AS high_performers,
    ROUND((COUNT(CASE WHEN avg_training_score > 80 THEN 1 END) * 100.0 / COUNT(*)), 2) AS high_performance_percentage
FROM employee_data
GROUP BY department
ORDER BY high_performance_percentage DESC;

	-- KPI CORRELATION 
-- KPI and training correlation
SELECT 
    KPIs_met_more_than_80,
    AVG(avg_training_score) AS avg_training_score
FROM employee_data
GROUP BY KPIs_met_more_than_80;

-- KPI & rating
SELECT 
    KPIs_met_more_than_80,
    AVG(previous_year_rating) AS avg_rating
FROM employee_data
GROUP BY KPIs_met_more_than_80;
	-- PERFORMANCE BY RECRUITMENT CHANNEL
    -- traning score by recruitment_channel 
SELECT recruitment_channel, AVG(avg_training_score) AS avg_score
FROM employee_data
GROUP BY recruitment_channel
ORDER BY avg_score DESC;

-- KPI by recruitment_channel
SELECT 
    recruitment_channel,
    ROUND((SUM(KPIs_met_more_than_80) * 100.0 / COUNT(*)), 2) AS kpi_achievement_rate
FROM employee_data
GROUP BY recruitment_channel;

-- Rating by recruitment_channel
SELECT 
    recruitment_channel,
    COUNT(CASE WHEN previous_year_rating > 3 THEN 1 END) AS high_performers,
    ROUND((COUNT(CASE WHEN previous_year_rating > 3 THEN 1 END) * 100.0 / COUNT(*)), 2) AS high_performance_percentage
FROM employee_data
GROUP BY recruitment_channel
ORDER BY high_performance_percentage DESC;

	-- PERFORMANCE BY DEPARTMENT
-- Performance by department 
SELECT department, AVG(avg_training_score) AS avg_score
FROM employee_data
GROUP BY department
ORDER BY avg_score DESC;

-- KPI by department
SELECT 
    department,
    ROUND((SUM(KPIs_met_more_than_80) * 100.0 / COUNT(*)), 2) AS kpi_achievement_rate
FROM employee_data
GROUP BY department;

-- Rating by department
SELECT 
    department,
    COUNT(CASE WHEN previous_year_rating > 3 THEN 1 END) AS high_performers,
    ROUND((COUNT(CASE WHEN previous_year_rating > 3 THEN 1 END) * 100.0 / COUNT(*)), 2) AS high_performance_percentage
FROM employee_data
GROUP BY department
ORDER BY high_performance_percentage DESC;

SELECT 
    department,
    COUNT(CASE WHEN previous_year_rating < 3 THEN 1 END) AS low_rating_employees,
    ROUND((COUNT(CASE WHEN previous_year_rating < 3 THEN 1 END) * 100.0 / COUNT(*)), 2) AS low_rating_employee_percentage
FROM employee_data
GROUP BY department
ORDER BY low_rating_employee_percentage DESC;

	-- HIGH AND UNDER PERFORMERS
-- High Performers
SELECT employee_id, department, avg_training_score, KPIs_met_more_than_80
FROM employee_data
WHERE avg_training_score > 85 AND KPIs_met_more_than_80 = 1
ORDER BY avg_training_score DESC;

SELECT COUNT(*) AS high_performer_count
FROM employee_data
WHERE avg_training_score > 85 AND KPIs_met_more_than_80 = 1;

-- Under Performers
SELECT employee_id, department, avg_training_score, KPIs_met_more_than_80
FROM employee_data
WHERE avg_training_score < 50 AND KPIs_met_more_than_80 = 0;

SELECT COUNT(*) AS under_performer_count
FROM employee_data
WHERE avg_training_score < 50 AND KPIs_met_more_than_80 = 0;
	
    -- PERFORMANCE BY REGION
-- KPI by region
SELECT region, ROUND((SUM(KPIs_met_more_than_80) * 100.0 / COUNT(*)), 2) AS kpi_achievement_rate
FROM employee_data
GROUP BY region
ORDER BY kpi_achievement_rate DESC;

-- avg rating by region
SELECT region, AVG(previous_year_rating) AS avg_rating
FROM employee_data
GROUP BY region
ORDER BY avg_rating DESC;

-- 'Sales & Marketing' Performance by region
SELECT department, region, AVG(avg_training_score), COUNT(*)
FROM employee_data
WHERE department = 'Sales & Marketing'
Group by region;


-- Performance by age
SELECT 
    CASE 
        WHEN age < 25 THEN 'Below 25'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55 and Above'
    END AS age_range,
    AVG(previous_year_rating) AS avg_previous_year_rating
FROM employee_data
GROUP BY age_range
ORDER BY age_range;


SELECT 
    CASE 
        WHEN age < 25 THEN 'Below 25'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55 and Above'
    END AS age_range,
    COUNT(*) AS employee_count,
    SUM(KPIs_met_more_than_80) AS total_KPIs_met,
    ROUND(SUM(KPIs_met_more_than_80) * 100.0 / COUNT(*), 2) AS kpi_achievement_percentage
FROM employee_data
GROUP BY age_range
ORDER BY age_range;

-- performance by education
SELECT education, AVG(previous_year_rating) AS rating
FROM employee_data
GROUP BY education
ORDER BY rating DESC;

SELECT education, ROUND((SUM(KPIs_met_more_than_80) * 100.0 / COUNT(*)), 2) AS kpi_achievement_rate
FROM employee_data
GROUP BY education
ORDER BY kpi_achievement_rate DESC;

	-- HIGH AND UNDER PERFORMING TEAMS
-- high performing teams
SELECT 
    department, 
    region, 
    KPIs_met_more_than_80, 
    AVG(previous_year_rating) AS rating,
    COUNT(*) AS num_employees
FROM employee_data
WHERE KPIs_met_more_than_80 = 1
GROUP BY department, region, KPIs_met_more_than_80
HAVING rating > 3
ORDER BY rating DESC;

-- Under performing teams
SELECT 
    department, 
    region, 
    KPIs_met_more_than_80, 
    AVG(previous_year_rating) AS rating,
    COUNT(*) AS num_employees
FROM employee_data
WHERE KPIs_met_more_than_80 = 0
GROUP BY department, region, KPIs_met_more_than_80
HAVING rating < 3
ORDER BY rating ASC;