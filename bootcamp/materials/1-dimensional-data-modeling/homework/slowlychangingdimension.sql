DROP TABLE IF EXISTS actors_history_scd;
CREATE TABLE actors_history_scd(
		actorid TEXT,
		actor TEXT,
		streak_identifier INT,
		quality_class quality_class,
	    is_active BOOL,
		start_year INT,
		end_year INT,
		PRIMARY KEY(actorid, start_year)
	
	);
	
INSERT INTO actors_history_scd
with change_indicator AS (	
	SELECT 
		actorid,
		actor,
		current_year,
		films,
		is_active,
		LAG(is_active, 1)
				OVER(PARTITION BY actorid ORDER BY current_year) as previous_is_active,
		quality_class,
		LAG(quality_class, 1)
			OVER(PARTITION BY actorid ORDER BY current_year) as previous_quality_class,
		CASE
			WHEN quality_class <> LAG(quality_class, 1)
				OVER(PARTITION BY actorid ORDER BY current_year)
			THEN 1
			WHEN is_active <> LAG(is_active, 1)
				OVER(PARTITION BY actorid ORDER BY current_year)
			THEN 1
			ELSE 0
		END AS change_indicator
	FROM actors_cd
),
streak_identifier as (
	SELECT
    actorid,
	actor,
    current_year,
    quality_class,
    is_active,
	SUM (change_indicator) OVER (PARTITION BY actorid ORDER BY current_year) as streak_identifier

FROM change_indicator

)

SELECT
    actorid,
	actor,
	streak_identifier,
	quality_class,
    is_active,
    MIN(current_year) AS start_year,
    MAX(current_year) AS end_year
FROM streak_identifier
GROUP BY 
	actorid,
	actor,
	streak_identifier,
    quality_class,
    is_active
	
ORDER BY 
	actorid,
	streak_identifier;

--select query
SELECT * FROM actors_history_scd ;	
