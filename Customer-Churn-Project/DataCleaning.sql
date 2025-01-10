-- ---------------------------------------------------------------------------------------------------------
-- DATABASE INITIALIZATION
CREATE DATABASE my_database;
USE my_database;
-- ---------------------------------------------------------------------------------------------------------
-- CREATE TABLES AND IMPORT DATA 
	-- customer_info
CREATE TABLE raw_customer_info (
    customer_id VARCHAR(255) NOT NULL PRIMARY KEY,
    gender VARCHAR(10),
    age INT,
    under_30 VARCHAR(10),
    senior_citizen VARCHAR(10),
    partner VARCHAR(10),
    dependents VARCHAR(10),
    number_of_dependents INT,
    married VARCHAR(10)
);

LOAD DATA INFILE '/Users/alyssajuarez/mysql-secure-folder/Customer_Info.csv'
INTO TABLE raw_customer_info
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

DESCRIBE raw_customer_info;

	-- location_info
CREATE TABLE raw_location_info (
  customer_id VARCHAR(50) NOT NULL PRIMARY KEY,
  country VARCHAR(50),
  state VARCHAR(50),
  city VARCHAR(50),
  zip_code VARCHAR(50),
  total_population INT,
  latitude DECIMAL(9, 6),
  longitude DECIMAL(9, 6)
);


LOAD DATA INFILE '/Users/alyssajuarez/mysql-secure-folder/Location_Data.csv'
INTO TABLE raw_location_info
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

DESCRIBE raw_location_info;

	-- online_services
CREATE TABLE raw_online_services (
  customer_id VARCHAR(50) NOT NULL PRIMARY KEY,
  phone_service VARCHAR(50),
  internet_service VARCHAR(50),
  online_security VARCHAR(50),
  online_backup VARCHAR(50),
  device_protection VARCHAR(50),
  premium_tech_support VARCHAR(50),
  streaming_tv VARCHAR(50),
  streaming_movies VARCHAR(50),
  streaming_music VARCHAR(50),
  internet_type VARCHAR(50)
);

LOAD DATA INFILE '/Users/alyssajuarez/mysql-secure-folder/Online_Services.csv'
INTO TABLE raw_online_services
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

DESCRIBE raw_online_services;

	-- payment_info
CREATE TABLE raw_payment_info (
customer_id VARCHAR(50) NOT NULL PRIMARY KEY,
contract VARCHAR(50),
paperless_billing VARCHAR(50),
payment_method VARCHAR(50),
monthly_charges FLOAT,
avg_monthly_long_distance_charges FLOAT,
total_charges FLOAT,
total_refunds FLOAT,
total_extra_data_charges FLOAT,
total_long_distance_charges FLOAT,
total_revenue FLOAT
);
LOAD DATA INFILE '/Users/alyssajuarez/mysql-secure-folder/Payment_Info-C.csv'
INTO TABLE raw_payment_info
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

DESCRIBE raw_payment_info;

	-- service_options
CREATE TABLE raw_service_options (
    customer_id VARCHAR(10) NOT NULL PRIMARY KEY,
    tenure INT,
    internet_service VARCHAR(10),
    phone_service VARCHAR(10),
    multiple_lines VARCHAR(10),
    avg_monthly_gb_download INT,
    unlimited_data VARCHAR(10),
    offer VARCHAR(10),
    referred_a_friend VARCHAR(10),
    number_of_referrals INT
);

LOAD DATA INFILE '/Users/alyssajuarez/mysql-secure-folder/Service_Options.csv'
INTO TABLE raw_service_options
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

DESCRIBE raw_service_options;

	-- Status Analysis
CREATE TABLE raw_status_analysis (
customer_id VARCHAR(10) NOT NULL PRIMARY KEY,
satisfaction_score INT,
cltv INT,
customer_status VARCHAR(10),
churn_score INT,
churn_label VARCHAR(10),
churn_value INT,
churn_category VARCHAR(20),
churn_reason VARCHAR(50)
);

LOAD DATA INFILE '/Users/alyssajuarez/mysql-secure-folder/Status_Analysis.csv'
INTO TABLE raw_status_analysis
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

DESCRIBE raw_status_analysis;
-- ----------------------------------------------------------------------------------------------------------
-- CREATE STAGING DATA
	/* Staging data is what we will be cleaning, 
    this preserves the raw data in the instance a mistake 
    is made and is the best practice */

CREATE TABLE customer LIKE raw_customer_info;
INSERT INTO customer
SELECT * FROM raw_customer_info;
SELECT COUNT(*) FROM customer;
SELECT * FROM customer;

CREATE TABLE location LIKE raw_location_info;
INSERT INTO location
SELECT * FROM raw_location_info;
SELECT COUNT(*) FROM location;
SELECT * FROM location;

CREATE TABLE services LIKE raw_online_services;
INSERT INTO services
SELECT * FROM raw_online_services;
SELECT COUNT(*) FROM services;
SELECT * FROM services;

CREATE TABLE payment LIKE raw_payment_info;
INSERT INTO payment
SELECT * FROM raw_payment_info;
SELECT COUNT(*) FROM payment;
SELECT * FROM payment;

CREATE TABLE s_options LIKE raw_service_options;
INSERT INTO s_options
SELECT * FROM raw_service_options;
SELECT COUNT(*) FROM s_options;
SELECT * FROM s_options;

CREATE TABLE stat LIKE raw_status_analysis;
INSERT INTO stat
SELECT * FROM raw_status_analysis;
SELECT COUNT(*) FROM stat;
SELECT * FROM stat;
	-- note that all data has 7043 rows
-- --------------------------------------------------------------------------------------------------------    
-- DATA CLEANING
	/* 
    Here we will beging the data cleaning process.
    To clean the data we will follow these steps:
		* Remove duplicates 
			- We used a PRIMARY KEY, which only uses unique values, so we can skip this step.
        * Handle missing value/nulls 
			- we can check for nulls intially by using distinct.
        * Standardize formats
			- In this dataset we did this by removing hidden characters
	It is best practice to remove duplicates and nulls/missing values prior to joining datasets. 
    Since my dataset had a large number of hidden characters (/r), 
    I decided to join the datasets prior to removing the hidden characters
    */

 -- check customer
SELECT DISTINCT(gender) FROM customer;
SELECT DISTINCT(age) FROM customer;
SELECT DISTINCT(under_30) FROM customer;
SELECT DISTINCT(senior_citizen) FROM customer;
SELECT DISTINCT(partner) FROM customer;
SELECT DISTINCT(dependents) FROM customer;
SELECT DISTINCT(number_of_dependents) FROM customer;
SELECT DISTINCT(married) FROM customer; -- 2 yes values

		-- Since we eliminated the white space, we can use hex to find why there are 2 Yes values
SELECT HEX(married) AS hex_value, COUNT(*) AS count
FROM customer
GROUP BY HEX(married)
ORDER BY count DESC;
		-- '59657330D' suggests there are hidden characters in the data (/r)
UPDATE customer
SET married = 'Yes'
WHERE HEX(married) = '5965730D';
		/*After checking the hex again, the issue for this column has been resolved. 
        However upon further inspection this seems to be a constant issue in the data, 
        therefore we will work on this more down the road. */

	-- check location
SELECT DISTINCT(country) FROM location; -- only United States
SELECT DISTINCT(state) FROM location; -- only california
SELECT DISTINCT(city) FROM location; 
SELECT DISTINCT(zip_code) FROM location;
SELECT DISTINCT(total_population) FROM location;
SELECT DISTINCT(latitude) FROM location;
SELECT DISTINCT(longitude) FROM location;

	-- Each city has their own latitude & longitude.
SELECT latitude, longitude, COUNT(DISTINCT city) AS unique_cities_count
FROM location
GROUP BY latitude, longitude
HAVING unique_cities_count > 1; 

	-- check services
SELECT DISTINCT(phone_service) FROM services;
SELECT DISTINCT(internet_service) FROM services;
SELECT DISTINCT(online_security) FROM services;
SELECT DISTINCT(online_backup) FROM services;
SELECT DISTINCT(device_protection) FROM services;
SELECT DISTINCT(premium_tech_support) FROM services;
SELECT DISTINCT(streaming_tv) FROM services;
SELECT DISTINCT(streaming_movies) FROM services;
SELECT DISTINCT(streaming_music) FROM services;
SELECT DISTINCT(internet_type) FROM services; -- almost all of the data has hidden characters

	-- Check payment
SELECT DISTINCT(contract) FROM payment;
SELECT DISTINCT(paperless_billing) FROM payment;
SELECT DISTINCT(payment_method) FROM payment;
SELECT DISTINCT(monthly_charges) FROM payment;
SELECT DISTINCT(avg_monthly_long_distance_charges) FROM payment;
SELECT DISTINCT(total_charges) FROM payment;
SELECT DISTINCT(total_refunds) FROM payment;
SELECT DISTINCT(total_extra_data_charges) FROM payment;
SELECT DISTINCT(total_long_distance_charges) FROM payment;
SELECT DISTINCT(total_revenue) FROM payment;

	-- Check s_options
SELECT DISTINCT(tenure) FROM s_options;
SELECT DISTINCT(internet_service) FROM s_options;
SELECT DISTINCT(phone_service) FROM s_options;
SELECT DISTINCT(multiple_lines) FROM s_options;
SELECT DISTINCT(avg_monthly_gb_download) FROM s_options;
SELECT DISTINCT(unlimited_data) FROM s_options;
SELECT DISTINCT(offer) FROM s_options;
SELECT DISTINCT(referred_a_friend) FROM s_options;
SELECT DISTINCT(number_of_referrals) FROM s_options;

	-- Check Stat
SELECT DISTINCT(satisfaction_score) FROM stat;
SELECT DISTINCT(cltv) FROM stat;
SELECT DISTINCT(customer_status) FROM stat;
SELECT DISTINCT(churn_score) FROM stat;
SELECT DISTINCT(churn_label) FROM stat;
SELECT DISTINCT(churn_value) FROM stat;
SELECT DISTINCT(churn_category) FROM stat;
SELECT DISTINCT(churn_reason) FROM stat;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- JOINING THE DATASETS
	/* we can conclude there are no duplicaates or nulls that need addressing, 
    however we do have some hidden characters, We will go ahead and join the 
    dataset then handle the hidden characters */

CREATE TABLE temp_dataset AS 
SELECT 
    c.*, 
	l.city, l.zip_code, l.total_population, -- dropped country and state since all were California, USA, also dropped latitude and longitude since they were redundant
    p.contract, p.paperless_billing, p.payment_method, p.monthly_charges, 
    p.avg_monthly_long_distance_charges, p.total_charges, p.total_refunds, 
    p.total_extra_data_charges, p.total_long_distance_charges, p.total_revenue,
    s.phone_service AS s_phone_service, s.internet_service AS s_internet_service, 
    s.multiple_lines, s.avg_monthly_gb_download, s.unlimited_data, s.offer, 
    s.referred_a_friend, s.number_of_referrals,
    os.phone_service AS os_phone_service, os.internet_service AS os_internet_service, 
    os.online_security, os.online_backup, os.device_protection, 
    os.premium_tech_support, os.streaming_tv, os.streaming_movies, 
    os.streaming_music, os.internet_type,
    st.satisfaction_score, st.cltv, st.customer_status, st.churn_score, 
    st.churn_label, st.churn_value, st.churn_category, st.churn_reason
FROM 
    customer c
LEFT JOIN location l ON c.customer_id = l.customer_id
LEFT JOIN payment p ON c.customer_id = p.customer_id
LEFT JOIN services os ON c.customer_id = os.customer_id
LEFT JOIN s_options s ON c.customer_id = s.customer_id
LEFT JOIN stat st ON c.customer_id = st.customer_id;

-- ----------------------------------------------------------------------------------------------------
-- GET RID OF HIDDEN CHARACTERS

SET SESSION group_concat_max_len = 1000000;

SET @update_query = (
    SELECT GROUP_CONCAT(
        CONCAT(
            column_name, " = REPLACE(", column_name, ", CHAR(13), '')"
        )
    )
    FROM information_schema.columns
    WHERE table_name = 'temp_dataset' 
      AND table_schema = 'my_database'
);

SET @final_query = CONCAT('UPDATE my_database.temp_dataset SET ', @update_query);

SET SQL_SAFE_UPDATES = 0; 
PREPARE stmt FROM @final_query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SELECT * FROM my_database.temp_dataset;

-- -------------------------------------------------------------------------------------------------------
-- EXPORT
SELECT *
FROM temp_dataset
INTO OUTFILE '/Users/alyssajuarez/mysql-secure-folder/clean_customer_churn_data.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n';



