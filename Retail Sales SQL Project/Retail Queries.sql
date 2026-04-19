DROP TABLE IF EXISTS retail;
CREATE TABLE retail (
	transactions_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender VARCHAR(15),
	age INT,
	category VARCHAR(20),
	quantiy INT,
	price_per_unit FLOAT,
	cogs FLOAT,	
	total_sale FLOAT 
);


ALTER TABLE retail
RENAME COLUMN quantiy TO quantity;
SELECT * FROM retail LIMIT 5;

/*
Data Exploration & Cleaning:
-- Record Count: Determine the total number of records in the dataset.
-- Customer Count: Find out how many unique customers are in the dataset.
-- Category Count: Identify all unique product categories in the dataset.
-- Null Value Check: Check for any null values in the dataset and delete records with missing data.
*/

SELECT COUNT(*) FROM retail;

SELECT COUNT(DISTINCT customer_id) FROM retail;

SELECT DISTINCT category FROM retail;

SELECT * FROM retail
WHERE 
	sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR gender IS NULL OR
	age IS NULL OR category IS NULL OR quantity IS NULL OR price_per_unit IS NULL OR
	cogs IS NULL OR total_sale IS NULL;

DELETE FROM retail
WHERE 
	sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR gender IS NULL OR
	age IS NULL OR category IS NULL OR quantity IS NULL OR price_per_unit IS NULL OR
	cogs IS NULL OR total_sale IS NULL;


SELECT * FROM retail LIMIT 5;

/*
Data Analysis & Findings:
1. Write a SQL query to retrieve all columns for sales made on '2022-11-05:
2. Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022:
3. Write a SQL query to calculate the total sales (total_sale) for each category.:
4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:
5. Write a SQL query to find all transactions where the total_sale is greater than 1000.:
6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:
7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:
8. Write a SQL query to find the top 5 customers based on the highest total sales :
9. Write a SQL query to find the number of unique customers who purchased items from each category.:
10. Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
*/

-- 1

SELECT * 
FROM retail
WHERE sale_date = '2022-11-05';

-- 2 

SELECT *
FROM retail
WHERE category = 'Clothing'
AND quantity >= 4
AND EXTRACT(MONTH FROM sale_date) = 11;

-- 3 

SELECT category, SUM(total_sale) AS Total_sales
FROM retail
GROUP BY category
ORDER BY Total_sales DESC;

-- 4

SELECT gender, AVG(age)::integer AS Average_age
FROM retail
WHERE category = 'Beauty'
GROUP BY 1;

-- 5

SELECT * 
FROM retail 
WHERE total_sale > 1000;

-- 6

SELECT 
	COUNT(transactions_id) AS total_transactions,  
	gender,
	category
FROM retail
GROUP BY gender, category
ORDER BY category;

-- 7

SELECT TO_CHAR(sale_date, 'Month') AS month_name, AVG(total_sale) as Average_sales
FROM retail
GROUP BY 1
ORDER BY 2 DESC;

-- 8

SELECT customer_id, SUM(total_sale) AS total_sales
FROM retail
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 9

SELECT 
	category,
	COUNT(DISTINCT customer_id) AS cnt_unique_cs
FROM retail
GROUP BY category;

-- 10

WITH shifts AS
(
	SELECT *,
		CASE WHEN EXTRACT(HOUR FROM sale_time) < 12
			THEN 'Morning'
			WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 
			THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift
	FROM retail
)
SELECT 
	shift,
	COUNT(*) AS total_orders
FROM shifts
GROUP BY shift;

SELECT * FROM retail LIMIT 5;