

-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);
-- -------------------------------
-- Data Analysis -Easy Category
-- -------------------------------

-- Retrieve the names of all tracks that have more than 1 billion streams.
SELECT * FROM spotify
WHERE stream > 1000000000;

-- List all albums along with their respective artists.

SELECT
	DISTINCT album, artist
FROM spotify
ORDER BY 1;

-- Get the total number of comments for tracks where licensed = TRUE.

SELECT SUM(comments) as total_comments 
FROM spotify
where Licensed = 'TRUE';

-- Find all tracks that belong to the album type single.
SELECT track
from spotify
where album_type ILIKE 'single';

-- Count the total number of tracks by each artist.
SELECT artist, 
		COUNT(*) as total_num_track
from spotify
GROUP BY artist
ORDER BY 2

-- -------------------------------
-- Data Analysis -Meduim Category
-- -------------------------------

-- Find the total number of tracks that have more likes than views.
SELECT COUNT(*)
FROM spotify
WHERE likes > views;

-- Calculate the average duration of tracks for each artist.
SELECT artist, 
       AVG(duration_min) AS avg_duration
FROM spotify
GROUP BY artist
ORDER BY avg_duration DESC;

-- Retrieve the top 10 albums with the most tracks.
SELECT album, 
       COUNT(track) AS num_tracks
FROM spotify
GROUP BY album
ORDER BY num_tracks DESC
LIMIT 10;

-- List all tracks where the danceability score is above the average danceability of all tracks.
SELECT track, artist, danceability
FROM spotify
WHERE danceability > (SELECT AVG(danceability) FROM spotify)
ORDER BY danceability DESC;

--  Find all artists who have more than 10 tracks in the dataset.
SELECT artist, 
       COUNT(track) AS track_count
FROM spotify
GROUP BY artist
HAVING COUNT(track) > 10
ORDER BY track_count DESC;

-- Calculate the total number of streams per album where licensed = TRUE.
SELECT album, 
       SUM(stream) AS total_streams
FROM spotify
WHERE licensed = TRUE
GROUP BY album
ORDER BY total_streams DESC;

-- Find the average loudness of tracks for each album type (e.g., single, album).
SELECT album_type, 
       AVG(loudness) AS avg_loudness
FROM spotify
GROUP BY album_type
ORDER BY avg_loudness DESC;

-- List the top 5 artists with the highest total number of views.
SELECT artist, 
       SUM(views) AS total_views
FROM spotify
GROUP BY artist
ORDER BY total_views DESC
LIMIT 5;

--Retrieve the names of tracks that have both high energy (above 0.8) and high danceability (above 0.8).
SELECT track, artist, energy, danceability
FROM spotify
WHERE energy > 0.8 AND danceability > 0.8
ORDER BY energy DESC, danceability DESC;

-- List the tracks where the duration is longer than the average duration of tracks in their respective album.
SELECT track, album, duration_min
FROM spotify s
WHERE duration_min > (SELECT AVG(duration_min) 
                      FROM spotify 
                      WHERE album = s.album)
ORDER BY duration_min DESC;


-- Calculate the average danceability of tracks in each album.
SELECT album, 
		AVG(danceability) as AVG_danceaility
FROM spotify
GROUP BY 1
ORDER BY 2 DESC

-- Find the top 5 tracks with the highest energy values.
SELECT 
	track,
	MAX(Energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- List all tracks along with their views and likes where official_video = TRUE.

SELECT track, 
		SUM(views) as total_views, 
		SUM(likes) as total_likes 
FROM spotify
where official_video = 'TRUE'
GROUP BY track
ORDER BY 2 DESC

-- For each album, calculate the total views of all associated tracks.

SELECT album, track, sum(views) as count
FROM spotify
GROUP BY 1,2
HAVING SUM(views) > 1
ORDER BY 3 DESC

-- Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * FROM
(SELECT track, 
COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END),0) AS STREAMED_ON_YOUTUBE,
COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END),0)AS STREAMED_ON_SPOTIFY
FROM spotify
GROUP BY 1
) as T1
WHERE STREAMED_ON_SPOTIFY > STREAMED_ON_YOUTUBE
		AND
		STREAMED_ON_YOUTUBE <> 0


-- ----------------------
-- Advance Problems
-- ----------------------

-- Find the top 3 most-viewed tracks for each artist using window functions.

WITH ranking_artist
AS
(SELECT
	artist,
	track,
	SUM(views) as total_views,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS rank

FROM spotify
GROUP BY 1, 2
ORDER BY 1, 3 DESC
)
SELECT * FROM ranking_artist
WHERE rank <= 3

-- Write a query to find tracks where the liveness score is above the average.
SELECT
	track,
	artist,
	liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify)

-- Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM cte
ORDER BY 2 DESC




