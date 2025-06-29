SELECT * FROM credits;
SELECT * FROM titles_cleaned;

-- Analysis of Netflix_Tv_Shows_Movies_dataset --

--Content Distribution by Type--
SELECT type, COUNT(*) AS Total_titles
FROM titles_cleaned
Group by type
ORDER BY Total_titles DESC;


-- Top 10 Genres --
SELECT TOP 10 genres, COUNT(*) AS Total
FROM titles_cleaned
GROUP BY genres
ORDER BY Total DESC;


-- Top 10 Countries Producing Content--
SELECT TOP 10 production_countries, COUNT(*) AS Total
FROM titles_cleaned
GROUP BY production_countries
ORDER BY Total DESC;


--  Top-Rated Titles --
SELECT TOP 10 title, imdb_score
FROM titles_cleaned
WHERE imdb_score IS NOT NULL
ORDER BY imdb_score DESC;


-- Frequent Indian Actors/Directors --
SELECT name, COUNT(*) AS appearances
FROM credits
WHERE name LIKE '%India%'
GROUP BY name
ORDER BY appearances DESC;



-- Title Keyword Trend: "War", "Love", "Death"-- 
SELECT title, genres
FROM titles_cleaned
WHERE title LIKE '%war%' OR title LIKE '%love%' OR title LIKE '%death%';



-- IMDb Votes Trend Since 2020-- 
SELECT release_year, AVG(imdb_votes) AS avg_votes
FROM titles_cleaned
WHERE release_year >= 2020 AND imdb_votes IS NOT NULL
GROUP BY release_year
ORDER BY release_year;



-- Compare Score With/Without a Specific Director ---
SELECT
  CASE WHEN c.name = 'Christopher Nolan' THEN 'Nolan'
       ELSE 'Others'
  END AS group_type,
  AVG(T.imdb_score) AS avg_score
FROM titles_cleaned t
LEFT JOIN credits c ON t.id = c.id AND c.role = 'DIRECTOR'
WHERE t.imdb_score IS NOT NULL
GROUP BY CASE WHEN C.name = 'Christopher Nolan' THEN 'Nolan' ELSE 'Others' END;



-- Year-wise Release Trend --
SELECT release_year, COUNT(*) AS count
FROM titles_cleaned
GROUP BY release_year
ORDER BY release_year;



-- Director IMDb Score Variance --
SELECT c.name, COUNT(*) AS count, AVG(t.imdb_score) AS avg_score,
       STDEV(t.imdb_score) AS score_variance
FROM credits c
JOIN titles_cleaned t ON t.id = c.id
WHERE c.role = 'DIRECTOR' AND t.imdb_score IS NOT NULL
GROUP BY c.name
HAVING COUNT(*) >= 3
ORDER BY score_variance ASC;



-- New Genres Introduced Each Year ---
WITH DistinctGenres AS (
  SELECT DISTINCT release_year, genres
  FROM titles_cleaned
  WHERE genres IS NOT NULL
)
SELECT release_year, COUNT(DISTINCT genres) AS new_genres
FROM DistinctGenres
GROUP BY release_year
ORDER BY release_year;




-- Top 5 Genres by Volume --
WITH GenreCount AS (
    SELECT genres, COUNT(*) AS total
    FROM titles_cleaned
    WHERE genres IS NOT NULL
    GROUP BY genres
)
SELECT TOP 5 * FROM GenreCount
ORDER BY total DESC;



-- Country Producing Highest Rated Titles --
SELECT production_countries, AVG(imdb_score) AS avg_score
FROM titles_cleaned
WHERE imdb_score IS NOT NULL AND production_countries IS NOT NULL
GROUP BY production_countries
ORDER BY avg_score DESC;




-- Titles Repeated Across Countries --
SELECT title, COUNT(DISTINCT production_countries) AS country_versions
FROM titles_cleaned
WHERE production_countries IS NOT NULL
GROUP BY title
HAVING COUNT(DISTINCT production_countries) > 1;





-- Top Countries Producing Content --
WITH CountryContent AS (
SELECT production_countries, COUNT(*) AS count
FROM titles_cleaned
WHERE production_countries IS NOT NULL
GROUP BY production_countries
)
SELECT * 
FROM CountryContent
ORDER BY count DESC;


-- Top-Rated Titles by Year --
WITH RankedTitles AS(
SELECT title, release_year, imdb_score,
		RANK() OVER(PARTITION BY release_year ORDER BY imdb_score DESC) AS rnk
FROM titles_cleaned
WHERE imdb_score IS NOT NULL
)
SELECT * FROM RankedTitles
where rnk = 1;


-- Most Frequent Indian Actors/Directors --
WITH FrequentActors AS (
SELECT name, COUNT(*) AS appearance
FROM credits
WHERE name LIKE '%Singh' OR name LIKE '%Kumar%' OR name LIKE '%Sharma%'
GROUP BY name
)
SELECT *             --- if you want to find (TOP 10 or 5) use (SELECT TOP 5*) --
FROM FrequentActors
ORDER BY appearance DESC;


-- Rolling IMDb Score --
SELECT title, imdb_score, release_year,
		AVG(imdb_score) OVER(PARTITION BY release_year ORDER BY title ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg
FROM titles_cleaned
WHERE imdb_score IS NOT NULL;


-- Content Involving Violence or Crime Keywords -- 
SELECT title, genres
FROM titles_cleaned
WHERE title LIKE '%kill%' OR title LIKE '%murder%' OR title LIKE '%crime%' OR title LIKE '%violence%';


--  IMDb Score vs Votes --
SELECT imdb_score, imdb_votes
FROM titles_cleaned
WHERE imdb_score IS NOT NULL AND imdb_votes IS NOT NULL
ORDER BY imdb_votes DESC;



-- Content by Runtime Category --
SELECT title, runtime,
		CASE
			WHEN runtime < 40 THEN 'Short'
			WHEN runtime BETWEEN 40 AND 90 THEN 'Medium'
			ELSE 'Long'
		END AS duration_category
FROM titles_cleaned
WHERE runtime IS NOT NULL;


--  Yearly Content Trend  --
WITH YearlyContent AS (
SELECt release_year, COUNT(*) AS Total
FROM titles_cleaned
GROUP BY release_year
)
SELECT * 
FROM YearlyContent
ORDER BY release_year;


-- Top 10 Most Frequent Actors/Directors --
SELECT c.name, c.role, COUNT(*) AS appearances
FROM credits c JOIN titles_cleaned t 
ON c.id = t.id
GROUP BY c.name, c.role
ORDER BY appearances DESC;


--  Top Directors of High IMDb Score Shows  --
SELECT t.title, t.imdb_score, c.name AS director
FROM titles_cleaned t JOIN credits c
ON t.id = c.id
WHERE c.role = 'DIRECTOR' AND t.imdb_score IS NOT NULL
ORDER BY t.imdb_score DESC;



-- Number of Titles per Actor --
SELECT c.name, COUNT(DISTINCT t.title) AS total_titles
FROM credits c JOIN titles_cleaned t 
ON t.id = c.id
WHERE c.role = 'ACTOR'
GROUP BY c.name
ORDER BY total_titles DESC;



-- Which Genres Have the Most Directors Working --
SELECT t.genres, COUNT(DISTINCT c.name) AS unique_directors
FROM titles_cleaned t JOIN Credits c
ON t.id = c.id
WHERE c.role = 'DIRECTOR'
GROUP BY t.genres
ORDER BY unique_directors DESC;



-- Actor Collaboration in Long Runtime Shows --
SELECT t.title, t.runtime, c.name
FROM titles_cleaned t
JOIN credits c ON t.id = c.id
WHERE t.runtime > 120 AND c.role = 'ACTOR'
ORDER BY t.runtime DESC;


-- Compare IMDb Score with Previous Year-- 
SELECT title, release_year, imdb_score,
       LAG(imdb_score) OVER (PARTITION BY title ORDER BY release_year) AS prev_year_score
FROM titles_cleaned
WHERE imdb_score IS NOT NULL;




-- Place Titles into 4 Groups Based on IMDb Score
SELECT title, imdb_score,
       NTILE(4) OVER (ORDER BY imdb_score DESC) AS score_quartile
FROM titles_cleaned
WHERE imdb_score IS NOT NULL;


-- Total of Titles Released per Year--
SELECT release_year, COUNT(*) AS yearly_titles,
       SUM(COUNT(*)) OVER (ORDER BY release_year) AS cumulative_titles
FROM titles_cleaned
GROUP BY release_year
ORDER BY release_year;




-- Full IMDb Score Movement
SELECT title, release_year, imdb_score,
       LAG(imdb_score) OVER (PARTITION BY title ORDER BY release_year) AS prev_score,
       LEAD(imdb_score) OVER (PARTITION BY title ORDER BY release_year) AS next_score
FROM titles_cleaned
WHERE imdb_score IS NOT NULL;




-- Country Producing Highest Rated Titles --
SELECT production_countries, AVG(imdb_score) AS avg_score
FROM titles_cleaned
WHERE imdb_score IS NOT NULL AND production_countries IS NOT NULL
GROUP BY production_countries
ORDER BY avg_score DESC;
