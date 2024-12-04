DROP TABLE IF EXISTS  user_devices_cumulated;
CREATE TABLE user_devices_cumulated(
	user_id TEXT,
 	date_active DATE[],
 	--browser_type TEXT,
 	date DATE,
 	PRIMARY KEY(user_id,date)
);

	  WITH 
	   dedup AS (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY user_id,DATE(event_time)) as rn  FROM events
		   WHERE user_id is not null
			)


			SELECT * FROM dedup 
			WHERE rn = 1;


		INSERT INTO user_devices_cumulated 
	  WITH 
	   dedup AS (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY user_id,DATE(event_time)) as rn  FROM events
		     WHERE user_id IS NOT NULL
			), 
		deduped_events AS (

			SELECT * FROM dedup 
			WHERE rn = 1)
	 ,yesterday AS (
			SELECT
				*
			FROM user_devices_cumulated
			WHERE date = DATE('2023-01-30')
		),
		today AS (
			SELECT 
				CAST(user_id AS TEXT), 
				DATE(event_time) as date_active
			FROM deduped_events
			WHERE DATE(event_time) = DATE('2023-01-30') + INTERVAL '1 day'
				AND user_id IS NOT NULL
			GROUP BY 1,2
		)
		SELECT 
			COALESCE(t.user_id, y.user_id) AS user_id,
			CASE 
				WHEN y.date_active IS NULL
					THEN ARRAY[t.date_active]
				WHEN t.date_active IS NULL 
					THEN y.date_active
				ELSE  ARRAY[t.date_active] || y.date_active 
			END as date_active,
			COALESCE(t.date_active, y.date + INTERVAL '1 day') as date
		FROM today t
		FULL OUTER JOIN yesterday y ON t.user_id = y.user_id
		
		
		SELECT * FROM user_devices_cumulated where date = date('2023-01-31')

