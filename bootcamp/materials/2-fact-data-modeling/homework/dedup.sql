SELECT game_id,team_id,player_id, COUNT(1)
FROM game_details
GROUP BY 1,2,3
HAVING COUNT(1)>1
ORDER BY  COUNT(1) DESC;

WITH dedup AS (
SELECT gd.* , g.game_date_est,  ROW_NUMBER() OVER (PARTITION BY gd.game_id, team_id, player_id ORDER BY g.game_date_est ) as rn

FROM game_details as gd
JOIN games g on gd.game_id = g.game_id
)

SELECT * FROM dedup 
WHERE rn = 1

