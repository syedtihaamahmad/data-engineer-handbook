WITH dedup AS (
SELECT * , ROW_NUMBER() OVER (PARTITION BY game_id, team_id, player_id) as rn

FROM game_details as gd

)

SELECT * FROM dedup 
WHERE rn = 1

