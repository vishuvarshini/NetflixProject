CREATE TABLE Netflix(show_id VARCHAR(50), 
type VARCHAR(20), 
title VARCHAR(110),
director VARCHAR(250), 
casts VARCHAR(1000), 
country VARCHAR(150), 
date_added VARCHAR(100), 
release_year INT, 
rating VARCHAR(20), 
duration VARCHAR(15), 
listed_in VARCHAR(25), 
description VARCHAR(25)
);

ALTER TABLE Netflix
ALTER COLUMN listed_in TYPE VARCHAR(300);

ALTER TABLE Netflix
ALTER COLUMN description TYPE VARCHAR(500);

--RETURNIG THE WHOLE DATA--
SELECT * FROM Netflix;

--Printing different types in data --
SELECT DISTINCT type FROM Netflix;

--Solving 15 Business Problems --
--Task 1: Count the number of movies and TV Shows --
SELECT type, count(type)
FROM Netflix
GROUP BY 1;

--Task 2: Find the most common rating for movies and TV shows --
SELECT type, rating
FROM(SELECT type, rating, count(rating),
RANK() OVER(PARTITION BY type ORDER BY count(rating)  DESC) as ranking
FROM Netflix
GROUP BY 1,2)as t1
WHERE ranking=1;

--Task 3: List all the movies added in a specific (year=2020)--
SELECT title, 
EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year_added
FROM Netflix
WHERE type='Movie'
AND EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD,YYYY'))=2020;


--Task 4: List all the movies released in a specific (year=2020)--
SELECT title, release_year
FROM Netflix
WHERE type='Movie' AND release_year=2020
ORDER BY title;

--Task 5: Find the top 5 countries with most content on netflix--
SELECT 
UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
COUNT(show_id) as total_count
FROM Netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--Task 6: Find the movies with longest duration--
SELECT title, duration
FROM Netflix
WHERE type='Movie' AND
(SPLIT_PART(duration, ' ',1))::int=
(SELECT MAX((SPLIT_PART(duration, ' ', 1))::int)
FROM Netflix
WHERE type='Movie');

--Task 7: Find all the content added in last 5 years--
SELECT title, 
EXTRACT(YEAR FROM to_date(date_added, 'Month DD,YYYY')) as year_added
FROM Netflix
WHERE EXTRACT(YEAR FROM to_date(date_added, 'Month DD,YYYY'))>= EXTRACT(YEAR FROM CURRENT_DATE)-5
ORDER BY year_added DESC;

SELECT DISTINCT EXTRACT(YEAR FROM to_date(date_added, 'Month DD,YYYY')) as year_added
FROM Netflix
WHERE EXTRACT(YEAR FROM to_date(date_added, 'Month DD,YYYY')) IS NOT NULL
ORDER BY year_added DESC;

--Task 8: Find all the movies and TV shows by the director 'Rajiv chilaka'--
SELECT type, title, director
FROM Netflix
WHERE director ILIKE '%Rajiv Chilaka%';

--Task 9: List all the TV shows with more than 5 seasons--
SELECT type, duration
FROM Netflix
WHERE type='TV Show' and
SPLIT_PART(duration, ' ', 1):: int >5;

--Task 10: Count the number of content items in each genre--
SELECT count(show_id) as count,
UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre
FROM Netflix
GROUP BY 2;


SELECT listed_in
FROM Netflix
WHERE listed_in ILIKE '%Documentaries%';

--Task 11: List all the movies with Documentaries--
SELECT type, listed_in
FROM Netflix
WHERE listed_in ILIKE '%documentaries%'
and type='Movie';

--Task 12: Find all the content without a director--
SELECT title, director
FROM Netflix
WHERE director IS NULL OR director=' ';

--Task 13: Find how many movies actor 'Salman Khan' appeared in last 10 years--
SELECT count(type) as count
FROM Netflix
WHERE 
type='Movie' AND
casts ILIKE '%Salman Khan%' AND
release_year>= EXTRACT(YEAR FROM CURRENT_DATE)-10;

--Task 14: Find the top 10 actors who have appeared in the highest number of movies produced in india--
SELECT 
    actor,
    COUNT(*) AS movie_count
FROM (
    SELECT TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actor
    FROM Netflix
    WHERE type = 'Movie'
      AND country ILIKE '%India%'
) AS t
GROUP BY actor
ORDER BY movie_count DESC
LIMIT 10;


--Task 15: Categorise the content based on the presence of the keywords like 'kill' and 'voilnece' in description field . Label content containing these keywords as 'bad' and all other as 'good'--
WITH new_table AS (
    SELECT *,
        CASE 
            WHEN description ILIKE '%kill%' 
              OR description ILIKE '%violence%' 
            THEN 'Bad Content'
            ELSE 'Good Content'
        END AS category
    FROM Netflix
)
SELECT 
    category, 
    COUNT(category) AS total_content
FROM new_table
GROUP BY 1;

