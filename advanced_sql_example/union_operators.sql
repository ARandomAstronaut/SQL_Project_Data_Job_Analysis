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
FROM march_jobs;



-- practice problem 8: Using UNION/UNION ALL;
-- I only want to look at job postings from the first quarter that have a salary greater 
--than $70k. Combine job posting tables from the first quarter of 2023 (Jan-Mar) Gets job postings
--  with an average yearly salary > $70,000 from the first quarter of 2023 (Jan-Mar)
-- ⚠️ Note: Alias is necessary because it will return an error without it. It’s needed for subqueries in the FROM clause.
SELECT
	quarter1_job_postings.job_title_short,
	quarter1_job_postings.job_location,
	quarter1_job_postings.job_via,
	quarter1_job_postings.job_posted_date::DATE
FROM
	(-- Gets all rows from January, February, and March job postings 
		SELECT *
		FROM january_jobs
		UNION ALL
		SELECT *
		FROM february_jobs
		UNION ALL 
		SELECT *
		FROM march_jobs
	) AS quarter1_job_postings 
WHERE quarter1_job_postings.salary_year_avg > 70000 AND job_postings.job_title_short = 'Data Analyst'
ORDER BY quarter1_job_postings.salary_year_avg DESC

--Problem 1: Create a unified query that categorizes job postings into two groups: those with salary 
--information (salary_year_avg or salary_hour_avg is not null) and those without it. Each job po
-- Select job postings with salary information
(
SELECT 
    job_id, 
    job_title, 
    'With Salary Info' AS salary_info  -- Custom field indicating salary info presence
FROM 
    job_postings_fact
WHERE 
    salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL  
)
UNION ALL
 -- Select job postings without salary information
(
SELECT 
    job_id, 
    job_title, 
    'Without Salary Info' AS salary_info  -- Custom field indicating absence of salary info
FROM 
    job_postings_fact
WHERE 
    salary_year_avg IS NULL AND salary_hour_avg IS NULL 
)
ORDER BY 
    salary_info DESC, 
    job_id; 


-- problem 2: Retrieve the job id, job title short, job location, job via, skill and skill type for 
--each job posting from the first quarter (January to March). Using a subquery to combine job postings 
--from the first quarter (these tables were created in the Advanced Section - Practice Problem 6 Video) 
--Only include postings with an average yearly salary greater than $70,000.
SELECT
    job_postings_q1.job_id,
    job_postings_q1.job_title_short,
    job_postings_q1.job_location,
    job_postings_q1.job_via,
    job_postings_q1.salary_year_avg,
    skills_dim.skills,
    skills_dim.type
FROM
-- Get job postings from the first quarter of 2023
    (
    SELECT *
    FROM january_jobs
    UNION ALL
    SELECT *
    FROM february_jobs
    UNION ALL
    SELECT *
    FROM march_jobs
    ) as job_postings_q1
LEFT JOIN skills_job_dim ON job_postings_q1.job_id = skills_job_dim.job_id
LEFT JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_postings_q1.salary_year_avg > 70000
ORDER BY
    job_postings_q1.job_id;


--problem 3: Analyze the monthly demand for skills by counting the number of job postings for each skill
-- in the first quarter (January to March), utilizing data from separate tables for each month. Ensure to 
--include skills from all job postings across these months. The tables for the first quarter job postings 
--were created in Practice Problem 6.
-- CTE for combining job postings from January, February, and March
WITH combined_job_postings AS (
    SELECT job_id, job_posted_date
    FROM january_jobs
    UNION ALL
    SELECT job_id, job_posted_date
    FROM february_jobs
    UNION ALL
    SELECT job_id, job_posted_date
    FROM march_jobs
),
-- CTE for calculating monthly skill demand based on the combined postings
monthly_skill_demand AS (
    SELECT
        skills_dim.skills,  
        EXTRACT(YEAR FROM combined_job_postings.job_posted_date) AS year,  
        EXTRACT(MONTH FROM combined_job_postings.job_posted_date) AS month,  
        COUNT(combined_job_postings.job_id) AS postings_count 
    FROM
        combined_job_postings
    INNER JOIN skills_job_dim ON combined_job_postings.job_id = skills_job_dim.job_id  
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id  
    GROUP BY
        skills_dim.skills, 
        year, 
        month
)
-- Main query to display the demand for each skill during the first quarter
SELECT
    skills,  
    year,  
    month,  
    postings_count 
FROM
    monthly_skill_demand
ORDER BY
    skills, 
    year,
    month;  