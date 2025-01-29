SELECT ip , CAST (avg(num_hits) AS integer) as avg_num_hits
FROM processed_events_aggregated_source
where host = 'bootcamp.techcreator.io'
GROUP BY ip
;
--question 2
SELECT  host, CAST (avg(num_hits) AS integer) as avg_num_hits
FROM processed_events_aggregated_source
WHERE host IN ('zachwilson.techcreator.io', 'zachwilson.tech', 'lulu.techcreator.io')
GROUP BY host