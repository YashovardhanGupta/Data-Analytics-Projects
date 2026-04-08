DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(250),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);


SELECT * FROM netflix LIMIT 2;

SELECT COUNT(*) as Total_Content
FROM netflix;

SELECT DISTINCT type FROM netflix;


-- Business Questions --

/*
1. Count the number of movies vs tv shows
2. find the most common rating for movies and tv shows
3. list all movies released in a specific year (eg: 2020)
4. Find the top 5 countries with the most content on Netflix
5. Identify the longest movie or tv show duration
6. Find content added in the last 5 years
7. Find all the TV shows/Movies by director 'Rajiv Chilaka'
8. List all tv shows with more than 5 seasons
9. Count the number of content items in each genre
10. Find each year and the average numbers of content release in India on Netflix ; Return top 5 year with highest avg content release;
11. List all movies tgat are documentaries 
12. Find all content without a director
*/

-- Question 1

SELECT type, COUNT(*)
FROM netflix
GROUP BY 1;

-- Question 2

-------------------------------------
SELECT DISTINCT rating FROM netflix;
-------------------------------------
SELECT
	type,
	rating,
	ranking
FROM
	(SELECT 
		type,
		rating,
		COUNT(*),
		RANK() OVER (PARTITION BY type ORDER BY COUNT (*) DESC) as ranking
	FROM netflix
	GROUP BY 1, 2) as t1
WHERE ranking = 1;

-- Question 3

SELECT * FROM netflix WHERE type = 'Movie' AND release_year = 2020;

-- Question 4

SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as Top_5_Countries,
	COUNT(*)
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Question 5

SELECT * FROM netflix
WHERE type = 'Movie'
AND duration = (SELECT MAX(duration) FROM netflix);

-- Question 6

SELECT *,
       TO_DATE(date_added, 'Month DD, YYYY') AS added_date
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') 
      >= TO_DATE('September 07, 2024', 'Month DD, YYYY') - INTERVAL '5 years';

-- Question 7

SELECT * FROM netflix WHERE director LIKE '%Rajiv Chilaka%';

SELECT
	title,
	type
FROM 
	(SELECT
		title,
		type,
		UNNEST(STRING_TO_ARRAY(director, ',')) as new_director
	FROM netflix
	GROUP BY 1,2,3) as t1
WHERE new_director = 'Rajiv Chilaka';

-- Question 8

SELECT 
	*
FROM netflix
WHERE type = 'TV Show'
AND SPLIT_PART(duration, ' ', 1)::numeric > 5;

-- Question 9

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
	COUNT(show_id)
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;

-- Question 10

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	COUNT (*),
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country LIKE '%India%')::numeric * 100
	,2) as avg_content_per_year
FROM netflix
WHERE country LIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC;

-- Question 11

SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries%';

-- Question 12

SELECT * FROM netflix
WHERE director IS NULL;






