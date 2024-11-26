DROP TABLE IF EXISTS actors;
DROP TYPE films;
CREATE TYPE films AS  (film TEXT,
			 year INTEGER,
			 votes INTEGER,
			 rating REAL,
			 filmid TEXT);

CREATE TABLE actors AS
	with actors_recent_year_rating AS (
		SELECT 
			af.actorid,
			my.recent_year,
			CASE
				WHEN AVG (af.rating) > 8 THEN 'star'
				WHEN AVG (af.rating) > 7 AND AVG (af.rating) <= 8 THEN 'good'
				WHEN AVG (af.rating) > 6 AND AVG (af.rating) <= 7  THEN 'averge'
				WHEN AVG (af.rating) <= 6 THEN 'bad'
			END AS quality_class	
		FROM actor_films as af
		LEFT JOIN 
		(SELECT actorid, MAX(year) as recent_year FROM actor_films GROUP BY actorid) as my
		ON af.actorid = my.actorid
		GROUP BY
			af.actorid,
			af.actor,
			my.recent_year
		)
	SELECT
		af.actorid,
		af.actor,
		array_agg(ROW(af.film, af.year, af.votes, af.rating, af.filmid)::films) AS films,
		ary.quality_class,
		CASE 
		WHEN ary.recent_year = '2021' THEN 1
		ELSE 0
		END AS is_active

	FROM actor_films as af
	LEFT JOIN actors_recent_year_rating  ary
	ON  af.actorid = ary.actorid
	GROUP BY
		af.actorid,
		af.actor,
		ary.quality_class,
		is_active	

	
