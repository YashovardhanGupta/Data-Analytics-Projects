-- create table
-- DROP TABLE IF EXISTS spotify;
-- CREATE TABLE spotify (
--     artist VARCHAR(255),
--     track VARCHAR(255),
--     album VARCHAR(255),
--     album_type VARCHAR(50),
--     danceability FLOAT,
--     energy FLOAT,
--     loudness FLOAT,
--     speechiness FLOAT,
--     acousticness FLOAT,
--     instrumentalness FLOAT,
--     liveness FLOAT,
--     valence FLOAT,
--     tempo FLOAT,
--     duration_min FLOAT,
--     title VARCHAR(255),
--     channel VARCHAR(255),
--     views FLOAT,
--     likes BIGINT,
--     comments BIGINT,
--     licensed BOOLEAN,
--     official_video BOOLEAN,
--     stream BIGINT,
--     energy_liveness FLOAT,
--     most_played_on VARCHAR(50)
-- );

-- EDA
SELECT COUNT(*) FROM spotify;

SELECT COUNT(DISTINCT artist) FROM spotify;

SELECT COUNT(DISTINCT album) FROM spotify;

SELECT DISTINCT album_type FROM spotify;

SELECT MAX(duration_min) FROM spotify;

SELECT * FROM spotify
WHERE duration_min = 0;

DELETE FROM spotify
WHERE duration_min = 0;

SELECT COUNT (DISTINCT channel) FROM spotify;

SELECT DISTINCT channel FROM spotify;

SELECT DISTINCT most_played_on FROM spotify;

-- ----------------------------------------------
-- Data Analysis - some easy business questions
-- ----------------------------------------------

-- Retrieve the names of all tracks that have more than 1 billion streams.
-- List all albums along with their respective artists.
-- Get the total number of comments for tracks where licensed
-- Find all tracks that belong to the album type single.
-- Count the total number of tracks by each artist.


-- Retrieve the names of all tracks that have more than 1 billion streams.
SELECT track 
FROM spotify
WHERE stream > 1000000000;


-- List all albums along with their respective artists.
SELECT 
	DISTINCT album, artist
FROM spotify
ORDER BY 1;


SELECT 
	DISTINCT album
FROM spotify
ORDER BY 1;

-- Get the total number of comments for tracks where licensed
SELECT track,sum(comments)
FROM spotify
WHERE licensed= true
GROUP BY 1;


-- Find all tracks that belong to the album type single.
SELECT track
FROM spotify
WHERE album_type = 'single';

-- Count the total number of tracks by each artist.
select artist, count(track) as total_tracks
FROM spotify
group by artist
order by total_tracks desc;

-- ----------------------------------------------
-- Data Analysis - Medium Business Questions
-- ----------------------------------------------

-- Calculate the average danceability of tracks in each album.
-- Find the top 5 tracks with the highest energy values.
-- List all tracks along with their views and likes where official_video = TRUE.
-- For each album, calculate the total views of all associated tracks.
-- Retrieve the the track names that have been streamed on Spotify more than YouTube.


-- Calculate the average danceability of tracks in each album.
SELECT album, AVG(danceability) as Average_Danceability
FROM spotify
GROUP BY 1
ORDER BY 2 desc;

-- Find the top 5 tracks with the highest energy values.
SELECT track, artist, energy_liveness
FROM spotify
ORDER BY energy_liveness DESC
LIMIT 5;

-- List all tracks along with their views and likes where official_video = TRUE.
SELECT track, views, likes
FROM spotify
WHERE official_video = true;

-- For each album, calculate the total views of all associated tracks.
SELECT 
	album, 
	track,
	sum(views) as total_views
FROM spotify
GROUP BY 1, 2;

-- Retrieve the the track names that have been streamed on Spotify more than YouTube.
SELECT * FROM
(SELECT 
	track,
	COALESCE (SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) as streamed_on_youtube,
	COALESCE (SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0) as streamed_on_spotify
FROM spotify
GROUP BY 1) as t1
WHERE streamed_on_youtube > streamed_on_spotify
AND streamed_on_youtube <> 0
ORDER BY streamed_on_youtube desc;



-- ---------------------------------------------
-- Data Analysis: Advanced Business Questions
-- --------------------------------------------- 

-- Find the top 3 most-viewed tracks for each artist using window function
-- Write a query to find tracks where the liveness score is above the average
-- Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each 
-- Find tracks where the energy-to-liveness ratios is greater than 1.2.
-- Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions




-- Find the top 3 most-viewed tracks for each artist using window function
WITH ranking_artist
AS
(SELECT
	artist,
	track,
	SUM(views) as total_views,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) desc) as rank
FROM spotify
GROUP BY 1,2
ORDER BY 1,3 desc)
SELECT * FROM ranking_artist
WHERE rank <= 3;


-- Write a query to find tracks where the liveness score is above the average

SELECT 
	track,
	artist,
	liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify);



-- Use a WITH clause to calculate the difference between 
-- the highest and lowest energy values for tracks in each album 

WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energy
FROM spotify
GROUP BY 1)
SELECT 
	album,
	highest_energy - lowest_energy as energy_difference
FROM cte
ORDER BY 2 desc;




