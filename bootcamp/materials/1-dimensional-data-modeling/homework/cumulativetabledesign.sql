DROP TABLE IF EXISTS actors_cd;
DROP TYPE films;
CREATE TYPE films AS  (
				film TEXT,
				year INTEGER,
				votes INTEGER,
				rating REAL,
				filmid TEXT);

CREATE TABLE actors_cd(
		actorid TEXT,
		actor TEXT,
		films films[],
		quality_class TEXT,
	    is_active INT,
		current_year INT,
		PRIMARY KEY(actorid,current_year)
	);
INSERT INTO actors_cd
WITH yesterday AS(
	SELECT * FROM actors_cd
	WHERE current_year = '1969'
),
today AS(
	SELECT * FROM actor_films
	WHERE year = '1970'
)

SELECT 
	COALESCE(t.actorid,y.actorid) AS actorid,
	COALESCE(t.actor,y.actor) AS actor,
	CASE 
		WHEN y.films IS NULL 
			THEN ARRAY[ROW(
					t.film,
					t.year,
					t.votes,
					t.rating,
					t.filmid)::films]
		WHEN t.film IS NOT NULL THEN y.films || ARRAY[ROW(
					t.film,
					t.year,
					t.votes,
					t.rating,
					t.filmid)::films]
		ELSE y.films
		
		END AS films,
	COALESCE(t.year, y.current_year+1) as current_year
FROM today t
FULL OUTER JOIN yesterday y
ON t.actorid = y.actorid


	

	
