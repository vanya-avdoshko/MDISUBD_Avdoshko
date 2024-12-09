select * from Player;

select * from Player where jersey_number = 11;

select * from UserProfile
where user_id in 
(select user_id from Player where jersey_number = 11);

select * from "User" where role_id < 3;

select jersey_number, team_id, points 
from player order by points desc limit 1;

select jersey_number, team_id, points 
from player order by points asc limit 1;

select jersey_number, team_id, points 
from player order by points desc limit 5;

select jersey_number, team_id, points 
from player order by points desc;

select count(*) from player where team_id = 3;

select count(*) from player where team_id = 3 and points > 10;

SELECT team_id, COUNT(*) AS player_count FROM Player GROUP BY team_id;

SELECT DISTINCT position FROM Player;

SELECT jersey_number, team_id, points 
FROM Player 
WHERE points > (SELECT AVG(points) FROM Player);

SELECT jersey_number, team_id, points 
FROM Player 
WHERE points > (SELECT AVG(points) FROM Player) order by points desc;

SELECT ROUND(AVG(points)) AS average_points FROM Player;

select * from userProfile where (user_id 
in (select id from "User" where role_id = 3))
and name like 'С%';

select * from userProfile where (user_id 
in (select id from "User" where role_id = 3))
and surname like 'К%';

SELECT * FROM Player WHERE jersey_number IN (9, 10, 5);

SELECT * FROM Match WHERE DATE(date) = '2024-11-20';

select * from playermatch;

select * from playerstatistics;

select * from userprofile where user_id =
(select coach_id from team where id =
(select team_id from player where jersey_number = 9));

select team_id, count(*) as players from player 
where points > 10 group by team_id order by team_id asc;

select * from player;

select * from playerstatistics;

select * from playermatch;

select * from playerstatistics where 
player_id = (select id from player where
team_id = (select away_team_id from match) order by points desc limit 1);

SELECT * 
FROM UserProfile 
WHERE user_id IN (
    SELECT user_id 
    FROM Player 
    WHERE jersey_number IN (
        SELECT jersey_number 
        FROM Player 
        GROUP BY jersey_number 
        HAVING COUNT(DISTINCT team_id) > 1 limit 2
    )
);


select * from tournament where
id in (select tournament_id from match where 
id in (select match_id from playermatch where 
player_id in (select id from player where 
user_id in (select user_id from userprofile where user_id = 3) ) ) );

SELECT * from team where 
id in ( select team_id
FROM Player
GROUP BY team_id
HAVING SUM(points) > 50);


select * from "User" where    
id in (select coach_id from team where 
id in (select home_team_id from match) or id in (select away_team_id from match));


select * from player
inner join team on player.team_id = team.id;

select * from player
left join team on player.team_id = team.id;

SELECT
    "User".id AS coach_id,
    "User".email AS coach_email,
    Team.id AS team_id,
    Team.name AS team_name
FROM
    (SELECT id, email FROM "User" WHERE role_id = 2) AS "User"
FULL JOIN
    Team ON "User".id = Team.coach_id;

select * from "User"

CREATE VIEW MatchResults AS
SELECT m.id AS match_id, t1.name AS home_team, t2.name AS away_team, m.result, m.date
FROM Match m
JOIN Team t1 ON m.home_team_id = t1.id
JOIN Team t2 ON m.away_team_id = t2.id;

select * from matchresults
select * from match

select t.name, p.jersey_number as player_number 
from Team t
left join Player p on t.id = p.team_id


select m.id, u.name as player_name
from Match m
inner join Player p on m.home_team_id = p.team_id
inner join UserProfile u on u.user_id = p.user_id

SELECT p.jersey_number, t.name AS team_name
FROM Player p
CROSS JOIN Team t;


select m.id, t.name as team_name
from Match m
right join Team t on m.tournament_id = 1

SELECT p1.id AS player1, p2.id AS player2
FROM Player p1
INNER JOIN Player p2 ON p1.team_id = p2.team_id AND p1.id != p2.id;

SELECT p1.id AS player1, p2.id AS player2
FROM Player p1
cross JOIN Player p2;

SELECT 
    team_id, 
    id, 
	points,
    ROW_NUMBER() OVER (PARTITION BY team_id ORDER BY points DESC) AS player_rank
FROM 
    Player;

SELECT 
    id, 
    team_id, 
    points, 
    RANK() OVER (PARTITION BY team_id ORDER BY points DESC) AS rank_in_team
FROM 
    Player;


SELECT * 
FROM "User" 
WHERE id IN (
    SELECT coach_id 
    FROM Team 
    WHERE id IN (
        SELECT home_team_id 
        FROM Match
    )
    
    UNION
    
    SELECT coach_id 
    FROM Team 
    WHERE id IN (
        SELECT away_team_id 
        FROM Match
    )
);


SELECT id 
FROM Team t
WHERE EXISTS (
    SELECT 1 
    FROM Player p 
    WHERE p.team_id = t.id AND p.points > 14
);


SELECT 
    id, 
    points, 
    CASE 
        WHEN points >= 10 THEN 'MVP'
        WHEN points BETWEEN 5 AND 9 THEN 'Star Player'
        ELSE 'Regular Player'
    END AS player_status
FROM Player;

EXPLAIN 
SELECT * 
FROM Player 
WHERE team_id = 3 AND points > 10;



INSERT INTO PlayerStatistics (player_id, points_scored, assists, blocks, aces)
SELECT id, points, assists, blocks, aces
FROM Player
WHERE points > 5;

select * from playerstatistics

select player.team_id, player.jersey_number, userprofile.name, userprofile.surname
from player
join match on match.home_team_id = player.team_id or match.away_team_id = player.team_id
join userprofile on userprofile.user_id = player.id
join "User" on "User".id = userprofile.user_id
where "User".role_id = 3
order by player.team_id;

SELECT team_id, sum(points) FROM player GROUP BY team_id;
SELECT id, team_id, SUM(points) OVER (PARTITION BY team_id) FROM player;


select player.id, tournament.name, match.id, team.id
from player
join team on team.id = player.team_id
join match on match.home_team_id = team.id or match.away_team_id = team.id
join tournament on match.tournament_id = tournament.id; 


select userprofile.surname, tournament.name, match.result, team.name, match.date
from player
join team on team.id = player.team_id
join match on match.home_team_id = team.id or match.away_team_id = team.id
join tournament on match.tournament_id = tournament.id
join userprofile on userprofile.user_id = player.user_id;
