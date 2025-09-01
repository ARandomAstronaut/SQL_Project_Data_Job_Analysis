--only want to look at companies that don’t require a degree
-- using a subquerry to pull company ID from another table then use in another table without having to combine them
SELECT 
	name as company_name
FROM company_dim 
WHERE company_id IN 
( -- this is the subquerry to pull all companyID for no degree requirement from job_postings facts
    SELECT company_id 
    FROM job_postings_fact 
    WHERE job_no_degree_mention = true
)
ORDER BY name ASC;


-- Find the companies that have the most job openings.
-- Return the total number of jobs with the company name
WITH company_job_count AS 
( -- create a table with company ID and counts how may job posting in each company
    SELECT company_id, COUNT(*) AS total_jobs 
    FROM job_postings_fact 
    GROUP BY company_id
)
SELECT 
	company_dim.name as company_name, 
	company_job_count.total_jobs -- select the column from the table we created
FROM company_dim

-- use left join to make sure the table on the left (company dim) will have all of its company ID
-- then it combines the total jobs with the respective company_id
--if we have used Right Join instead of Left join, companies without job postings woudn't show up in 
-- the column at all rather than showing 0 job postings for a specified company ID like when we used Left Join
LEFT JOIN company_job_count ON company_dim.company_id = company_job_count.company_id 
ORDER BY total_jobs DESC; -- Order from the most job postings to the least (DESC)

-- Practice problem 7: Using CTE and subquerries
-- find the count of remote job posting per skill

--Data naalyst - 
WITH remote_job_skills AS
(
    SELECT skill_id, COUNT(*) AS remote_job_count
    FROM skills_job_dim AS skills_to_job
    INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
    WHERE 
        job_postings.job_work_from_home = TRUE
        AND job_postings.job_title_short = 'Data Analyst'
    GROUP BY skill_id
    LIMIT 5
)

SELECT
    skills.skill_id, 
	skills as skill_name, 
	remote_job_count
FROM remote_job_skills
INNER JOIN skills_dim AS skills ON skills.skill_id = remote_job_skills.skill_id
ORDER BY remote_job_count DESC;


-- problem 1: Identify the top 5 skills that are most frequently mentioned in job postings. Use a subquery 
-- to find the skill IDs with the highest counts in the skills_job_dim table and then join this result with 
-- the skills_dim table to get the skill names.

WITH top5_skills AS -- instead of using dubquerry, I used CTE because why not
(
    SELECT skill_id, COUNT(*) AS skill_count
    FROM skills_job_dim
    GROUP BY skills_job_dim.skill_id
    ORDER BY COUNT(job_id) DESC
    LIMIT 5 -- top 5 skills
)
SELECT * FROM skills_dim -- because WITH statement creates a temporary table, it must be followed by a select statement
INNER JOIN top5_skills ON top5_skills.skill_id = skills_dim.skill_id
ORDER BY top5_skills.skill_count DESC;


-- problem 2: Determine the size category ('Small', 'Medium', or 'Large') for each company by first identifying
-- the number of job postings they have (Using CASE Expressions) A company is considered 'Small' if it has less 
-- than 10 job postings, 'Medium' if the number of job postings is between 10 and 50, and 'Large' if it has more 
-- than 50 job postings

--Use a subquery to calculate the total job postings per company. Implement a subquery to aggregate job counts per company 
--before classifying them based on size.

SELECT
   company_id,
   name,
   CASE-- Categorize companies using CASE expressions
       WHEN job_count < 10 THEN 'Small'
       WHEN job_count BETWEEN 10 AND 50 THEN 'Medium'
       ELSE 'Large'
   END AS company_size
FROM 
(-- Subquery to calculate number of job postings per company 
   SELECT
       company_dim.company_id,
       company_dim.name,
       COUNT(job_postings_fact.job_id) AS job_count
   FROM company_dim
   INNER JOIN job_postings_fact ON company_dim.company_id = job_postings_fact.company_id
   GROUP BY company_dim.company_id, company_dim.name -- must include every non-aggregated column in the GROUP BY unless the 
   --DB knows that one column is functionally determined by another (like a primary key relationship). In this case, 
   --grouping by just company_id makes sense logically, but SQL syntax rules require you to also list name unless the DB 
   --enforces that company_id → name.
) AS company_job_count;


--problem 3: Your goal is to find the names of companies that have an average salary greater than the overall average 
--salary across all job postings. You'll need to use two tables: company_dim (for company names) and job_postings_fact 
-- (for salary data). The solution requires using subqueries.

SELECT company_dim.name, company_salaries.avg_salary FROM company_dim
INNER JOIN 
( -- inner joining one subquerry to our desired result
  -- This Subquery calculates average salary per company
    SELECT company_id, AVG(salary_year_avg) AS avg_salary
    FROM job_postings_fact
    GROUP BY company_id
) AS company_salaries ON company_dim.company_id = company_salaries.company_id
-- Filter for companies with an average salary greater than the overall average
WHERE company_salaries.avg_salary > ( -- companies_salaries is the table we just created above
    -- This Subquery calculates the overall average salary across all postings in job_postings_fact
    SELECT AVG(salary_year_avg)
    FROM job_postings_fact
);