DROP TABLE IF EXISTS  user_devices_cumulated;
CREATE TABLE user_devices_cumulated(
	user_id TEXT,
 	date_active DATE[],
 	browser_type TEXT,
 	date DATE,
 	PRIMARY KEY(user_id)
);
INSERT INTO user_devices_cumulated
WITH yesterday AS (
SELECT
	*
FROM user_devices_cumulated
	WHERE date = DATE ('2022-12-31')

),

today AS (

SELECT 
	CAST(user_id AS TEXT), 
	DATE(event_time) as date_active
FROM events
	
WHERE DATE(event_time) =  DATE ('2023-01-01') 
	and user_id IS NOT NULL
	GROUP BY 1,2
)

SELECT 
COALESCE(t.user_id, y.user_id) AS user_id,
CASE 
	WHEN y.date_active IS NULL
		THEN ARRAY[t.date_Active]
	WHEN t.date_active IS NULL 
		THEN y.date_active
	ELSE y.date_Active || ARRAY [t.date_active]
	
END
as dates_active,
COALESCE (t.date_active, y.date + INTERVAL '1 day') as date

FROM today t
FULL OUTER JOIN yesterday y ON t.user_id = y.user_id
