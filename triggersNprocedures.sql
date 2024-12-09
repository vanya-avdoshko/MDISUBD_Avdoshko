--ФУНКЦИИ И ТРИГГЕРЫ

--функция для того чтобы делать игроков свободными агентами при удалении команды
CREATE OR REPLACE FUNCTION free_players_on_team_delete() RETURNS TRIGGER AS $$
BEGIN
    UPDATE player SET team_id = NULL WHERE team_id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

--триггер на удаление команды
CREATE TRIGGER team_delete_trigger
AFTER DELETE ON team
FOR EACH ROW EXECUTE FUNCTION free_players_on_team_delete();

--функция для автопересчета очков в playermatch
CREATE OR REPLACE FUNCTION update_points_playermatch() RETURNS TRIGGER AS $$
BEGIN
    NEW.points := NEW.attacks + NEW.aces + NEW.blocks + NEW.assists;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--триггер для пересчета очков
CREATE TRIGGER calculate_points_playermatch
BEFORE INSERT OR UPDATE ON PlayerMatch
FOR EACH ROW
EXECUTE FUNCTION update_points_playermatch();


--функция для автопересчета очков в playerstatistics
CREATE OR REPLACE FUNCTION update_points_playerstatistics() RETURNS TRIGGER AS $$
BEGIN
    NEW.points := NEW.attacks + NEW.aces + NEW.blocks + NEW.assists;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--триггер для пересчета очков
CREATE TRIGGER calculate_points_playerstatistics
BEFORE INSERT OR UPDATE ON PlayerStatistics
FOR EACH ROW
EXECUTE FUNCTION update_points_playerstatistics();

--ограничение на количество игроков в команде
CREATE OR REPLACE FUNCTION limit_team_size() RETURNS TRIGGER AS $$
DECLARE
    player_count INT;
BEGIN
    SELECT COUNT(*) INTO player_count FROM Player WHERE team_id = NEW.team_id;
    IF player_count >= 12 THEN
        RAISE EXCEPTION 'Нельзя добавить больше 12 игроков в команду';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--триггер лимита игроков
CREATE TRIGGER limit_team_size_trigger
BEFORE INSERT ON Player
FOR EACH ROW EXECUTE FUNCTION limit_team_size();


--функция для логирования
CREATE OR REPLACE FUNCTION log_user_updates() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO ActionLog (user_id, action_type, created_at)
    VALUES (NEW.id, 'UPDATE USER', NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--триггер логирования
CREATE TRIGGER user_update_trigger
AFTER UPDATE ON "User"
FOR EACH ROW EXECUTE FUNCTION log_user_updates();
select * from actionlog;


--ПРОЦЕДУРЫ

--процедура для добавления игроков с проверкой номера
CREATE OR REPLACE PROCEDURE add_player(
    p_user_id INT,
    p_team_id INT,
    p_position VARCHAR,
    p_jersey_number INT
) AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM Player 
        WHERE team_id = p_team_id AND jersey_number = p_jersey_number
    ) THEN
        RAISE EXCEPTION 'Номер % уже занят в команде %', p_jersey_number, p_team_id;
    ELSE
        INSERT INTO Player (user_id, team_id, position, jersey_number)
        VALUES (p_user_id, p_team_id, p_position, p_jersey_number);
    END IF;
END;
$$ LANGUAGE plpgsql;


--процедура обновления статистики
CREATE OR REPLACE PROCEDURE update_player_statistics(
    p_player_id INT,
    p_points INT,
    p_assists INT,
    p_blocks INT,
    p_aces INT,
    p_attacks INT
) AS $$
BEGIN
    UPDATE PlayerStatistics
    SET 
        matches_played = matches_played + 1,
        points = points + p_points,
        assists = assists + p_assists,
        blocks = blocks + p_blocks,
        aces = aces + p_aces,
        attacks = attacks + p_attacks
    WHERE player_id = p_player_id;
END;
$$ LANGUAGE plpgsql;

--добавление новой команды с проверкой имени
CREATE OR REPLACE PROCEDURE add_team(
    p_name VARCHAR,
    p_coach_id INT
) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Team WHERE name = p_name) THEN
        RAISE EXCEPTION 'Команда с именем "%" уже существует', p_name;
    ELSE
        INSERT INTO Team (name, coach_id) VALUES (p_name, p_coach_id);
    END IF;
END;
$$ LANGUAGE plpgsql;


--получение расписания матчей в турнире
CREATE OR REPLACE PROCEDURE get_tournament_schedule(
    p_tournament_id INT
) AS $$
DECLARE
    match_record RECORD;  -- Объявляем переменную типа record
BEGIN
    FOR match_record IN
        SELECT 
            m.id AS match_id,
            t1.name AS home_team,
            t2.name AS away_team,
            m.date
        FROM Match m
        JOIN Team t1 ON m.home_team_id = t1.id
        JOIN Team t2 ON m.away_team_id = t2.id
        WHERE m.tournament_id = p_tournament_id
    LOOP
        RAISE INFO 'Match ID: %, Home Team: %, Away Team: %, Date: %',
            match_record.match_id, match_record.home_team, match_record.away_team, match_record.date;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

--получение игроков и статистики по команде
CREATE OR REPLACE PROCEDURE get_team_players_with_stats(
    p_team_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    player_record RECORD;
BEGIN
    FOR player_record IN
        SELECT 
            p.id AS player_id,
            p.jersey_number,
            u.name AS player_name,
            u.surname AS player_surname,
            ps.matches_played,
            ps.points,
            ps.assists,
            ps.blocks,
            ps.aces,
			ps.attacks
        FROM Player p
        JOIN UserProfile u ON p.user_id = u.user_id
        JOIN PlayerStatistics ps ON p.id = ps.player_id
        WHERE p.team_id = p_team_id
    LOOP
        RAISE NOTICE 'ID игрока: %, Номер: %, Имя: % %, Матчи: %, Очки: %, Пасы: %, Блоки: %, Эйсы: %',
            player_record.player_id, player_record.jersey_number, 
            player_record.player_name, player_record.player_surname, 
            player_record.matches_played, player_record.points, 
            player_record.assists, player_record.blocks, player_record.aces;
    END LOOP;
END;
$$;


--------------------------------------------------------------




DELETE FROM Team where id = 3;
select * from player;


SELECT conname, confdeltype
FROM pg_constraint
WHERE conrelid = 'player'::regclass;

select * from playerstatistics;

UPDATE PlayerStatistics
SET points = attacks + aces + blocks + assists;


update "User" set email = 'new_email1@gmail.com'
where id = 3;




INSERT INTO "User" (email, password, role_id, created_at) VALUES 
('player15@gmail.com', 'pass15', 3, NOW()),
('player16@gmail.com', 'pass16', 3, NOW()),
('player17@gmail.com', 'pass17', 3, NOW());
select * from "User";

INSERT INTO Player (user_id, team_id, position, jersey_number, created_at) VALUES
(20, 4, 'Центральный блокирующий', 22, NOW());


INSERT INTO "User" (email, password, role_id, created_at) VALUES 
('player18@gmail.com', 'pass18', 3, NOW()),
('player19@gmail.com', 'pass19', 3, NOW()),
('player20@gmail.com', 'pass20', 3, NOW());
INSERT INTO "User" (email, password, role_id, created_at) VALUES 
('player21@gmail.com', 'pass21', 3, NOW());

INSERT INTO Player (user_id, team_id, position, jersey_number, created_at) VALUES
(22, 4, 'Центральный блокирующий', 27, NOW()),
(23, 4, 'Центральный блокирующий', 28, NOW()),
(24, 4, 'Центральный блокирующий', 34, NOW()),
(25, 4, 'Центральный блокирующий', 36, NOW());


INSERT INTO "User" (email, password, role_id, created_at) VALUES 
('player25@gmail.com', 'pass25', 3, NOW());
CALL add_player(27, 4, 'Либеро', 1);

CALL add_team('Карасуно', 8);
select * from team;
select * from player;

CALL update_player_statistics(12, 23, 3, 3, 13, 4);  

CALL get_tournament_schedule(1);  

select * from tournament;
SELECT * FROM Match WHERE tournament_id = 1; 
INSERT INTO Match (home_team_id, away_team_id, tournament_id, date, result, created_at) VALUES
(5, 4, 1, '2024-11-22', 'Хозяева 1:3 Гости', NOW());
INSERT INTO Match (home_team_id, away_team_id, tournament_id, date, result, created_at) VALUES
(5, 4, 1, '2024-12-01', 'Хозяева 3:0 Гости', NOW());

CALL get_team_players_with_stats(4);
select * from player where team_id = 4;






--ЗАДАНИЕ
CREATE OR REPLACE FUNCTION handle_past_match()
RETURNS TRIGGER AS $$
DECLARE
    home_team_players INT;
    away_team_players INT;
BEGIN
    -- Проверяем, если дата матча уже прошла
    IF NEW.date < NOW() THEN
        -- Добавляем записи для игроков домашней команды
        FOR home_team_players IN
            SELECT p.id
            FROM Player p
            WHERE p.team_id = NEW.home_team_id
        LOOP
            INSERT INTO PlayerMatch (player_id, match_id, points, assists, blocks, aces)
            VALUES (home_team_players, NEW.id, 0, 0, 0, 0);
        END LOOP;

        -- Добавляем записи для игроков гостевой команды
        FOR away_team_players IN
            SELECT p.id
            FROM Player p
            WHERE p.team_id = NEW.away_team_id
        LOOP
            INSERT INTO PlayerMatch (player_id, match_id, points, assists, blocks, aces)
            VALUES (away_team_players, NEW.id, 0, 0, 0, 0);
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_past_match
AFTER INSERT ON Match
FOR EACH ROW 
EXECUTE FUNCTION handle_past_match();

INSERT INTO Match (home_team_id, away_team_id, tournament_id, date, result, created_at) VALUES
(5, 4, 1, '2024-11-26', 'Хозяева 0:3 Гости', NOW());


INSERT INTO Match (home_team_id, away_team_id, tournament_id, date, result, created_at) VALUES
(5, 4, 1, '2024-12-13', 'Хозяева 3:1 Гости', NOW());

select * from match;
select * from playermatch where match_id=7;