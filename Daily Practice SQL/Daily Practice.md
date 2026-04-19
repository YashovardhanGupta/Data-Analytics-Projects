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


## Input 2:

<u> `Person` Table </u>

| Rank | Name | Score |
| --- | --- | --- |
| 1 | Alice | 88 |
| 2 | Bob | 11 |
| 3 | Devis | 27 |
| 4 | Tara | 45 |
| 5 | John | 63 |

<u> `Friend` Table </u>

| pid | fid |
| --- | --- |
| 1 | 2 |
| 1 | 3 |
| 2 | 1 |
| 2 | 3 |
| 3 | 5 |
| 4 | 2 |
| 4 | 3 |

## Question 2:

write a query to find PersonID, Name, number of friends, sum of marks of person who have friends with total score greater than 100.

## Query:
```sql
WITH score_details AS
(
	SELECT 
		f.pid,
		COUNT(1) AS no_of_friends,
		SUM(p.score) as total_friend_score
	FROM friend f
	JOIN person p
	ON f.fid=p.pid
	GROUP BY f.pid
	HAVING SUM(p.score) > 100
)
SELECT 
	s.*,
	p.name AS Name
FROM person p
JOIN score_details s
ON p.pid = s.pid;
```

## Output 2:

| pid | no_of_friends | total_friend_score | name |
| --- | --- | --- | --- |
| 2 | 2 | 115 | Bob |
| 4 | 3 | 101 | Tara |


# 19 Apr 2026
## Input 1:

<u>`User's` Table</u>

| users_id | banned | role |
| --- | --- | --- |
| 1 | No | client |
| 2 | Yes | client |
| 3 | No | client |
| 4 | No | client |
| 10 | No | driver |
| 11 | No | driver |
| 12 | No | driver |
| 13 | No | driver |

<u> `Trips` Table </u>

| id | client_id | driver_id | city_id | status | request_at |
| --- | --- | --- | --- | --- | --- |
| 1 | 1 | 10 | 1 | completed | 01-10-2013 |
| 2 | 2 | 11 | 1 | cancelled_by_driver | 01-10-2013 |
| 3 | 3 | 12 | 6 | completed | 01-10-2013 |
| 4 | 4 | 13 | 6 | cancelled_by_client | 01-10-2013 |
| 5 | 1 | 10 | 1 | completed | 02-10-2013 |
| 6 | 2 | 11 | 6 | completed | 02-10-2013 |
| 7 | 3 | 12 | 6 | completed | 02-10-2013 |
| 8 | 2 | 12 | 12 | completed | 03-10-2013 |
| 9 | 3 | 10 | 12 | completed | 03-10-2013 |
| 10 | 4 | 13 | 12 | cancelled_by_driver | 03-10-2013 |


## Question 1:
Write a SQL query to find the cancellation rate of requests with unbanned users (both client and driver must not be banned) each day between "2013-10-01" and "2013-10-03". Round Cancellation Rate to two decimal points.

The cancellation rate is computed by dividing the number of canceled (by client or driver) requests with unbanned users by the total number of requests with unbanned users on that day.

## Query:

```sql
SELECT 
	request_at,
	COUNT(CASE WHEN status IN ('cancelled_by_driver', 'cancelled_by_client') 
				THEN 1 
				ELSE null 
				END) AS trips_cancelled,
	count(1) AS total_trips,
	((COUNT(CASE WHEN status IN ('cancelled_by_driver', 'cancelled_by_client') 
					THEN 1 
					ELSE null 
					END)) * 100) / COUNT(request_at) AS cancellation_rate_in_percent
FROM trips t
JOIN users c
ON t.client_id = c.users_id
JOIN users d
ON t.driver_id = d.users_id
WHERE c.banned = 'No' AND d.banned = 'No'
GROUP BY request_at;
```

## Output 1:

| request_at | trips_cancelled | total_trips | cancellation_rate_in_percent |
| --- | --- | --- | --- |
| 01-10-2013 | 1 | 3 | 33 |
| 02-10-2013 | 0 | 2 | 0 |
| 03-10-2013 | 1 | 2 | 50 |


## Input 2:

<u> `Matches` Table </u>

| match_id | first_player | second_player | first_score | second_score |
| --- | --- | --- | --- | --- |
| 1 | 15 | 45 | 3 | 0 |
| 2 | 30 | 25 | 1 | 2 |
| 3 | 30 | 15 | 2 | 0 |
| 4 | 40 | 20 | 5 | 2 |
| 5 | 35 | 50 | 1 | 1 |


<u> `Players` Table </u>

| player_id | group_id |
| --- | --- |
| 15 | 1 |
| 25 | 1 |
| 30 | 1 |
| 45 | 1 |
| 10 | 2 |
| 35 | 2 |
| 50 | 2 |
| 20 | 3 |
| 40 | 3 |


## Question 2:
Write an SQL Query to find the winner in each group.

*The winner in each group is the player who scoerd the maximum total points withing the group. In the case of a tie, the lowest player_id wins.*

## Query:

```sql
WITH player_scores AS
(
	SELECT
		first_player AS player_id,
		first_score AS score
	FROM matches

	UNION ALL

	SELECT
		second_player AS player_id,
		second_score AS score
	FROM matches	
),
groups as
(
	SELECT 
		ps.player_id,
		SUM(ps.score) as Total_Score,
		p.group_id
	FROM player_scores ps
	JOIN players p
	ON ps.player_id = p.player_id
	GROUP BY ps.player_id, p.group_id
	ORDER BY Total_Score DESC
)
SELECT 
	player_id,
	group_id
FROM 
	(
		SELECT 
			player_id, 
			group_id,
			RANK() OVER (PARTITION BY group_id ORDER BY total_score DESC, player_id ASC) as rn
		FROM groups
	) t
WHERE rn = 1;
```

## Output 2:

| player_id | group_id |
|-----------|----------|
| 15       | 1        |
| 35       | 2        |
| 40       | 3        |

