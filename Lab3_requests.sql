CREATE TABLE Role (
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);

CREATE TABLE "User" (
	id SERIAL PRIMARY KEY,
	email VARCHAR(255) UNIQUE NOT NULL,
	password VARCHAR(255) NOT NULL,
	role_id INT REFERENCES Role(id),
	created_at TIMESTAMP DEFAULT NOW(),
	updated_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE UserProfile (
	id SERIAL PRIMARY KEY,
	user_id INT UNIQUE REFERENCES "User"(id),
	name VARCHAR(100) NOT NULL,
	surname VARCHAR(100) NOT NULL
);

ALTER TABLE UserProfile RENAME COLUMN nane TO name;
ALTER TABLE UserProfile ALTER COLUMN name SET NOT NULL;
ALTER TABLE UserProfile ALTER COLUMN surname SET NOT NULL;

CREATE TABLE Team (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    coach_id INT REFERENCES "User"(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE Player (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(id),
    team_id INT REFERENCES Team(id),
    position VARCHAR(50),
    jersey_number INT,
    points INT DEFAULT 0,
    assists INT DEFAULT 0,
    blocks INT DEFAULT 0,
    aces INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE Tournament (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE Match (
	id SERIAL PRIMARY KEY,
	home_team_id INT REFERENCES Team(id),
	away_team_id INT REFERENCES Team(id),
	tournament_id INT REFERENCES Tournament(id),
	date TIMESTAMP,
	result VARCHAR(50),
	created_at TIMESTAMP DEFAULT NOW()	
);

CREATE TABLE PlayerMatch (
    player_id INT REFERENCES Player(id),
    match_id INT REFERENCES Match(id),
    points INT DEFAULT 0,
    assists INT DEFAULT 0,
    blocks INT DEFAULT 0,
    aces INT DEFAULT 0,
    PRIMARY KEY (player_id, match_id)
);

CREATE TABLE PlayerStatistics (
    id SERIAL PRIMARY KEY,
    player_id INT REFERENCES Player(id),
    matches_played INT DEFAULT 0,
    points_scored INT DEFAULT 0,
    assists INT DEFAULT 0,
    blocks INT DEFAULT 0,
    aces INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE ActionLog (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(id),
    action_type VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);


INSERT INTO Role (name) VALUES ('Администратор');
INSERT INTO "User" (email, password, role_id, created_at) VALUES ('ivanavdoshko@gmail.com', '12345678', 1, NOW());
INSERT INTO UserProfile (user_id, name, surname) VALUES (1, 'Иван', 'Авдошко');

INSERT INTO Role (name) VALUES ('Тренер'), ('Игрок');
INSERT INTO "User" (email, password, role_id, created_at) VALUES 
('player1@gmail.com', 'pass1', 3, NOW()),
('player2@gmail.com', 'pass2', 3, NOW()),
('player3@gmail.com', 'pass3', 3, NOW()),
('player4@gmail.com', 'pass4', 3, NOW()),
('player5@gmail.com', 'pass5', 3, NOW()),
('player6@gmail.com', 'pass6', 3, NOW()),
('coach1@gmail.com', 'coachpass1', 2, NOW()),
('player7@gmail.com', 'pass7', 3, NOW()),
('player8@gmail.com', 'pass8', 3, NOW()),
('player9@gmail.com', 'pass9', 3, NOW()),
('player10@gmail.com', 'pass10', 3, NOW()),
('player11@gmail.com', 'pass11', 3, NOW()),
('player12@gmail.com', 'pass12', 3, NOW()),
('coach2@gmail.com', 'coachpass2', 2, NOW()),
INSERT INTO "User" (email, password, role_id, created_at) VALUES 
('player13@gmail.com', 'pass13', 3, NOW()),
('player14@gmail.com', 'pass14', 3, NOW());


INSERT INTO UserProfile (user_id, name, surname) VALUES 
(2, 'Сё', 'Хината'),
(3, 'Кей', 'Цукишма'),
(4, 'Азумане', 'Асахи'),
(5, 'Даичи', 'Савамура'),
(6, 'Рюноске', 'Танака'),
(7, 'Тобио', 'Кагеяма'),
(8, 'Укай', 'Сенсей'),
(9, 'Козуме', 'Кенма'),
(10, 'Лев', 'Хайба'),
(11, 'Тецуро', 'Куро'),
(12, 'Нобуюки', 'Кай'),
(13, 'Шохэй', 'Фукунага'),
(14, 'Такера', 'Ямамото'),
(15, 'Некомата', 'Сенсей'),
(17, 'Ю', 'Нишиноя'),
(18, 'Мориске', 'Яку');

INSERT INTO Team (name, coach_id, created_at, updated_at) VALUES
('Карасуно', '8', NOW(), NOW()),
('Некома', '15', NOW(), NOW());

INSERT INTO Player (user_id, team_id, position, jersey_number, points, assists, blocks, aces, created_at) VALUES
(2, 3, 'Центральный блокирующий', 10, 0, 0, 0, 0, NOW()),
(3, 3, 'Центральный блокирующий', 11, 0, 0, 0, 0, NOW()),
(4, 3, 'Доигровщик', 3, 0, 0, 0, 0, NOW()),
(5, 3, 'Доигровщик', 1, 0, 0, 0, 0, NOW()),
(6, 3, 'Доигровщик', 5, 0, 0, 0, 0, NOW()),
(7, 3, 'Связующий', 9, 0, 0, 0, 0, NOW()),
(17, 3, 'Либеро', 4, 0, 0, 0, 0, NOW()),
(9, 4, 'Связующий', 5, 0, 0, 0, 0, NOW()),
(10, 4, 'Центральный блокирующий', 11, 0, 0, 0, 0, NOW()),
(11, 4, 'Центральный блокирующий', 1, 0, 0, 0, 0, NOW()),
(12, 4, 'Доигровщик', 2, 0, 0, 0, 0, NOW()),
(13, 4, 'Доигровщик', 6, 0, 0, 0, 0, NOW()),
(14, 4, 'Доигровщик', 4, 0, 0, 0, 0, NOW()),
(18, 4, 'Либеро', 3, 0, 0, 0, 0, NOW());

INSERT INTO Tournament (name, category, start_date, end_date, created_at) VALUES
('Товарищеский', 'Юношеский', '2024-11-20', '2024-11-21', NOW());

INSERT INTO Match (home_team_id, away_team_id, tournament_id, date, result, created_at) VALUES
(3, 4, 1, '2024-11-20', 'Хозяева 2:3 Гости', NOW());

INSERT INTO PlayerMatch (player_id, match_id, points, assists, blocks, aces) VALUES 
(1, 1, 12, 1, 2, 0),
(2, 1, 12, 1, 2, 0),
(3, 1, 5, 0, 3, 0),
(4, 1, 13, 1, 2, 0),
(5, 1, 11, 1, 2, 2),
(6, 1, 12, 1, 5, 0),
(7, 1, 12, 1, 2, 0),
(8, 1, 12, 1, 2, 0),
(9, 1, 12, 1, 2, 0),
(10, 1, 12, 1, 2, 0),
(11, 1, 12, 1, 2, 0),
(12, 1, 12, 1, 2, 0),
(13, 1, 12, 1, 2, 0),
(14, 1, 12, 1, 2, 0);

UPDATE PlayerMatch 
SET points = 0,
	assists = 0,
	blocks = 0,
	aces = 0;

INSERT INTO PlayerStatistics (player_id) VALUES
(1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12), (13), (14);

INSERT INTO ActionLog (user_id, action_type) VALUES 
(3, 'вход'),
(7, 'вход'),
(6, 'вход'),
(12, 'вход'),
(2, 'вход');

INSERT INTO ActionLog (user_id, action_type) VALUES 
(3, 'выход'),
(7, 'выход'),
(6, 'выход'),
(12, 'выход'),
(2, 'выход');

UPDATE Player
SET points = 13, assists = 7, blocks = 15, aces = 1
WHERE user_id = 2 AND points = 0 AND assists = 0 AND blocks = 0 AND aces = 0;

UPDATE Player
SET points = 11, assists = 6, blocks = 11, aces = 0
WHERE user_id = 3 AND points = 0 AND assists = 0 AND blocks = 0 AND aces = 0;

UPDATE Player
SET points = 0, assists = 7, blocks = 14, aces = 12
WHERE user_id = 4 AND points = 0 AND assists = 0 AND blocks = 0 AND aces = 0;

UPDATE Player
SET points = 14, assists = 0, blocks = 13, aces = 9
WHERE user_id = 5 AND points = 0 AND assists = 0 AND blocks = 0 AND aces = 0;

UPDATE Player
SET points = 11, assists = 0, blocks = 6, aces = 5
WHERE user_id = 6 AND points = 0 AND assists = 0 AND blocks = 0 AND aces = 0;

UPDATE Player
SET points = 8, assists = 14, blocks = 15, aces = 13
WHERE user_id = 7 AND points = 0 AND assists = 0 AND blocks = 0 AND aces = 0;

UPDATE Player
SET points = 1, assists = 14, blocks = 7, aces = 9
WHERE user_id = 17 AND points = 0 AND assists = 0 AND blocks = 0 AND aces = 0;

UPDATE Player
SET points = 15, assists = 0, blocks = 5, aces = 5
WHERE user_id = 9 AND points = 0 AND assists = 0 AND blocks = 0 AND aces = 0;

UPDATE Player
SET points = 0, assists = 13, blocks = 0, aces = 12
WHERE user_id = 10 AND points = 0 AND assists = 0 AND blocks = 0 AND aces = 0;

UPDATE Player
SET points = 8, assists = 1, blocks = 15, aces = 7
WHERE user_id = 11 AND points = 0 AND assists = 0 AND blocks = 0 AND aces = 0;

UPDATE Player
SET points = 4, assists = 4, blocks = 4, aces = 7
WHERE user_id = 12 AND points = 0 AND assists = 0 AND blocks = 0 AND aces = 0;

UPDATE Player
SET points = 2, assists = 11, blocks = 5, aces = 6
WHERE user_id = 13 AND points = 0 AND assists = 0 AND blocks = 0 AND aces = 0;

UPDATE Player
SET points = 1, assists = 4, blocks = 1, aces = 12
WHERE user_id = 14 AND points = 0 AND assists = 0 AND blocks = 0 AND aces = 0;

UPDATE Player
SET points = 13, assists = 3, blocks = 12, aces = 12
WHERE user_id = 18 AND points = 0 AND assists = 0 AND blocks = 0 AND aces = 0;


UPDATE PlayerStatistics
SET points_scored = Player.points,
    assists = Player.assists,
    blocks = Player.blocks,
    aces = Player.aces,
	matches_played = 1
FROM Player
WHERE PlayerStatistics.player_id = Player.id;

UPDATE PlayerMatch
SET points = Player.points,
    assists = Player.assists,
    blocks = Player.blocks,
    aces = Player.aces
FROM Player
WHERE PlayerMatch.player_id = Player.id;


CREATE UNIQUE INDEX idx_user_email ON "User"(email);
CREATE INDEX idx_player_team_id ON Player(team_id);
CREATE INDEX idx_player_jersey_number ON Player(jersey_number);
CREATE INDEX idx_player_statistics_player_id ON PlayerStatistics(player_id);
CREATE INDEX idx_tournament_start_date ON Tournament(start_date);

INSERT INTO "User" (email, password, role_id, created_at) VALUES 
('coach3@gmail.com', 'coachpass3', 2, NOW());


ALTER TABLE player
DROP CONSTRAINT player_team_id_fkey;

ALTER TABLE player
ADD CONSTRAINT player_team_id_fkey FOREIGN KEY (team_id) REFERENCES team(id) ON DELETE SET NULL;

ALTER TABLE Match
DROP CONSTRAINT match_home_team_id_fkey,
DROP CONSTRAINT match_away_team_id_fkey;

ALTER TABLE Match
ADD CONSTRAINT match_home_team_id_fkey FOREIGN KEY (home_team_id) REFERENCES Team(id) ON DELETE SET NULL;

ALTER TABLE Match
ADD CONSTRAINT match_away_team_id_fkey FOREIGN KEY (away_team_id) REFERENCES Team(id) ON DELETE SET NULL;

ALTER TABLE Player
DROP COLUMN points,
DROP COLUMN assists,
DROP COLUMN blocks,
DROP COLUMN aces;

ALTER TABLE PlayerStatistics
ADD COLUMN attacks INT DEFAULT 0;


ALTER TABLE PlayerMatch
ADD COLUMN attacks INT DEFAULT 0;

ALTER TABLE PlayerStatistics RENAME COLUMN points_scored TO points;
