-- Union combines results from two or more SELECT statemets but they 
-- must have the same data type for each column and same number of column
-- UNION will help us get rid of duplicate rows
-- UNION ALL will not get rid of duplicate rows
-- Using UNION returns 143,227 rows
-- Using UNION ALL instead of UNION returns 220,984 rows

--Using UNION
SELECT -- Get jobs and companies from January
	job_title_short,
	company_id,
	job_location
FROM january_jobs

UNION -- combine the two tables 

SELECT -- Get jobs and companies from February 
	job_title_short,
	company_id,
	job_location
FROM february_jobs

UNION -- combine another table

SELECT -- Get jobs and companies from March
	job_title_short,
	company_id,
	job_location
FROM march_jobs;

--Using UNION ALL instead of just UNION
SELECT -- Get jobs and companies from January
	job_title_short,
	company_id,
	job_location
FROM january_jobs

UNION ALL-- combine the two tables 

SELECT -- Get jobs and companies from February 
	job_title_short,
	company_id,
	job_location
FROM february_jobs

UNION ALL -- combine another table

SELECT -- Get jobs and companies from March
	job_title_short,
	company_id,
	job_location
FROM march_jobs