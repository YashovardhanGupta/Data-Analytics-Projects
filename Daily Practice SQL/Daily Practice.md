# 17 Apr 2026
## Input 1

| team_1 | team_2 | winner |
| ----- | ----- | ----- |
| India | SL | India |
| SL | Aus | Aus |
| SA | Eng | Eng |
| Eng | NZ | NZ |
| Aus | India | India |


## Question 1: 

Find out matches played, won and lost from the above data

## Queries:

Way 1: 

```SQL
SELECT 
	team_name, 
	count(1) AS no_of_games_played, 
	SUM(win_flag) AS no_of_wins, 
	COUNT(1) - SUM(win_flag) AS no_of_losses
FROM 
	(SELECT team_1 as team_name,
	CASE WHEN
		team_1 = winner
		THEN 
			1
		ELSE
			0
		END AS win_flag
	FROM icc_world_cup
	UNION ALL 
	SELECT team_2 as team_name,
	CASE WHEN
		team_2 = winner
		THEN 
			1
		ELSE
			0
		END AS win_flag
	FROM icc_world_cup) A
GROUP BY team_name
ORDER BY no_of_wins DESC;
```
Way 2: 

```SQL
WITH cte AS
(SELECT team_1,winner FROM icc_world_cup
UNION ALL
SELECT team_2,winner FROM icc_world_cup
) 
SELECT 
	team_1,
	COUNT(*) no_of_matches_played,
	SUM( CASE WHEN team_1 = winner
		THEN 1
		ELSE 0
		END) AS no_of_wins,
	SUM( CASE WHEN team_1 <> winner
		THEN 1
		ELSE 0
		END) as no_of_losses
FROM cte
GROUP BY team_1
ORDER BY no_of_wins DESC;
```
## Output 1

| team_1 | no_of_matches_played | no_of_wins | no_of_losses |
| ------- | ------- | ------- | ------- |
| India | 2 | 2 | 0 |
| Eng | 2 | 1 | 1 |
| NZ | 1 | 1 | 0 |
| Aus | 2 | 1 | 1 |
| SA | 1 | 0 | 1 |
| SL | 2 | 0 | 2 |

## Input 2:

| order_id | customer_id | order_date | order_amount |
| --------- | --------- | --------- | --------- |
| 1 | 100 | 2022-01-01 | 2000 |
| 2 | 200 | 2022-01-01 | 2500 |
| 3 | 300 |2022-01-01 | 2100 |
| 4 | 100 | 2022-01-02 | 2000 |
| 5 | 400 | 2022-01-02 | 2200 |
| 6 | 500 | 2022-01-02 | 2700 |
| 7 | 100 | 2022-01-03 | 3000 |
| 8 | 400 | 2022-01-03 | 1000 |
| 9 | 600 | 2022-01-03 | 3000 |

## Question 2: 

Find out new and repeating customers

## Queries: 

way 1: 

```SQL
WITH first_visit AS
(SELECT 
	customer_id, 
	MIN(order_date) AS first_visit_date
FROM customer_orders co
GROUP BY customer_id),
visit_flag AS
(SELECT 
	co.*,
	fv.first_visit_date,
	CASE WHEN co.order_date = fv.first_visit_date
		THEN 1
		ELSE 0
		END AS first_visit_flag,
	CASE WHEN co.order_date <> fv.first_visit_date
		THEN 1
		ELSE 0
		END AS repeat_visit_flag
FROM customer_orders co
INNER JOIN first_visit fv
ON co.customer_id = fv.customer_id
ORDER BY order_id)
SELECT order_date, SUM(first_visit_flag) AS no_of_new_customers, SUM(repeat_visit_flag) AS no_of_repeat_customer
FROM visit_flag
GROUP BY order_date;
```

Alternate Way:

```sql
WITH first_visit AS
(SELECT 
	customer_id, 
	MIN(order_date) AS first_visit_date
FROM customer_orders co
GROUP BY customer_id)
SELECT 
	co.order_date,
	SUM(CASE WHEN co.order_date = fv.first_visit_date
		THEN 1
		ELSE 0
		END) AS first_visit_flag,
	SUM(CASE WHEN co.order_date <> fv.first_visit_date
		THEN 1
		ELSE 0
		END) AS repeat_visit_flag
FROM customer_orders co
INNER JOIN first_visit fv
ON co.customer_id = fv.customer_id
GROUP BY order_date;
```

Alternate Way: 

```sql
SELECT
	a.order_date,
	SUM(CASE WHEN a.order_date = a.first_order_date 
		THEN 1
		ELSE 0
		END) AS no_of_new_customers,
	SUM(CASE WHEN a.order_date != a.first_order_date
		THEN 1 
		ELSE 0 
		END) as no_of_repeat_customers
FROM
(SELECT
	customer_id,
	order_date,
	MIN(order_date) OVER(PARTITION BY customer_id) AS first_order_date
FROM customer_orders) a 
GROUP BY a.order_date;
```

## Output 2:

| Order_date | no_of_new_customers | no_of_repeat_customer |
| ------------ | ------------ | ------------ |
| 2022-01-01 | 3 | 0 |
| 2022-01-02 | 2 | 2 |
| 2022-01-03 | 1 | 2 |

# 18 Apr 2026
## Input 1

|   | Name | Address | Email | Floor | Resources |
|---| --- | --- | --- | --- | --- |
| 1 | A | Banglore | A@gmail.com | 1 | CPU |
| 2 | A | Banglore | A1@gmail.com | 1 | CPU |
| 3 | A | Banglore | A2@gmail.com | 2 | DESKTOP |
| 4 | B | Banglore | B@gmail.com | 2 | DESKTOP |
| 5 | B | Banglore | B1@gmail.com | 2 | DESKTOP |
| 6 | B | Banglore | B2@gmail.com | 1 | MONITOR |

## Question 1:

In an office, an employee is allowed to enter a floor **only once** and to ensure this system, the employee is supposed to enter their unique email. But there was a loophole found where the employee can feed **more than one unique email id**. You are tasked to find out **total visits** and the **most visited floor** of the employees and **what resources they used**.

## Query:

```sql
WITH cte AS (
    SELECT
        name,
        floor,
        COUNT(*) AS no_of_floor_visits,
        RANK() OVER(PARTITION BY name ORDER BY COUNT(*) DESC) AS rn
    FROM entries
    GROUP BY name, floor
),
total_visits_cte AS (
    SELECT
        name,
        SUM(no_of_floor_visits) AS total_visits
    FROM cte
    GROUP BY name
),
resources_cte AS (
    SELECT
        name,
        STRING_AGG(DISTINCT resources, ', ') AS resources_used
    FROM entries
    GROUP BY name
)

SELECT
    c.name,
    t.total_visits,
    c.floor AS most_visited_floor,
    r.resources_used
FROM cte c
JOIN total_visits_cte t
    ON c.name = t.name
JOIN resources_cte r
    ON c.name = r.name
WHERE c.rn = 1
ORDER BY t.total_visits DESC;
```

## Output 1:

|    | name | total_visits | most_visited_floor | resources_used |
| -- | --- | --- | --- | --- |
|  1 | A | 3 | 1 | CPU, DESKTOP |
|  2 | B | 3 | 2 | DESKTOP, MONITOR |

