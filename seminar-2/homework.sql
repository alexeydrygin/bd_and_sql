/*
Task 1. Используя операторы языка SQL, создайте табличку “sales”. Заполните ее данными.
*/

-- Проверяем наличие уже существующей БД с таким же названием, если имеется - удаляем и создаем заново:
DROP DATABASE IF EXISTS lesson_2;
CREATE DATABASE lesson_2;
USE lesson_2;
-- Проверяем наличие уже существующей сущности с таким же названием, если имеется - удаляем и создаем заново с указанными полями:
DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
	order_date DATE,
	count_product INT DEFAULT '0'
);
-- Наполняем сущность 'sales' данными:
INSERT INTO `sales` (order_date, count_product)
VALUES 
('2022-01-01', 156),
('2022-01-02', 180),
('2022-01-03', 21),
('2022-01-04', 124),
('2022-01-05', 341);


/*
Task 2. Для данных таблицы “sales” укажите тип заказа в зависимости от кол-ва : 
меньше 100 - Маленький заказ; от 100 до 300 - Средний заказ; больше 300 - Большой заказ.
*/

-- Создаем условие отбора с указанной маской 'Тип заказа':
SELECT 
	id AS 'id заказа',
	IF (count_product < 100, 'Маленький заказ', 
		IF (count_product BETWEEN 100 AND 300, 'Средний заказ', 'Большой заказ')
	) AS 'Тип заказа'	
FROM sales;


/*
Task 3. Создайте таблицу “orders”, заполните ее значениями. Выберите все заказы. 
В зависимости от поля order_status выведите столбец full_order_status: OPEN – «Order is in open state» ; 
CLOSED - «Order is closed»; CANCELLED - «Order is cancelled»
*/

-- Проверяем наличие уже существующей сущности с таким же названием, если имеется - удаляем и создаем заново с указанными полями:
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
	employee_id VARCHAR(5) NOT NULL UNIQUE DEFAULT 'e00',
	amount FLOAT(7,2) NOT NULL DEFAULT '0.00',
    order_status VARCHAR(15) NOT NULL DEFAULT 'OPEN'
);
-- Наполняем сущность 'orders' данными:
INSERT INTO `orders` (employee_id, amount, order_status)
VALUES 
('e03', 15.00, 'OPEN'),
('e01', 25.50, 'OPEN'),
('e05', 100.70, 'CLOSED'),
('e02', 22.18, 'OPEN'),
('e04', 9.50, 'CANCELLED');
-- Создаем кейс для показа отдельной колонки 'full_order_status' с интересующими нас условиями отбора и заменой маски значений:
SELECT 
	employee_id AS 'Номер заказа',
	amount AS 'Сумма заказа',
    CASE order_status 
		WHEN 'OPEN' THEN 'Order is in open state'
		WHEN 'CLOSED' THEN 'Order is closed'
		WHEN 'CANCELLED' THEN 'Order is cancelled'
	END AS 'full_order_status'	
FROM orders;


/*
Task 4. Чем 0 отличается от NULL?
*/

-- NULL это отсутсвие значений в ячейке, а 0 это цифра, т.е. значение (с которым можно производить математические вычисления).