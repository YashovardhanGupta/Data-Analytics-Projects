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
-----------------------------------------------------------------------------------------------
/*
In an office, an employee is allowed to enter a floor only once and to ensure this system,
the employee is supposed to enter their unique email.
But there was a loophole found where the employee can feed **more than one unique email id**.
You are tasked to find out **total visits** and the **most visited floor** of the employees
and **what resources they used**.
*/
-----------------------------------------------------------------------------------------------

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


---------------------------------------------
drop table friend 
Create table friend (pid int, fid int)
insert into friend (pid , fid ) values ('1','2');
insert into friend (pid , fid ) values ('1','3');
insert into friend (pid , fid ) values ('2','1');
insert into friend (pid , fid ) values ('2','3');
insert into friend (pid , fid ) values ('3','5');
insert into friend (pid , fid ) values ('4','2');
insert into friend (pid , fid ) values ('4','3');
insert into friend (pid , fid ) values ('4','5');
drop table person
create table person (pid int,	Name varchar(50),	Score int)
insert into person(pid,Name ,Score) values('1','Alice','88')
insert into person(pid,Name ,Score) values('2','Bob','11')
insert into person(pid,Name ,Score) values('3','Devis','27')
insert into person(pid,Name ,Score) values('4','Tara','45')
insert into person(pid,Name ,Score) values('5','John','63')
select * from person
select * from friend


/*write a query to find PersonID, Name, number of friends, sum of marks
of person who have friends with total score greater than 100. */

-- pId, Name, number_of_friends, sum_of_marks 


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

------------------------------------------
---------------
-- 19 Apr 2026
---------------




Create table  Trips (id int, client_id int, driver_id int, city_id int, status varchar(50), request_at varchar(50));
Create table Users (users_id int, banned varchar(50), role varchar(50));
Truncate table Trips;
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('1', '1', '10', '1', 'completed', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('2', '2', '11', '1', 'cancelled_by_driver', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('3', '3', '12', '6', 'completed', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('4', '4', '13', '6', 'cancelled_by_client', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('5', '1', '10', '1', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('6', '2', '11', '6', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('7', '3', '12', '6', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('8', '2', '12', '12', 'completed', '2013-10-03');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('9', '3', '10', '12', 'completed', '2013-10-03');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('10', '4', '13', '12', 'cancelled_by_driver', '2013-10-03');
Truncate table Users;
insert into Users (users_id, banned, role) values ('1', 'No', 'client');
insert into Users (users_id, banned, role) values ('2', 'Yes', 'client');
insert into Users (users_id, banned, role) values ('3', 'No', 'client');
insert into Users (users_id, banned, role) values ('4', 'No', 'client');
insert into Users (users_id, banned, role) values ('10', 'No', 'driver');
insert into Users (users_id, banned, role) values ('11', 'No', 'driver');
insert into Users (users_id, banned, role) values ('12', 'No', 'driver');
insert into Users (users_id, banned, role) values ('13', 'No', 'driver');
select * from Users;
select * from Trips;

/*
Write a SQL query to find the cancellation rate of requests with unbanned users
(both client and driver must not be banned) each day between "2013-10-01" and "2013-10-03".
Round Cancellation Rate to two decimal points.

The cancellation rate is computed by dividing the number of canceled (by client or driver)
requests with unbanned users by the total number of requests with unbanned users on that day.
*/

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


------------------------------------------------

create table players
(player_id int,
group_id int)

insert into players values (15,1);
insert into players values (25,1);
insert into players values (30,1);
insert into players values (45,1);
insert into players values (10,2);
insert into players values (35,2);
insert into players values (50,2);
insert into players values (20,3);
insert into players values (40,3);
select * from players
create table matches
(
match_id int,
first_player int,
second_player int,
first_score int,
second_score int)

insert into matches values (1,15,45,3,0);
insert into matches values (2,30,25,1,2);
insert into matches values (3,30,15,2,0);
insert into matches values (4,40,20,5,2);
insert into matches values (5,35,50,1,1);
select * from matches;

/*
Write an SQL Query to find the winner in each group
The winner in each group is the player who scoerd the maximum total points withing the group. 
In the case of a tie, the lowest player_id wins.
*/


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

	
	

