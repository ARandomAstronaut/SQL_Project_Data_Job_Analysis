
--convert job_locations to either 'remote', 'onsite' or 'local'
SELECT 
    job_title_short,
    job_location,
    CASE -- CASE is like an if statement in Pyhton or other programming languages
	    WHEN job_location = 'Anywhere' THEN 'Remote'    --if joblocation = anwhere: location catergory = remote
        WHEN job_location = 'Boston, MA' THEN 'Local'   -- elif joblocation = boston, MA: location catergory = local 
	    ELSE 'Onsite'                                   -- else: location catergory = onsite
    END AS location_category
FROM job_postings_fact;



-- we want to convert joblocations to 'remote' 'onsite', or 'local'
-- but only for Data Analyst
-- we also want to count how many of each catergory there are
SELECT 
    -- notice how the job_title_short and job_location has been comented out? 
    -- this is so that the groupby function can execute properly
    --job_title_short,
    --job_location,
    CASE -- CASE is like an if statement in Pyhton or other programming languages
	    WHEN job_location = 'Anywhere' THEN 'Remote'    --if joblocation = anwhere: location catergory = remote
        WHEN job_location = 'Boston, MA' THEN 'Local'   -- elif joblocation = boston, MA: location catergory = local 
	    ELSE 'Onsite'                                   -- else: location catergory = onsite
    END AS location_category,
    COUNT(job_id) AS number_of_jobs -- using count to aggregate the jobs number
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY location_category
ORDER BY number_of_jobs DESC;

-- problem 1: From the job_postings_fact table, categorize the salaries from job postings that are
-- data analyst jobs, and that have yearly salary information. Put salary into 3 different categories:
    --1. If the salary_year_avg is greater than or equal to $100,000, then return ‘high salary’.
    --2. If the salary_year_avg is greater than or equal to $60,000 but less than $100,000, then return ‘Standard salary.’
    --3. If the salary_year_avg is below $60,000 return ‘Low salary’.

--Also, order from the highest to the lowest salaries.

SELECT 
    salary_year_avg,
    CASE    
        WHEN salary_year_avg >= 100000 THEN 'high salary'
        WHEN salary_year_avg >= 60000 THEN 'Standard salary'
        WHEN salary_year_avg < 600000 THEN 'Low salary'
    END AS salary_category
FROM job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
    and job_title_short = 'Data Analyst'
ORDER BY salary_year_avg DESC; 

--problem 2: Count the number of unique companies that offer work from home (WFH) versus those 
--requiring work to be on-site. Use the job_postings_fact table to count and compare the distinct 
-- companies based on their WFH policy (job_work_from_home).
-- solution 1: what I did 
SELECT
CASE 
    WHEN job_work_from_home = TRUE THEN 'wfh_companies'
    WHEN job_work_from_home = FALSE THEN 'non_wfh_companies'
END AS company_type,
COUNT(DISTINCT company_id)
FROM job_postings_fact
GROUP BY company_type;
--solution 2: shorter way by combining COUNT DISTINCT and CASE expression
SELECT 
    COUNT(DISTINCT CASE WHEN job_work_from_home = TRUE THEN company_id END) AS wfh_companies,
    COUNT(DISTINCT CASE WHEN job_work_from_home = FALSE THEN company_id END) AS non_wfh_companies
FROM job_postings_fact;

-- problem 3: Write a SQL query using the job_postings_fact table that returns the following columns:
-- job_id, salary_year_avg, experience_level (derived using a CASE WHEN), remote_option (derived using a CASE WHEN), 
-- Only include rows where salary_year_avg is not null.
SELECT 
  job_id,
  salary_year_avg,
  CASE -- we used ILIKE instead of LIKE to deal with non-case sensitive situation (PostgreSQL-specific)
      WHEN job_title ILIKE '%Senior%' THEN 'Senior'
      WHEN job_title ILIKE '%Manager%' OR job_title ILIKE '%Lead%' THEN 'Lead/Manager'
      WHEN job_title ILIKE '%Junior%' OR job_title ILIKE '%Entry%' THEN 'Junior/Entry'
      ELSE 'Not Specified'
  END AS experience_level,
  CASE
      WHEN job_work_from_home THEN 'Yes'
      ELSE 'No' 
  END AS remote_option
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL 
ORDER BY job_id;