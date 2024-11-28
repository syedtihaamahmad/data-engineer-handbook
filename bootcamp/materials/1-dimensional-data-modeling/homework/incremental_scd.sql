DROP TYPE IF  EXISTS scd_type;
CREATE TYPE scd_type AS (
                    quality_class quality_class,
                    is_active boolean,
                    start_year INTEGER,
                    end_year INTEGER
                        );


WITH last_year_scd AS (
    SELECT * FROM actors_history_scd_bf
    WHERE current_year = 2021
    AND end_year = 2021
),
historical_scd AS (
	SELECT
		
		actorid,
		actor,
		quality_class,
		is_active,
		start_year,
		end_year
	FROM actors_history_scd_bf
	WHERE current_year = 2021
	AND end_year < 2021
     ),
this_year_data AS (
	 SELECT * FROM actors_history_scd_bf
	 WHERE current_year = 2022
 ),
unchanged_records AS (
SELECT
	ts.actorid,
	ts.actor,
	ts.quality_class,
	ts.is_active,
	ls.start_year,
	ts.current_year as end_year
FROM this_year_data ts
JOIN last_year_scd ls
ON ls.actorid = ts.actorid
WHERE ts.quality_class = ls.quality_class
AND ts.is_active = ls.is_active
     ),
	 
changed_records AS (
	
SELECT
	ts.actorid,
	ts.actor,
	UNNEST(ARRAY[
		ROW(
			ls.quality_class,
			ls.is_active,
			ls.start_year,
			ls.end_year

			)::scd_type,
		ROW(
			ts.quality_class,
			ts.is_active,
			ts.current_year,
			ts.current_year
			)::scd_type
	]) as records
FROM this_year_data ts
LEFT JOIN last_year_scd ls
ON ls.actorid = ts.actorid
WHERE (ts.quality_class <> ls.quality_class
OR ts.is_active <> ls.is_active)
),
unnested_changed_records AS (

SELECT actorid,
	actor,
	(records::scd_type).quality_class,
	(records::scd_type).is_active,
	(records::scd_type).start_year,
	(records::scd_type).end_year
	FROM changed_records
),
new_records AS (

SELECT
ts.actorid,
	ts.actor,
	ts.quality_class,
	ts.is_active,
	ts.current_year AS start_year,
	ts.current_year AS end_year
FROM this_year_data ts
LEFT JOIN last_year_scd ls
 ON ts.actorid = ls.actorid
WHERE ls.actorid IS NULL

)



  SELECT *
  FROM historical_scd

  UNION ALL

  SELECT *
  FROM unchanged_records

  UNION ALL

  SELECT *
  FROM unnested_changed_records

  UNION ALL

  SELECT *
  FROM new_records
              