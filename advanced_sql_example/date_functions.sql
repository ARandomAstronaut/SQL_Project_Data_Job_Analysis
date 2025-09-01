SELECT 
    '2023-02-19'::DATE, --use semi-colon to cast the string into a date data type
    '123'::INTEGER,
    'true'::BOOLEAN,
    '3.14'::REAL;


-- the below querry will convert job_posted_date into DATE format (only consist of the date without time)
SELECT
	job_title_short AS title,
	job_location AS location,
	job_posted_date::DATE AS date--Format the date
FROM
	job_postings_fact
ORDER BY
    job_posted_date::DATE DESC;

-- converting and putting on time zones information
-- the idea is to either 1. just specify the time zone or 2. specify the current timezone, and the time zone we want to go to
SELECT
	job_title_short AS title,
	job_location AS location,
	job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
FROM
	job_postings_fact
LIMIT 5;


-- EXTRACT is used to extract either year, month, or date
SELECT
	job_title_short AS title,
	job_location AS location,
	job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST',
    EXTRACT(MONTH FROM job_posted_date) AS job_posted_month, --extracting month
    EXTRACT(YEAR FROM job_posted_date) AS job_posted_year -- extracting year 
FROM
	job_postings_fact
LIMIT 5;

-- example: looking at the month that has the most job postings that is titled 'Data Analyst'
SELECT
    EXTRACT(MONTH FROM job_posted_date) AS job_posted_month, --extracting month
    COUNT(job_id) as job_posted_count
FROM job_postings_fact
WHERE job_title_short ='Data Analyst'
GROUP BY job_posted_month
ORDER BY job_posted_count DESC;



-- Problem 1: Find the average salary both yearly (salary_year_avg) and hourly (salary_hour_avg)
-- for job postings using the job_postings_fact table that were posted after June 1, 2023. Group 
-- the results by job schedule type. Order by the job_schedule_type in ascending order.

-- SELECT * FROM job_postings_fact LIMIT 10;

SELECT
    job_schedule_type,
    AVG(salary_year_avg) AS avg_yearly_salary,
    AVG(salary_hour_avg) AS avg_hourly_salary
FROM job_postings_fact
WHERE job_posted_date::date > '2023-06-01'
GROUP BY job_schedule_type
ORDER BY job_schedule_type;

--problem 2: Count the number of job postings for each month, adjusting the job_posted_date 
-- to be in 'America/New_York' time zone before extracting the month. Assume the job_posted_date
-- is stored in UTC. Group by and order by the month.
SELECT
    EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') AS job_posted_month,
	COUNT(*) AS job_postings_count
FROM job_postings_fact
GROUP BY job_posted_month
ORDER BY job_posted_month;


--problem 3: Find companies (include company name) that have posted jobs offering health insurance, 
-- where these postings were made in the second quarter of 2023. Use date extraction to filter by quarter.
--  And order by the job postings count from highest to lowest.

SELECT
    company_dim.name AS company_name,
    COUNT(job_postings_fact.job_id) AS job_postings_count
FROM
    job_postings_fact
	INNER JOIN -- we inner join company_dim to get the company name from the foreign key company_id
    company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_postings_fact.job_health_insurance = TRUE
    AND EXTRACT(QUARTER FROM job_postings_fact.job_posted_date) = 2 -- job posted in the 2nd quarter
GROUP BY company_dim.name -- group by company name
HAVING COUNT(job_postings_fact.job_id) > 0 -- we have to use HAVING because of aggregate + logic 
ORDER BY job_postings_count DESC; 

	
--SELECT * FROM company_dim LIMIT 10;

-- create a table for Jan 2023, Feb 2023, Mar 2023 of the job postings
SELECT * FROM job_postings_fact LIMIT 10;

-- extract months out of the job_posted_date column
CREATE TABLE january_jobs AS 
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;
    -- LIMIT 10; -- this line is used for debugging

-- For February
CREATE TABLE february_jobs AS 
	SELECT * 
	FROM job_postings_fact
	WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

-- For March
CREATE TABLE march_jobs AS 
	SELECT * 
	FROM job_postings_fact
	WHERE EXTRACT(MONTH FROM job_posted_date) = 3;