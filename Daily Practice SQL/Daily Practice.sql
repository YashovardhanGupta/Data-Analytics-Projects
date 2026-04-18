-- 17 Apr 2026
-------------------------------------------------
-- This data/query is about finding no of wins, losses and total matches played
-------------------------------------------------
create table icc_world_cup
(
Team_1 Varchar(20),
Team_2 Varchar(20),
Winner Varchar(20)
);
INSERT INTO icc_world_cup values('India','SL','India');
INSERT INTO icc_world_cup values('SL','Aus','Aus');
INSERT INTO icc_world_cup values('SA','Eng','Eng');
INSERT INTO icc_world_cup values('Eng','NZ','NZ');
INSERT INTO icc_world_cup values('Aus','India','India');

select * from icc_world_cup;


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

-------------------
-- Alternative way
-------------------
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

----------------------------------------------------
-- This data/query is about finding new and repeat customers
----------------------------------------------------

create table customer_orders (
order_id integer,
customer_id integer,
order_date date,
order_amount integer
);
select * from customer_orders
insert into customer_orders values(1,100,cast('2022-01-01' as date),2000),(2,200,cast('2022-01-01' as date),2500),(3,300,cast('2022-01-01' as date),2100)
,(4,100,cast('2022-01-02' as date),2000),(5,400,cast('2022-01-02' as date),2200),(6,500,cast('2022-01-02' as date),2700)
,(7,100,cast('2022-01-03' as date),3000),(8,400,cast('2022-01-03' as date),1000),(9,600,cast('2022-01-03' as date),3000)
;


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

-- Alternate Way:

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

-- Alternate Way:

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

----------------
-- 18 Apr 2026
----------------

create table entries ( 
name varchar(20),
address varchar(20),
email varchar(20),
floor int,
resources varchar(10));

insert into entries 
values ('A','Bangalore','A@gmail.com',1,'CPU'),('A','Bangalore','A1@gmail.com',1,'CPU'),('A','Bangalore','A2@gmail.com',2,'DESKTOP')
,('B','Bangalore','B@gmail.com',2,'DESKTOP'),('B','Bangalore','B1@gmail.com',2,'DESKTOP'),('B','Bangalore','B2@gmail.com',1,'MONITOR')

select * from entries;

-- name, total_visits, floor_most_visited, resources_used

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