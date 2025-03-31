-- Selecting all data from the layoffs_staging2 table
SELECT * 
FROM layoffs_staging2;

-- Getting the maximum number of total layoffs and the maximum percentage of layoffs
SELECT max(total_laid_off), max(percentage_laid_off)
FROM layoffs_staging2;

-- Fetching records where the entire workforce was laid off (percentage_laid_off = 1),
-- sorted by the total number of layoffs in descending order
SELECT * 
FROM layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off desc;

-- Fetching records where the entire workforce was laid off (percentage_laid_off = 1),
-- sorted by funds raised in descending order
SELECT * 
FROM layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;

-- Summing the total layoffs per company and ordering by the highest layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Finding the earliest and latest recorded layoff dates
select min(`date`), max(`date`)
FROM layoffs_staging2;

-- Summing total layoffs per industry and ordering by highest layoffs
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Summing total layoffs per country and ordering by highest layoffs
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Summing total layoffs per year and ordering by year in descending order
SELECT year(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY year(`date`)
ORDER BY 1 DESC;

-- Summing total layoffs per company stage and ordering by highest layoffs
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Summing total percentage of layoffs per company and ordering by highest percentage
SELECT company, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Calculating the average percentage of layoffs per company and ordering by highest percentage
SELECT company, avg(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Aggregating total layoffs per month, ignoring null values, and ordering by month
SELECT SUBSTRING(`date`,1,7) as `Month`, sum(total_laid_off)
from layoffs_staging2
where SUBSTRING(`date`,1,7) is not null
group by `Month`
order by 1 asc;

-- Creating a rolling total of layoffs per month
WITH Rolling_Total AS
(
    -- Aggregating total layoffs per month
    SELECT SUBSTRING(`date`,1,7) as `Month`, sum(total_laid_off) as total_off
    from layoffs_staging2
    where SUBSTRING(`date`,1,7) is not null
    group by `Month`
    order by 1 asc
)
-- Computing cumulative layoffs over time
SELECT `Month`, total_off, sum(total_off) over(order by `Month`) as rolling_total
FROM Rolling_Total;

-- Aggregating layoffs per company per year, ordering by company name
SELECT company, year(`date`), sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company, `date`
ORDER BY company asc;

-- Aggregating layoffs per company per year, ordering by highest layoffs
SELECT company, year(`date`), sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company, `date`
ORDER BY 3 desc;

-- Finding top 5 companies with the highest layoffs per year using a ranking method
WITH Company_Year (company, years, total_laid_off) AS
(
    -- Aggregating layoffs per company per year
    SELECT company, year(`date`), sum(total_laid_off)
    FROM layoffs_staging2
    GROUP BY company, `date`
), Company_Year_Rank AS
(
    -- Assigning ranks based on layoffs per year
    SELECT *, dense_rank() OVER(PARTITION BY years ORDER BY total_laid_off DESC) as Ranking
    FROM Company_Year
    WHERE years is not null
)
-- Selecting the top 5 companies per year
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;

-- Identifying the month with the highest number of layoffs
SELECT SUBSTRING(`date`,1,7) as `Month`, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY `Month`
ORDER BY total_laid_off DESC
LIMIT 1;

-- Find the top company in each industry with the highest layoffs
WITH Industry_Max AS (
    SELECT industry, company, SUM(total_laid_off) AS total_laid_off,
           RANK() OVER (PARTITION BY industry ORDER BY SUM(total_laid_off) DESC) AS rnk
    FROM layoffs_staging2
    GROUP BY industry, company
)
SELECT industry, company, total_laid_off
FROM Industry_Max
WHERE rnk = 1;

-- Checking if companies with higher funds raised had more layoffs
SELECT CASE 
           WHEN funds_raised_millions < 50 THEN 'Low Funding (<$50M)'
           WHEN funds_raised_millions BETWEEN 50 AND 200 THEN 'Medium Funding ($50M-$200M)'
           ELSE 'High Funding (>$200M)'
       END AS funding_category,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY funding_category
ORDER BY total_laid_off DESC;

-- Finding the average percentage of layoffs per year to track if layoff severity increased
SELECT year(`date`), AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging2
GROUP BY year(`date`)
ORDER BY year(`date`) ASC;

-- Identifying companies that had multiple rounds of layoffs
SELECT company, COUNT(DISTINCT year(`date`)) AS layoff_years, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company
HAVING layoff_years > 1
ORDER BY total_laid_off DESC;


