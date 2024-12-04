DROP TABLE IF EXISTS  user_devices_cumulated;
CREATE TABLE user_devices_cumulated(
	user_id TEXT,
	device_id TEXT,
	browser_type TEXT,
 	date_active DATE[],
 	date DATE,
 	PRIMARY KEY(user_id,device_id,browser_type,date)
);

	  WITH 
	   dedup AS (
			SELECT user_id,d.device_id,
		   d.browser_type as browser_type , 
		   DATE(event_time) as active_day,
		   ROW_NUMBER() OVER (PARTITION BY e.user_id,d.device_id,d.browser_type, DATE(event_time)) as rn  FROM events e
		   LEFT JOIN devices d
		   ON e.device_id = d.device_id
		   WHERE e.user_id is not null
		   	and d.device_id is not null
			)


			SELECT user_id,device_id,browser_type,active_day  FROM dedup 
			WHERE rn = 1 and user_id = '13580626093054200000' and active_day = '2023-01-03'
			;



		INSERT INTO user_devices_cumulated 
	  WITH 
	   dedup AS (
			SELECT user_id,d.device_id,
		   d.browser_type as browser_type , 
		   event_time,
		   ROW_NUMBER() OVER (PARTITION BY e.user_id,d.device_id,d.browser_type, DATE(event_time)) as rn  FROM events e
		   LEFT JOIN devices d
		   ON e.device_id = d.device_id 
		   WHERE e.user_id is not null
		   	and d.device_id is not null
			), 
		deduped_events AS (

			SELECT user_id,device_id,browser_type,event_time  FROM dedup 
			WHERE rn = 1

		)
	 ,yesterday AS (
			SELECT
				*
			FROM user_devices_cumulated
			WHERE date = DATE('2023-01-02')
		),
		today AS (
			SELECT 
				CAST(user_id AS TEXT), 
				CAST(device_id AS TEXT),
			    browser_type,
				DATE(event_time) as date_active
			FROM deduped_events
			WHERE DATE(event_time) = DATE('2023-01-02') + INTERVAL '1 day'
				AND user_id IS NOT NULL and device_id IS NOT NULL
			GROUP BY 1,2,3,4
		)
		SELECT 
			COALESCE(t.user_id, y.user_id) AS user_id,
			COALESCE(t.device_id, y.device_id) AS device_id,
		    COALESCE(t.browser_type, y.browser_type)  as browser_type,
			CASE 
				WHEN y.date_active IS NULL
					THEN ARRAY[t.date_active]
				WHEN t.date_active IS NULL 
					THEN y.date_active
				ELSE  ARRAY[t.date_active] || y.date_active 
			END as date_active,

			COALESCE(t.date_active, y.date + INTERVAL '1 day') as date
		FROM today t
		FULL OUTER JOIN yesterday y ON t.user_id = y.user_id;
		
		
		SELECT * FROM user_devices_cumulated 
		--where date= date('2023-01-31')
		;


