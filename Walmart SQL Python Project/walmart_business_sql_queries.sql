---------------------------------
-- Beginner Questions 
---------------------------------


-- What is the total revenue generated?

SELECT SUM(total) AS Total_Revenue
FROM walmart;

-- How many transactions were madde in each city?

SELECT "City", count(*) 
FROM walmart
GROUP BY 1;

-- What is the average rating across all transactions?

SELECT AVG(rating) as Average_Ratings
FROM walmart;

-- Which paymant methods are used and how many times each?

SELECT payment_method, COUNT(*) 
FROM walmart
GROUP BY 1;

-- What are the top 5 most sold categories by quantity?

SELECT category, SUM(quantity) as Quantity_Sold
FROM walmart
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


---------------------------------
-- Intermediate Questions
---------------------------------

-- Which branch generates the highest total revenue?

SELECT "Branch", SUM(total) as Total_revenue
FROM walmart
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- What is the average profit margin for each cateogry?

SELECT category, AVG(profit_margin)
FROM walmart
GROUP BY 1
ORDER BY 2 DESC;

-- Which city has the highest average transaction value?

SELECT "City", AVG(total)
FROM walmart
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- Find the top 3 days with highest sales (revenue)

------------------------------------------------
ALTER TABLE walmart ADD COLUMN date_new date;
UPDATE walmart
SET date_new = TO_DATE("date", 'DD/MM/YY')
WHERE "date" IS NOT NULL AND "date" <> '';
------------------------------------------------

SELECT "date" from walmart;
SELECT "date_new" from walmart;

SELECT "date_new", SUM(total)
FROM walmart
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- Which payment metod gives the higest average transaction value?

SELECT payment_method, AVG(total)
FROM walmart
GROUP BY 1
ORDER BY 2
LIMIT 1;


---------------------------------
-- Advanced Questions
---------------------------------

-- What is the correlation between rating and profit margin?

SELECT CORR(rating, profit_margin) FROM walmart;

-- Find the top-performing category in each city (by revenue).

WITH category_sales AS (     
    SELECT 
        category,
        "City",
        SUM(total) AS revenue
    FROM walmart
    GROUP BY category, "City"
),
ranked AS (         
    SELECT *,
        RANK() OVER (PARTITION BY "City" ORDER BY revenue DESC) AS rnk
    FROM category_sales
)
SELECT 
    category,
    "City",
    revenue
FROM ranked
WHERE rnk = 1;

-- Identify peak sales hours of the day/
--
select COUNT(time), COUNT(time_new) from walmart;
select count(time) from walmart where time is null;
select count(time_new) from walmart;
ALTER TABLE walmart ADD COLUMN time_new time;
UPDATE walmart
SET time_new = trim("time")::time
WHERE "time" IS NOT NULL
AND trim("time") <> ''
AND trim("time") ~ '^\d{1,2}:\d{2}:\d{2}$';
--

SELECT 
    date_part('hour', time_new) AS hour_of_day,
    SUM(total) AS total_sales
FROM walmart
GROUP BY hour_of_day
ORDER BY total_sales DESC;
	
-- Calculate daily revenue growth (day-over-day % change)

WITH daily_sales AS (
    SELECT 
        date,
        SUM(total) AS daily_revenue
    FROM walmart
    GROUP BY date
),
with_lag AS (
    SELECT *,
        LAG(daily_revenue) OVER (ORDER BY date) AS prev_day_revenue
    FROM daily_sales
)
SELECT 
    date,
    daily_revenue,
    prev_day_revenue,
    
    ROUND(
        (
            (daily_revenue - prev_day_revenue) 
            / prev_day_revenue * 100
        )::NUMERIC,
        2
    ) AS growth_percent

FROM with_lag;

-- Segment transactions into High, Medium, Low value based on total and count them

SELECT 
    CASE 
        WHEN total < 100 THEN 'Low'
        WHEN total BETWEEN 100 AND 500 THEN 'Medium'
        ELSE 'High'
    END AS transaction_segment,
    
    COUNT(*) AS transaction_count

FROM walmart
GROUP BY transaction_segment
ORDER BY transaction_count DESC;

--
select * from walmart limit 2;