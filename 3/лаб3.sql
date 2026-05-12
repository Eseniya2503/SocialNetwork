/*
Created: 29.04.2026
Modified: 12.05.2026
Model: SocialNetwork
Database: MS SQL Server 2019
*/

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = N'SocialNetwork')
BEGIN
    ALTER DATABASE SocialNetwork SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SocialNetwork;
END;
GO

CREATE DATABASE SocialNetwork;
GO

USE SocialNetwork;
GO

CREATE TABLE Users (
    id INT NOT NULL PRIMARY KEY,
    name NVARCHAR(50) NOT NULL
) AS NODE;

CREATE TABLE Groups (
    id INT NOT NULL PRIMARY KEY,
    title NVARCHAR(100) NOT NULL
) AS NODE;

CREATE TABLE Interests (
    id INT NOT NULL PRIMARY KEY,
    name NVARCHAR(50) NOT NULL
) AS NODE;

CREATE TABLE Friends (
    since_date DATE, 
    trust_level INT
) AS EDGE;

CREATE TABLE Subscribed (
    sub_date DATE, 
    is_muted BIT
) AS EDGE;

CREATE TABLE Blacklist (
    reason NVARCHAR(100), 
    ban_date DATETIME DEFAULT GETDATE()
) AS EDGE;

CREATE TABLE GroupTopic (relevance_weight INT) AS EDGE;

ALTER TABLE Friends 
ADD CONSTRAINT EC_Friends CONNECTION (Users TO Users); 

ALTER TABLE Subscribed 
ADD CONSTRAINT EC_Subscribed CONNECTION (Users TO Groups);

ALTER TABLE Blacklist 
ADD CONSTRAINT EC_Blacklist CONNECTION (Users TO Users, Groups TO Users);

ALTER TABLE GroupTopic 
ADD CONSTRAINT EC_GroupTopic CONNECTION (Groups TO Interests);
GO

INSERT INTO Users (id, name) VALUES
(1, N'Eseniya'), 
(2, N'Alex'), 
(3, N'Daria'),
(4, N'Max'),
(5, N'Lewis'),
(6, N'Charles'),
(7, N'Ivan'),
(8, N'Elena'),
(9, N'Pavel'),
(10, N'Kimi');

INSERT INTO Groups (id, title) VALUES
(1, N'Formula 1 News'), 
(2, N'Swift iOS Club'), 
(3, N'PHP & Backend'),
(4, N'Типичный Минск'), 
(5, N'Верстка и Шрифты'), 
(6, N'Scuderia Ferrari'),
(7, N'Группа №9 БГУ'), 
(8, N'Web Design 2026'), 
(9, N'Node.js Community'), 
(10, N'Coastal Living');

INSERT INTO Interests (id, name) VALUES
(1, N'Formula 1'), 
(2, N'iOS Dev'), 
(3, N'Типографика'), 
(4, N'PostgreSQL'), 
(5, N'Романы'),
(6, N'Фотография'), 
(7, N'Ходьба'), 
(8, N'Путешествия'), 
(9, N'UI/UX'), 
(10, N'Музыка');
GO

INSERT INTO Friends ($from_id, $to_id, since_date, trust_level) VALUES
((SELECT $node_id FROM Users WHERE id = 1), (SELECT $node_id FROM Users WHERE id = 2), '2026-01-01', 10),
((SELECT $node_id FROM Users WHERE id = 2), (SELECT $node_id FROM Users WHERE id = 7), '2026-01-05', 9),
((SELECT $node_id FROM Users WHERE id = 10), (SELECT $node_id FROM Users WHERE id = 3), '2026-02-10', 8),
((SELECT $node_id FROM Users WHERE id = 1), (SELECT $node_id FROM Users WHERE id = 3), '2026-01-15', 7),
((SELECT $node_id FROM Users WHERE id = 4), (SELECT $node_id FROM Users WHERE id = 6), '2026-03-01', 9),
((SELECT $node_id FROM Users WHERE id = 5), (SELECT $node_id FROM Users WHERE id = 6), '2026-03-20', 10),
((SELECT $node_id FROM Users WHERE id = 8), (SELECT $node_id FROM Users WHERE id = 9), '2026-04-01', 8),
((SELECT $node_id FROM Users WHERE id = 9), (SELECT $node_id FROM Users WHERE id = 7), '2026-04-10', 6),
((SELECT $node_id FROM Users WHERE id = 10), (SELECT $node_id FROM Users WHERE id = 5), '2026-01-01', 10),
((SELECT $node_id FROM Users WHERE id = 4), (SELECT $node_id FROM Users WHERE id = 5), '2026-02-01', 7);

INSERT INTO Subscribed ($from_id, $to_id, sub_date) VALUES
((SELECT $node_id FROM Users WHERE id = 1), (SELECT $node_id FROM Groups WHERE id = 1), '2026-05-01'),
((SELECT $node_id FROM Users WHERE id = 2), (SELECT $node_id FROM Groups WHERE id = 1), '2026-05-01'),
((SELECT $node_id FROM Users WHERE id = 2), (SELECT $node_id FROM Groups WHERE id = 2), '2026-05-01'),
((SELECT $node_id FROM Users WHERE id = 6), (SELECT $node_id FROM Groups WHERE id = 6), '2026-04-01'),
((SELECT $node_id FROM Users WHERE id = 10), (SELECT $node_id FROM Groups WHERE id = 3), '2026-05-02'),
((SELECT $node_id FROM Users WHERE id = 3), (SELECT $node_id FROM Groups WHERE id = 7), '2026-03-01'),
((SELECT $node_id FROM Users WHERE id = 4), (SELECT $node_id FROM Groups WHERE id = 1), '2026-01-01'),
((SELECT $node_id FROM Users WHERE id = 5), (SELECT $node_id FROM Groups WHERE id = 10), '2026-04-01'),
((SELECT $node_id FROM Users WHERE id = 7), (SELECT $node_id FROM Groups WHERE id = 9), '2026-05-05'),
((SELECT $node_id FROM Users WHERE id = 8), (SELECT $node_id FROM Groups WHERE id = 5), '2026-02-01'),
((SELECT $node_id FROM Users WHERE id = 9), (SELECT $node_id FROM Groups WHERE id = 4), '2026-05-10');

INSERT INTO GroupTopic ($from_id, $to_id, relevance_weight) VALUES
((SELECT $node_id FROM Groups WHERE id = 1), (SELECT $node_id FROM Interests WHERE id = 1), 100),
((SELECT $node_id FROM Groups WHERE id = 6), (SELECT $node_id FROM Interests WHERE id = 1), 95),
((SELECT $node_id FROM Groups WHERE id = 2), (SELECT $node_id FROM Interests WHERE id = 2), 100),
((SELECT $node_id FROM Groups WHERE id = 9), (SELECT $node_id FROM Interests WHERE id = 4), 90),
((SELECT $node_id FROM Groups WHERE id = 5), (SELECT $node_id FROM Interests WHERE id = 3), 100),
((SELECT $node_id FROM Groups WHERE id = 8), (SELECT $node_id FROM Interests WHERE id = 5), 85),
((SELECT $node_id FROM Groups WHERE id = 7), (SELECT $node_id FROM Interests WHERE id = 9), 60),
((SELECT $node_id FROM Groups WHERE id = 3), (SELECT $node_id FROM Interests WHERE id = 7), 100),
((SELECT $node_id FROM Groups WHERE id = 10), (SELECT $node_id FROM Interests WHERE id = 8), 100),
((SELECT $node_id FROM Groups WHERE id = 4), (SELECT $node_id FROM Interests WHERE id = 10), 30),
((SELECT $node_id FROM Groups WHERE id = 5), (SELECT $node_id FROM Interests WHERE id = 6), 100);

INSERT INTO Blacklist ($from_id, $to_id, reason) VALUES
((SELECT $node_id FROM Groups WHERE id = 2), (SELECT $node_id FROM Users WHERE id = 7), N'Оффтоп'),
((SELECT $node_id FROM Users WHERE id = 10), (SELECT $node_id FROM Users WHERE id = 9), N'Спам'),
((SELECT $node_id FROM Groups WHERE id = 1), (SELECT $node_id FROM Users WHERE id = 5), N'Флуд'),
((SELECT $node_id FROM Users WHERE id = 1), (SELECT $node_id FROM Users WHERE id = 10), N'Токсичность'),
((SELECT $node_id FROM Groups WHERE id = 7), (SELECT $node_id FROM Users WHERE id = 4), N'Нарушение правил'),
((SELECT $node_id FROM Users WHERE id = 2), (SELECT $node_id FROM Users WHERE id = 3), N'Конфликт'),
((SELECT $node_id FROM Groups WHERE id = 8), (SELECT $node_id FROM Users WHERE id = 8), N'Реклама'),
((SELECT $node_id FROM Users WHERE id = 4), (SELECT $node_id FROM Users WHERE id = 1), N'Игнор'),
((SELECT $node_id FROM Groups WHERE id = 6), (SELECT $node_id FROM Users WHERE id = 9), N'Спойлеры'),
((SELECT $node_id FROM Users WHERE id = 3), (SELECT $node_id FROM Users WHERE id = 5), N'Ссора');
GO

-- 1. Интересы Есении через цепочку Пользователь -> Группа -> Интерес
SELECT U.name, G.title, I.name AS Interest
FROM Users AS U, Subscribed AS S, Groups AS G, GroupTopic AS T, Interests AS I
WHERE MATCH(U-(S)->G-(T)->I) 
AND U.name = N'Eseniya';

-- 2. Друзья Есении, состоящие в группе "Formula 1 News"
SELECT U1.name AS Me, U2.name AS Friend, G.title
FROM Users AS U1, Friends AS F, Users AS U2, Subscribed AS S, Groups AS G
WHERE MATCH(U1-(F)->U2-(S)->G) 
AND G.title = N'Formula 1 News' 
AND U1.name = N'Eseniya';

-- 3. Пользователи, которых забанили в группах, где состоит Charles
SELECT G.title AS GroupName, Banned.name AS BannedUser, B.reason
FROM Users AS U, Subscribed AS S, Groups AS G, Blacklist AS B, Users AS Banned
WHERE MATCH(U-(S)->G-(B)->Banned) 
AND U.name = N'Charles';

-- 4. Друзья друзей 
SELECT U1.name AS UserA, U2.name AS UserB, U3.name AS UserC
FROM Users AS U1, Friends AS F1, Users AS U2, Friends AS F2, Users AS U3
WHERE MATCH(U1-(F1)->U2-(F2)->U3) 
AND U1.id <> U3.id;

-- 5. Общие темы интересов друзей Есении
SELECT DISTINCT U1.name AS Me, U2.name AS Friend, I.name AS CommonInterest
FROM Users AS U1, Friends AS F, Users AS U2, Subscribed AS S, Groups AS G, GroupTopic AS T, Interests AS I
WHERE MATCH(U1-(F)->U2-(S)->G-(T)->I) 
AND U1.name = N'Eseniya';
GO

-- 6. Кратчайший путь от Есении до Макса 
SELECT 
    U1.name AS [Начало],
    STRING_AGG(U2.name, ' -> ') WITHIN GROUP (GRAPH PATH) AS [Цепочка друзей]
FROM Users AS U1, Friends FOR PATH AS F, Users FOR PATH AS U2
WHERE MATCH(SHORTEST_PATH(U1(-(F)->U2){1,3}))
AND U1.name = N'Eseniya' 
AND LAST_NODE(U2.name) = N'Max';
GO

-- 7. Любой путь от пользователя до интереса через подписки 
SELECT 
    U.name AS [Пользователь],
    STRING_AGG(Target.name, ' -> ') WITHIN GROUP (GRAPH PATH) AS [Путь к интересу]
FROM Users AS U, Subscribed FOR PATH AS S, Groups FOR PATH AS G, 
     GroupTopic FOR PATH AS T, Interests FOR PATH AS Target
WHERE MATCH(SHORTEST_PATH(U(-(S)->G-(T)->Target)+))
AND U.name = N'Eseniya';
GO