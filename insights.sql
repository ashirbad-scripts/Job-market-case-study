CREATE DATABASE job_market;
USE job_market;


/*
----------------------------------------------------------------------------------------------------------------------
Job Market Trends & Demand 
----------------------------------------------------------------------------------------------------------------------
*/

-- Show the count of job postings grouped by industry.
SELECT 
	industry, 
    COUNT(DISTINCT job_id) AS total_postings 
FROM market_data
GROUP BY industry
ORDER BY total_postings DESC;


-- Show the most frequent job titles by counting occurrences in the job_title column.
SELECT 
	job_title,
    COUNT(job_title) AS occurences
FROM market_data
GROUP BY job_title
ORDER BY occurences DESC
LIMIT 5;


-- Show the most common skills by parsing and aggregating values from skills_required.
select * from skills;
SELECT 
	skills_required,
    COUNT(*) AS Times_Required
FROM skills
GROUP BY skills_required
ORDER BY Times_Required DESC
LIMIT 5;


/*
----------------------------------------------------------------------------------------------------------------------
Salary Insights
----------------------------------------------------------------------------------------------------------------------
*/
-- Show the average salary_min_usd and salary_max_usd grouped by industry
SELECT 
	industry,
	CONCAT("$ ", ROUND(AVG(salary_min_usd), 2)) AS avg_min_salary,
    CONCAT("$ ", ROUND(AVG(salary_max_usd), 2)) AS avg_max_salary
FROM market_data
GROUP BY industry;


-- Show the average salary_min_usd and salary_max_usd grouped by job_title.
SELECT 
	job_title,
	CONCAT("$ ", ROUND(AVG(salary_min_usd), 2)) AS avg_min_salary,
    CONCAT("$ ", ROUND(AVG(salary_max_usd), 2)) AS avg_max_salary
FROM market_data
GROUP BY job_title;


-- Show which industries have the highest salary_max_usd values.
SELECT 
	industry,
	MAX(salary_max_usd)
FROM market_data
GROUP BY industry;



-- Show salary ranges grouped by experience_level and compare across levels.
SELECT 
	experience_level,
    CONCAT(
			CONCAT("$ ", ROUND(AVG(salary_min_usd), 0)),
            " - ",
			CONCAT("$ ", ROUND(AVG(salary_max_usd), 0))
			) AS salary_range
FROM market_data
GROUP BY experience_level;



-- Show salary_min_usd and salary_max_usd grouped by employment_type and identify variations.
SELECT 
	employment_type,
	CONCAT("$ ", ROUND(AVG(salary_min_usd), 1)) AS min_salary,
    CONCAT("$ ", ROUND(AVG(salary_max_usd), 1)) AS max_salary
FROM market_data
GROUP BY employment_type;



-- Avg salary_range based on skills
SELECT 
	s.skills_required,
    CONCAT(
			CONCAT("$ ", ROUND(AVG(md.salary_min_usd), 0)),
            " - ",
			CONCAT("$ ", ROUND(AVG(md.salary_max_usd), 0))
		  ) AS salary_range 
FROM market_data md
JOIN skills s ON s.job_id = md.job_id
GROUP BY s.skills_required;


/*
----------------------------------------------------------------------------------------------------------------------
Company-Level Analysis
----------------------------------------------------------------------------------------------------------------------
*/
-- Show the total number of job postings grouped by company_size.
SELECT 
	company_size,
    COUNT(job_id) AS total_postings
FROM company_details
GROUP BY company_size;


-- Show the relationship between company_size and salary ranges by grouping and comparing averages.
SELECT 
	cd.company_size,
	CONCAT(
			CONCAT("$ ", ROUND(AVG(md.salary_min_usd), 0)),
			" - ",
			CONCAT("$ ", ROUND(AVG(md.salary_max_usd), 0))
			) AS salary_range
FROM market_data md
JOIN company_details cd ON cd.job_id = md.job_id
GROUP BY cd.company_size;


-- Show the frequency of tools listed in tools_preferred grouped by company_size.
SELECT 
	cd.company_size,
    t.tools_preferred,
    COUNT(*) AS Frequency
FROM company_details cd
JOIN tools t ON t.job_id = cd.job_id
GROUP BY cd.company_size, t.tools_preferred
ORDER BY cd.company_size, Frequency DESC;

/*
----------------------------------------------------------------------------------------------------------------------
Skills & Tools Deep Dive
----------------------------------------------------------------------------------------------------------------------
*/
-- Show the most frequent tools used by aggregating values in tools_preferred.
SELECT 
	tools_preferred,
    COUNT(*) AS frequency_of_use
FROM tools
GROUP BY tools_preferred
ORDER BY frequency_of_use DESC
LIMIT 5;


-- Show all records where skills_required and tools_preferred share common technologies.
SELECT 
	md.*,
    s.skills_required,
    t.tools_preferred
FROM market_data md
JOIN skills s ON s.job_id = md.job_id
JOIN tools t ON t.job_id = md.job_id
WHERE s.skills_required = t.tools_preferred;


-- Show the average salary ranges for jobs using each tool listed in tools_preferred.
SELECT 
	t.tools_preferred,
    CONCAT(
			CONCAT("$ ", ROUND(AVG(md.salary_min_usd), 0)),
            " - ",
			CONCAT("$ ", ROUND(AVG(md.salary_max_usd), 0))
		  ) AS salary_range 
FROM market_data md
JOIN tools t ON t.job_id = md.job_id
GROUP BY t.tools_preferred;


/*
----------------------------------------------------------------------------------------------------------------------
Experience-Level Breakdown
----------------------------------------------------------------------------------------------------------------------
*/
-- Show the count of jobs posted for each experience_level
SELECT 
    experience_level,
    COUNT(*) AS job_count
FROM market_data
GROUP BY experience_level
ORDER BY job_count DESC;



-- show salary range based on experience level
SELECT 
	experience_level,
    CONCAT(
			CONCAT("$ ", ROUND(AVG(salary_min_usd), 0)),
            " - ",
            CONCAT("$ ", ROUND(AVG(salary_max_usd), 0))
		  ) AS salary_range
FROM market_data
GROUP BY experience_level
ORDER BY experience_level;


/*
----------------------------------------------------------------------------------------------------------------------
Temporal Analysis
----------------------------------------------------------------------------------------------------------------------
*/
-- Show job posting counts grouped by month extracted from posted_date.
SELECT
	MONTHNAME(posted_date) AS `Month`,
    COUNT(job_id) AS Total_Job_Postings
FROM market_data
GROUP BY `Month`
ORDER BY Total_Job_Postings DESC;


-- Show salary trends over time by grouping salary averages by posted_date or month.
SELECT 
	YEAR(posted_date) AS `Year`,
	CONCAT("$ ", ROUND(AVG(salary_min_usd), 2)) AS Avg_Min_Salary,
    CONCAT("$ ", ROUND(AVG(salary_max_usd), 2)) AS Avg_Max_Salary
FROM market_data
GROUP BY `Year`
ORDER BY `Year` DESC;


/*
----------------------------------------------------------------------------------------------------------------------
Competitive Positioning & Market Differentiation
----------------------------------------------------------------------------------------------------------------------
*/
-- Show which companies offer salaries above the industry average for the same job_title 
-- to identify market leaders in compensation.
WITH industry_avg AS (
    SELECT 
        industry,
        job_title,
        ROUND(AVG((salary_min_usd + salary_max_usd) / 2), 2) AS avg_salary
    FROM market_data
    GROUP BY industry, job_title
)
SELECT 
    cd.company_name,
    md.industry,
    md.job_title,
    ROUND(((md.salary_min_usd + md.salary_max_usd) / 2), 2) AS company_salary,
    ia.avg_salary AS industry_avg_salary
FROM market_data md
JOIN company_details cd ON cd.job_id = md.job_id
JOIN industry_avg ia 
    ON ia.industry = md.industry
   AND ia.job_title = md.job_title
WHERE (md.salary_min_usd + md.salary_max_usd) / 2 > ia.avg_salary
ORDER BY industry_avg_salary DESC;



-- Show which industries have the widest salary gap (salary_max_usd – salary_min_usd) to 
-- highlight roles with the highest compensation volatility.
SELECT
	industry,
    ROUND(AVG(salary_max_usd - salary_min_usd), 0) AS Compensation_Volatility
FROM market_data
GROUP BY industry
ORDER BY Compensation_Volatility DESC;























