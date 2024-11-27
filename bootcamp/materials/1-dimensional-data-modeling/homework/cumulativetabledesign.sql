DROP TABLE IF EXISTS actors_cd;
DROP TYPE films;
CREATE TYPE films AS  (
				film TEXT,
				votes INTEGER,
				rating REAL,
				filmid TEXT);
CREATE TYPE	quality_class AS ENUM ('star','good','average','bad');
CREATE TABLE actors_cd(
		actorid TEXT,
		actor TEXT,
		year  INT,
		films films[],
		quality_class quality_class,
	    is_active BOOL,
		current_year INT,
		PRIMARY KEY(actorid,current_year)
	);
	 

DO $$	
--years from 1969 to 2021	
DECLARE
    year_range INT;
BEGIN
    FOR year_range IN 
    	SELECT generate_series(1969, 2021)
    LOOP
		RAISE NOTICE 'Processing data for year: %', year_range;	
		
		INSERT INTO actors_cd
		WITH yesterday AS(
			SELECT * FROM actors_cd
			WHERE current_year = year_range
		),
		today AS(
			SELECT 
				actor,
				actorid,
				year,
				 array_agg(ROW(
							film,
							votes,
							rating,
							filmid)::films) AS films_in_year,
			CASE
				WHEN AVG (rating) > 8 
					THEN 'star'::quality_class
				WHEN AVG (rating) > 7 AND AVG (rating) <= 8 
					THEN 'good'::quality_class
				WHEN AVG (rating) > 6 AND AVG (rating) <= 7  
					THEN 'average'::quality_class
				WHEN AVG (rating) <= 6 
					THEN 'bad'::quality_class
			END AS quality_class	


			FROM actor_films
			WHERE year = year_range + 1
			GROUP BY
				actor,
				actorid,
				year

		)

		SELECT 
			COALESCE(t.actorid,y.actorid) AS actorid,
			COALESCE(t.actor,y.actor) AS actor,
			COALESCE(t.year,y.year) AS year,
			CASE 
				WHEN y.films IS NULL 
					THEN t.films_in_year		
				WHEN t.films_in_year IS NOT NULL 
					THEN y.films || t.films_in_year		
				ELSE y.films
			END AS films,
			t.quality_class,
			CASE 
				WHEN t.year IS NOT NULL
					THEN TRUE
				ELSE FALSE
			END AS	is_active,
			COALESCE(t.year, y.current_year+1) as current_year
		FROM today t
		FULL OUTER JOIN yesterday y
		ON t.actorid = y.actorid;
    END LOOP;
END $$;


-- query to test cumulative desing table
SELECT * FROM actors_cd
--where current_year ='1970' and actorid ='nm0001128'

-- Unnesting query decumulating, it's always gonna be sorted
WITH unnested AS (	
SELECT 
	actor,
	actorid,
	year,
	UNNEST(films)::films AS films
	

FROM actors_cd
where  actorid ='nm0001128'
)

SELECT actor,
	actorid,
	year,
	(films::films).* AS films
FROM unnested

	
