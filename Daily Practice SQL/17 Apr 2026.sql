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



