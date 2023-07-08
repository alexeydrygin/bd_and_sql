
/* 
- Хранимые процедуры
- Пользовательские функции
- Транзакции
- Циклы
- Триггеры
*/
-- используем БД, созданную в lesson_4 
USE lesson_4;

-- ТРАНЗАКЦИИ 

START TRANSACTION;

INSERT INTO users (firstname, lastname, email)
VALUES ('Дмитрий', 'Дмитриев', 'dima@mail.ru');
	
SET @last_user_id = last_insert_id();
	
INSERT INTO profiles (user_id, hometown, birthday, photo_id)
VALUES (@last_user_id, 'Moscow', '1999-10-10', NULL);

COMMIT;
-- ROLLBACK;

-- ПРОЦЕДУРЫ
-- создание процедуры для добавления нового пользователя с профилем c определение COMMIT или ROLLBACK 
DROP PROCEDURE IF EXISTS sp_user_add;
DELIMITER //
CREATE PROCEDURE sp_user_add(
firstname varchar(100), lastname varchar(100), email varchar(100), 
phone varchar(100), hometown varchar(50), photo_id INT, birthday DATE,
OUT  tran_result varchar(100))
BEGIN
	
	DECLARE `_rollback` BIT DEFAULT b'0';
	DECLARE code varchar(100);
	DECLARE error_string varchar(100); 

	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
	BEGIN
 		SET `_rollback` = b'1';
 		GET stacked DIAGNOSTICS CONDITION 1
			code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
	END;

	START TRANSACTION;
	 INSERT INTO users (firstname, lastname, email)
	 VALUES (firstname, lastname, email);
	-- SET @last_user_id = last_insert_id();
	 INSERT INTO profiles (user_id, hometown, birthday, photo_id)
	 VALUES (last_insert_id(), hometown, birthday, photo_id);
	
	IF `_rollback` THEN
		SET tran_result = CONCAT('УПС. Ошибка: ', code, ' Текст ошибки: ', error_string);
		ROLLBACK;
	ELSE
		SET tran_result = 'O K';
		COMMIT;
	END IF;
END//
DELIMITER ;

-- вызов процедуры
CALL sp_user_add('New', 'User', 'new_user1@mail.com', 9110001122, 'Moscow', -1, '1998-01-01', @tran_result); 
SELECT @tran_result;


/* создание процедуры, которая решает следующую задачу
Выбрать для одного пользователя 5 пользователей в случайной комбинации, которые удовлетворяют хотя бы одному критерию:
1)	из одного города
2)	состоят в одной группе
3)	друзья друзей
*/

-- обновим данные в базе, чтобы появились пользователи из одного города
UPDATE profiles
SET hometown = 'Adriannaport'
WHERE birthday < '1990-01-01';


-- создание процедуры
DROP PROCEDURE IF EXISTS sp_friendship_offers;
DELIMITER //
CREATE PROCEDURE sp_friendship_offers(for_user_id BIGINT)
BEGIN
-- друзья
WITH friends AS (
	SELECT initiator_user_id AS id
    FROM friend_requests
    WHERE status = 'approved' AND target_user_id = for_user_id 
    UNION
    SELECT target_user_id 
    FROM friend_requests
    WHERE status = 'approved' AND initiator_user_id = for_user_id 
)
-- общий город
	SELECT p2.user_id
	FROM profiles p1
	JOIN profiles p2 ON p1.hometown = p2.hometown 
	WHERE p1.user_id = for_user_id AND p2.user_id <> for_user_id
    UNION 
-- состоят в одной группе
	SELECT uc2.user_id 
	FROM users_communities uc1
	JOIN users_communities uc2 ON uc1.community_id = uc2.community_id 
	WHERE uc1.user_id = for_user_id AND uc2.user_id <> for_user_id
-- друзья друзей
    UNION
	SELECT fr.initiator_user_id
    	FROM friends f
        JOIN friend_requests fr ON fr.target_user_id = f.id
	WHERE fr.initiator_user_id != for_user_id  AND fr.status = 'approved'
    UNION
    	SELECT fr.target_user_id
    	FROM  friends f
        JOIN  friend_requests fr ON fr.initiator_user_id = f.id 
	WHERE fr.target_user_id != for_user_id  AND status = 'approved'
	ORDER BY rand()
	LIMIT 5;
	
END//

DELIMITER ;

-- вызов процедуры
CALL sp_friendship_offers(1);

-- ФУНКЦИИ
-- создание функции, вычисляющей коэффициент популярности пользователя
DROP FUNCTION IF EXISTS friendship_direction;
DELIMITER //
CREATE FUNCTION friendship_direction(check_user_id BIGINT)
RETURNS FLOAT READS SQL DATA 
BEGIN
	DECLARE requests_to_user INT; -- заявок к пользователю
	DECLARE requests_from_user INT; -- заявок от пользователя

	SET requests_to_user = (
		SELECT COUNT(*) 
		FROM friend_requests
		WHERE target_user_id = check_user_id 
		);
	/* 
	SET requests_from_user = (
	SELECT COUNT(*) 
	FROM friend_requests
	WHERE initiator_user_id = check_user_id 
	); */
	
	SELECT COUNT(*)
	INTO  requests_from_user
	FROM friend_requests
	WHERE initiator_user_id = check_user_id; 
	
	RETURN requests_to_user / requests_from_user;
END//
DELIMITER ;

-- вызов функции
SELECT friendship_direction(1);
SELECT truncate(friendship_direction(1), 2)*100 AS `user popularity`;


-- ЦИКЛЫ
ALTER TABLE `profiles`
ADD COLUMN time_update DATETIME ON UPDATE NOW(); 


DROP PROCEDURE IF EXISTS sp_data_analysis;
DELIMITER //
CREATE PROCEDURE sp_data_analysis(start_date DATE)
BEGIN
	DECLARE id_max_users INT;
	DECLARE count_find INT;
	
	SET id_max_users = (SELECT MAX(user_id) FROM profiles);
	WHILE (id_max_users > 0) DO
		BEGIN
			SET count_find = (SELECT COUNT(*) FROM profiles WHERE user_id = id_max_users AND birthday > start_date); 
			IF (count_find>0 )	THEN 
				UPDATE profiles
					SET birthday=NOW()
				WHERE user_id=id_max_users; 
			END IF;
	    	SET id_max_users = id_max_users - 1;
    	END;
  	END WHILE;
END//

DELIMITER ;

-- вызов процедуры
CALL sp_data_analysis('2000-01-01');

-- ТРИГГЕРЫ 
-- триггер для корректировки возраста пользователя при вставке новых строк
DROP TRIGGER if exists check_user_age_before_insert;
DELIMITER //
CREATE TRIGGER check_user_age_before_insert BEFORE INSERT ON profiles
FOR EACH ROW
BEGIN
    IF NEW.birthday > CURRENT_DATE() THEN
        SET NEW.birthday = CURRENT_DATE();
    END IF;
END//
DELIMITER ;

-- триггер для проверки возраста пользователя перед обновлением
DELIMITER //
CREATE TRIGGER check_user_age_before_update BEFORE UPDATE ON profiles
FOR EACH ROW
BEGIN
    IF NEW.birthday > NOW() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Обновление отменено. Дата рождения не может быть больше текущей даты!';
    END IF;
END//
DELIMITER ;

-- проверка работы триггеров
-- вывод всех пользователей
SELECT u.id, u.firstname, u. lastname, p.birthday FROM users u
INNER JOIN profiles p ON u.id=p.user_id
ORDER BY u.id DESC;

-- добавление нового пользователя
CALL sp_user_add('Иван', 'Диванов', 'ivan_2023@mail.ru', 9876543221, 'Moscow', NULL, '2030-01-01', @tran_result); 
CALL sp_user_add('Петр', 'Петров', 'retya_2023@mail.ru', 9876543222, 'Moscow', NULL, '2023-01-01', @tran_result); 


-- обновление данных 
UPDATE profiles 
SET birthday = '2030-01-01'
WHERE user_id = 10;

UPDATE profiles 
SET birthday = '2020-01-01'
WHERE user_id = 10;

/*
Создайте таблицу users_old, аналогичную таблице users. 
Создайте процедуру, с помощью которой можно переместить любого (одного) пользователя из таблицы users в таблицу users_old. 
(использование транзакции с выбором commit или rollback – обязательно).
*/
use lesson_4;
DROP TABLE IF EXISTS users_old;
CREATE TABLE users_old (
 id INT PRIMARY KEY auto_increment, 
 firstname varchar(50), 
 lastname varchar(50), 
 email varchar(100) UNIQUE
);

DELIMITER $$
DROP PROCEDURE IF EXISTS move;
CREATE PROCEDURE move (IN num1 INT) 
 DETERMINISTIC
BEGIN
INSERT INTO users_old (firstname,lastname,email) 
SELECT firstname, lastname, email 
	FROM users 
	WHERE users.id = num1;
DELETE FROM users 
	WHERE id = num1;
COMMIT;
END$$

DELIMITER ;

CALL move(4); -- Проверяем.