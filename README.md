update the content later
this project will answer these following question from the given dataset: 

# Intro
Dive into data job market. This project will explore the jobs and skills that are in high in demand for a Data Analyst. 

SQL Querries: [project_sql folder](/project_sql/)

# Background
Driven by a mission to find high paying analyst jobs in a declining job market. AI has been taking many data analyst jobs away and it is essential that we act fast and learn the skills that is still in demand in a declining market. 

All data were given to me at the courtesy of Luke Barousse[](/) from my [SQL Course](/create_data/). 

### The questions I wanted to answer: 
1. What are the top paying jobs? 
2. What skills are required for these top paying jobs (in question 1)?
3. What skills are most in demand for data analyst?
4. Which skills are associated with higher pay? 
5. What are the most optimal skills to learn? 

# Tools I used 
- SQL: The language that provides me with the capability to write querries to process large amount of data from my local database.
- Postgres SQL: The database management system that I picked due to its popularity and ease of use
- VS Code: My go to code editor due to its smooth intergration with github
- Git & Github: Essential for version control and sharing my SQL scripts and analysis. Ensures collaboration and project tracking is clear and smooth. 

# The Analysis 
Each querry for this project answers a specific question that aims to investigatea spects of the data analyst job market. Here is what each querry does: 

### 1. Top Paying Data Analyst Jobs
To identify the higest paying roles, I filtered data analyst positions by avergae salary and location, focusing on remote jobs. This query highlights the high paying opporunities in the field. 

``` sql
SELECT
	job_id,
	job_title,
	job_location,
	job_schedule_type,
	salary_year_avg,
	job_posted_date
	-- name AS company_name
FROM job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
	job_title = 'Data Analyst'
	AND salary_year_avg IS NOT NULL -- we are not interested in job postings without  salary information
	AND job_location = 'Anywhere'
ORDER BY salary_year_avg DESC 
LIMIT 10;
```

Here's a break down of the top data analyst jobs in 2023: 
- Wide Salary Range: Top 10 paying data analyst roles span from $184,000 to $650,000. This indicates significant slaary potential in the data analyst field. 
- Diverse Employers: Companies like SmartAsset, Meta, and Raytheon are amongst the highest payers for data analyst, showing a broad interest across the industries. 
- Job Title Variety: There's a high diversity in job titles, from "Data Analyst" to "Director of Analystics". Reflecting varied roles and specialization within data analytic. 
![Alt text](URL_TO_IMAGE)

### 2. Skills for Top Paying jobs
To understand what skills are required for the top-paying jobs, I joined the job postings with the skills data, providing insights into what employers value for high-compensation roles.

``` sql
WITH top_paying_jobs AS (
    SELECT
        job_id,
        job_title,
        salary_year_avg
        -- name AS company_name
    FROM job_postings_fact
    LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_title_short = 'Data Analyst'
				AND salary_year_avg IS NOT NULL
        AND job_location = 'Anywhere'
    ORDER BY salary_year_avg DESC
    LIMIT 10
)

-- Skills required for data analyst jobs
SELECT
    top_paying_jobs.job_id,
    job_title,
    salary_year_avg,
    skills
FROM
    top_paying_jobs
	INNER JOIN
    skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
	INNER JOIN
    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY salary_year_avg DESC;
```

### 3. In-Demand Skills for Data Analytic
This query helped identify the skills most frequently requested in job postings, directing focus to areas with high demand.

``` sql
SELECT
  skills_dim.skills,
  COUNT(skills_job_dim.job_id) AS demand_count
FROM
  job_postings_fact
  INNER JOIN
    skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
  INNER JOIN
    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
  -- Filters job titles for 'Data Analyst' roles
  job_postings_fact.job_title_short = 'Data Analyst' AND job_work_from_home = True -- optional to filter for remote jobs
GROUP BY
  skills_dim.skills
ORDER BY
  demand_count DESC
LIMIT 5;
```

### 4. Skills Based on Salary
Exploring the average salaries associated with different skills revealed which skills are the highest paying.

``` sql
SELECT
  skills_dim.skills AS skill, 
  ROUND(AVG(job_postings_fact.salary_year_avg),2) AS avg_salary
FROM
  job_postings_fact
	INNER JOIN
	  skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
	INNER JOIN
	  skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
  job_postings_fact.job_title_short = 'Data Analyst' 
  AND job_postings_fact.salary_year_avg IS NOT NULL AND job_work_from_home = True  -- optional to filter for remote jobs
GROUP BY skills_dim.skills 
ORDER BY avg_salary DESC; 
```

### 5. Most Optimal Skills to Learn
Combining insights from demand and salary data, this query aimed to pinpoint skills that are both in high demand and have high salaries, offering a strategic focus for skill development.
``` sql
-- Identifies skills in high demand for Data Analyst roles
-- Use Query #3 (but modified)
WITH skills_demand AS (
  SELECT
    skills_dim.skill_id,
		skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS demand_count
  FROM
    job_postings_fact
	  INNER JOIN
	    skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
	  INNER JOIN
	    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
  WHERE
    job_postings_fact.job_title_short = 'Data Analyst'
		AND job_postings_fact.salary_year_avg IS NOT NULL
    AND job_postings_fact.job_work_from_home = True
  GROUP BY skills_dim.skill_id
),
-- Skills with high average salaries for Data Analyst roles
-- Use Query #4 (but modified)
average_salary AS (
  SELECT
    skills_job_dim.skill_id,
    AVG(job_postings_fact.salary_year_avg) AS avg_salary
  FROM
    job_postings_fact
	  INNER JOIN
	    skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
	  -- There's no INNER JOIN to skills_dim because we got rid of the skills_dim.name 
  WHERE
    job_postings_fact.job_title_short = 'Data Analyst'
		AND job_postings_fact.salary_year_avg IS NOT NULL
    AND job_postings_fact.job_work_from_home = True
  GROUP BY skills_job_dim.skill_id
)
-- Return high demand and high salaries for 10 skills 
SELECT
  skills_demand.skills,
  skills_demand.demand_count,
  ROUND(average_salary.avg_salary, 2) AS avg_salary --ROUND to 2 decimals 
FROM
  skills_demand
	INNER JOIN
	  average_salary ON skills_demand.skill_id = average_salary.skill_id
-- WHERE demand_count > 10
ORDER BY demand_count DESC, avg_salary DESC
LIMIT 25; --Limit 25
```

# Lessons Learned
Throughout this project, I honed several key SQL techniques and skills:
- **Complex Query Construction**: Learning to build advanced SQL queries that combine multiple tables and employ functions like **`WITH`** clauses for temporary tables.
- **Data Aggregation**: Utilizing **`GROUP BY`** and aggregate functions like **`COUNT()`** and **`AVG()`** to summarize data effectively.
- **Analytical Thinking**: Developing the ability to translate real-world questions into actionable SQL queries that got insightful answers.

### **Insights**

From the analysis, several general insights emerged:

1. **Top-Paying Data Analyst Jobs**: The highest-paying jobs for data analysts that allow remote work offer a wide range of salaries, the highest at $650,000!
2. **Skills for Top-Paying Jobs**: High-paying data analyst jobs require advanced proficiency in SQL, suggesting it’s a critical skill for earning a top salary.
3. **Most In-Demand Skills**: SQL is also the most demanded skill in the data analyst job market, thus making it essential for job seekers.
4. **Skills with Higher Salaries**: Specialized skills, such as SVN and Solidity, are associated with the highest average salaries, indicating a premium on niche expertise.
5. **Optimal Skills for Job Market Value**: SQL leads in demand and offers for a high average salary, positioning it as one of the most optimal skills for data analysts to learn to maximize their market value.

### **Conclusion**

This project enhanced my SQL skills and provided valuable insights into the data analyst job market. The findings from the analysis serve as a guide to prioritizing skill development and job search efforts. Aspiring data analysts can better position themselves in a competitive job market by focusing on high-demand, high-salary skills. This exploration highlights the importance of continuous learning and adaptation to emerging trends in the field of data analytics.



