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



/*
2. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".
*/
DROP FUNCTION IF EXISTS hello; 
DELIMITER $$
CREATE FUNCTION hello() 
	RETURNS VARCHAR(25)
	DETERMINISTIC
BEGIN
DECLARE result_text VARCHAR(25);
SELECT CASE 
	WHEN CURRENT_TIME >= '12:00:00' AND  CURRENT_TIME < '18:00:00' THEN 'Добрый день'
	WHEN CURRENT_TIME >= '06:00:00' AND  CURRENT_TIME < '12:00:00' THEN 'Доброе утро'
	WHEN CURRENT_TIME >= '00:00:00' AND  CURRENT_TIME < '06:00:00' THEN 'Доброй ночи'
	ELSE 'Добрый вечер'
END INTO result_text;
RETURN result_text;
END$$

DELIMITER ;

SELECT hello(); -- Проверяем.


-- Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, communities и messages в таблицу logs помещается время и дата создания записи, название таблицы, идентификатор первичного ключа.

CREATE TABLE logs (
  table_name VARCHAR(20) NOT NULL,
  pk_id INT UNSIGNED NOT NULL,
  name VARCHAR(255),
  created_at DATETIME DEFAULT NOW()
) ENGINE=ARCHIVE;

CREATE TRIGGER users_log AFTER INSERT ON users FOR EACH ROW
  INSERT INTO logs 
    SET 
      table_name = 'users',
      pk_id = NEW.id;

CREATE TRIGGER communities_log AFTER INSERT ON communities FOR EACH ROW
  INSERT INTO logs 
    SET 
      table_name = 'catalogs',
      pk_id = NEW.id;

CREATE TRIGGER messages_log AFTER INSERT ON messages FOR EACH ROW
  INSERT INTO logs 
    SET 
      table_name = 'products',
      pk_id = NEW.id;