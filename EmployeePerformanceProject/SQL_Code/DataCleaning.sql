# THE SETUP
CREATE DATABASE employee_performance;
Use employee_performance;

# UPLOAD DATA
CREATE TABLE raw_employee_data (
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
    
LOAD DATA INFILE '/Users/alyssajuarez/mysql-secure-folder/employee_data.csv'
INTO TABLE raw_employee_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM raw_employee_data;
SELECT COUNT(*) FROM raw_employee_data;

# Create Staging Data
CREATE TABLE employee_data LIKE raw_employee_data;
INSERT INTO employee_data
SELECT * FROM raw_employee_data;

# INITAL LOOK
SELECT * FROM employee_data; -- staging data up and running
SELECT COUNT(*) FROM employee_data; -- count aligns with original data

# CLEANING
	-- Duplicates Check
SELECT employee_id, COUNT(*) AS duplicate_count
FROM employee_data
GROUP BY employee_id
HAVING COUNT(*) > 1;
		# I have 2 instances where an employe_id is duplicated

	-- Using MIN method to delete duplicates   
ALTER TABLE employee_data
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;

SET SQL_SAFE_UPDATES = 0;

SELECT MIN(id) AS id
FROM employee_data
GROUP BY employee_id;

DELETE FROM employee_data
WHERE id NOT IN (
    SELECT id
    FROM (
        SELECT MIN(id) AS id
        FROM employee_data
        GROUP BY employee_id
    ) AS temp
);

SELECT employee_id, COUNT(*)
FROM employee_data
GROUP BY employee_id
HAVING COUNT(*) > 1;

SELECT * FROM employee_data;
	
    -- Drop id column now that it is no longer needed 
ALTER TABLE employee_data
DROP COLUMN id;

SET SQL_SAFE_UPDATES = 1;

-- Check for NULL/''
SELECT 
    COUNT(CASE WHEN employee_id IS NULL OR employee_id = '' THEN 1 END) AS employee_id_issues,
    COUNT(CASE WHEN department IS NULL OR department = '' THEN 1 END) AS department_issues,
    COUNT(CASE WHEN region IS NULL OR region = '' THEN 1 END) AS region_issues,
    COUNT(CASE WHEN education IS NULL OR education = '' THEN 1 END) AS education_issues,
    COUNT(CASE WHEN gender IS NULL OR gender = '' THEN 1 END) AS gender_issues,
    COUNT(CASE WHEN recruitment_channel IS NULL OR recruitment_channel = '' THEN 1 END) AS recruitment_channel_issues,
    COUNT(CASE WHEN previous_year_rating IS NULL OR previous_year_rating = '' THEN 1 END) AS previous_year_rating_issues
FROM employee_data;

-- I have 2 columns with null values; education and previous_year_rating

SELECT * 
FROM employee_data 
WHERE previous_year_rating = '' and length_of_service > 1;

SELECT DISTINCT(length_of_service) FROM employee_data;
-- From here we can conclude that this value is blank because these are new hires who have not yet had a rating

SELECT DISTINCT(education) FROM employee_data;
-- it is clear there is a gap, secondary and associates degrees are not covered. we will combine them sine we have no way to distinguish from the 2.
	
    -- Update table accordingly
SET SQL_SAFE_UPDATES = 0;
UPDATE employee_data
SET previous_year_rating = NULL
WHERE previous_year_rating = '';

UPDATE employee_data
SET education = 'Secondary or Associate'
WHERE education = '';

SET SQL_SAFE_UPDATES = 1;

-- Formatting & Column drop
	-- the region column has a redundant prefix i want to remove 
SET SQL_SAFE_UPDATES = 0; 
UPDATE employee_data
SET region = REPLACE(region, 'region_', '')
WHERE region LIKE 'region_%';
SET SQL_SAFE_UPDATES = 1;

-- Final look after basic cleaning
SELECT * FROM employee_data;

-- Export
SELECT * INTO OUTFILE '/Users/alyssajuarez/mysql-secure-folder/employee_data_cleaned.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM employee_data;
