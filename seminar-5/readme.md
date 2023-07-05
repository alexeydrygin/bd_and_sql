# Базы данных и SQL (семинары)
## Урок 5. SQL – оконные функции

**Для решения задач используйте базу данных lesson_4
(скрипт создания, прикреплен к 4 семинару).**

1. Создайте представление, в которое попадет информация о пользователях (имя, фамилия, город и пол), которые не старше 20 лет.
2. Найдите кол-во, отправленных сообщений каждым пользователем и выведите ранжированный список пользователь, указав указать имя и фамилию пользователя, количество отправленных сообщений и место в рейтинге (первое место у пользователя с максимальным количеством сообщений) . (используйте DENSE_RANK)
3. Выберите все сообщения, отсортируйте сообщения по возрастанию даты отправления (created_at) и найдите разницу дат отправления между соседними сообщениями, получившегося списка. (используйте LEAD или LAG)

---

1. **Создайте представление, в которое попадет информация о пользователях (имя, фамилия, город и пол), которые не старше 20 лет.**

```sql
USE lesson_4;

/*
Создайте представление, в которое попадет информация о пользователях (имя, фамилия, город и пол), которые не старше 20 лет.
*/

CREATE OR REPLACE VIEW view_user AS 
SELECT CONCAT(firstname, ' ', lastname, '; ', hometown, '; ', gender) AS 'Пользователи (младше 20 лет)'
FROM users u
JOIN profiles p ON u.id = p.user_id
WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 20
GROUP BY u.id
;

SELECT * FROM view_user;
-- DROP VIEW view_user;
```

|Пользователи (младше 20 лет)|
|----------------------------|
|Frederik Upton; North Nettieton; f|
|Austyn Braun; South Jeffereyshire; m|

---

2. **Найдите кол-во, отправленных сообщений каждым пользователем и выведите ранжированный список пользователь, указав указать имя и фамилию пользователя, количество отправленных сообщений и место в рейтинге (первое место у пользователя с максимальным количеством сообщений) . (используйте DENSE_RANK)**

```sql
/*
Найдите кол-во, отправленных сообщений каждым пользователем и выведите ранжированный список пользователь, 
указав имя и фамилию пользователя, количество отправленных сообщений и место в рейтинге 
(первое место у пользователя с максимальным количеством сообщений) . (используйте DENSE_RANK)
*/

SELECT 
	DENSE_RANK() OVER (ORDER BY COUNT(from_user_id) DESC) AS 'Место в рейтинге',
	COUNT(from_user_id) AS 'Количество отправленных сообщений',
	CONCAT(firstname, ' ', lastname) AS 'Пользователи'
FROM users u
JOIN messages m ON u.id = m.from_user_id
GROUP BY u.id
;
```

|Место в рейтинге|Количество отправленных сообщений|Пользователи|
|----------------|---------------------------------|------------|
|1	|7	|Jaida Kilback|
|2	|4	|Reuben Nienow|
|2	|4	|Norene West|
|3	|2	|Frederik Upton|
|4	|1	|Unique Windler|
|4	|1	|Mireya Orn|
|4	|1	|Jordyn Jerde|

---

3. **Выберите все сообщения, отсортируйте сообщения по возрастанию даты отправления (created_at) и найдите разницу дат отправления между соседними сообщениями, получившегося списка. (используйте LEAD или LAG)**

```sql
/*
Выберите все сообщения, отсортируйте сообщения по возрастанию даты отправления (created_at) 
и найдите разницу дат отправления между соседними сообщениями, получившегося списка. (используйте LEAD или LAG)
*/

SELECT *, 
LAG(created_at, 1, 0) OVER (PARTITION BY TIMESTAMPDIFF(SECOND, created_at, created_at)) AS lag_created_at, -- смещение на 1 и вместо NULL будет 0
LEAD(created_at) OVER (PARTITION BY TIMESTAMPDIFF(SECOND, created_at, created_at)) AS lead_created_at
FROM messages ORDER BY TIMESTAMPDIFF(SECOND, created_at, NOW()) DESC;
```

|id|from_user_id|to_user_id|body|created_at|lag_created_at|lead_created_at|
|--|--|--|----------------------|----------|--------------|---------------|
|1|1|2|Voluptatem ut quaerat quia. Pariatur esse amet ratione qui quia. In necessitatibus reprehenderit et. Nam accusantium aut qui quae nesciunt non.|2023-07-05 22:09:12|0|2023-07-05 22:11:12|
|2|2|1|Sint dolores et debitis est ducimus. Aut et quia beatae minus. Ipsa rerum totam modi sunt sed. Voluptas atque eum et odio ea molestias ipsam architecto.|2023-07-05 22:11:12|2023-07-05 22:09:12|2023-07-05 22:13:12|
|3|3|1|Sed mollitia quo sequi nisi est tenetur at rerum. Sed quibusdam illo ea facilis nemo sequi. Et tempora repudiandae saepe quo.|2023-07-05 22:13:12|2023-07-05 22:11:12|2023-07-05 22:19:12|
|4|4|1|Quod dicta omnis placeat id et officiis et. Beatae enim aut aliquid neque occaecati odit. Facere eum distinctio assumenda omnis est delectus magnam.|2023-07-05 22:19:12|2023-07-05 22:13:12|2023-07-05 22:20:12|
|5|1|5|Voluptas omnis enim quia porro debitis facilis eaque ut. Id inventore non corrupti doloremque consequuntur. Molestiae molestiae deleniti exercitationem sunt qui ea accusamus deserunt.|2023-07-05 22:20:12|2023-07-05 22:19:12|2023-07-05 22:22:12|
|6|1|6|Rerum labore culpa et laboriosam eum totam. Quidem pariatur sit alias. Atque doloribus ratione eum rem dolor vitae saepe.|2023-07-05 22:22:12	|2023-07-05 22:20:12|2023-07-05 22:23:12|
|7|1|7|Perspiciatis temporibus doloribus debitis. Et inventore labore eos modi. Quo temporibus corporis minus. Accusamus aspernatur nihil nobis placeat molestiae et commodi eaque.|2023-07-05 22:23:12|2023-07-05 22:22:12|2023-07-05 22:29:12|
|8|8|1|Suscipit dolore voluptas et sit vero et sint. Rem ut ratione voluptatum assumenda nesciunt ea. Quas qui qui atque ut. Similique et praesentium non voluptate iure. Eum aperiam officia quia dolorem.|2023-07-05 22:29:12|2023-07-05 22:23:12|2023-07-05 22:30:12|
|9|9|3|	Et quia libero aut vitae minus. Rerum a blanditiis debitis sit nam. Veniam quasi aut autem ratione dolorem. Sunt quo similique dolorem odit totam sint sed.|	2023-07-05 22:30:12|	2023-07-05 22:29:12|	2023-07-05 22:33:12|
|10|	10|	2|	Praesentium molestias quia aut odio. Est quis eius ut animi optio molestiae. Amet tempore sequi blanditiis in est.	|2023-07-05 22:33:12	|2023-07-05 22:30:12	|2023-07-05 22:35:12|
|11	|8	|3	|Molestiae laudantium quibusdam porro est alias placeat assumenda. Ut consequatur rerum officiis exercitationem eveniet. Qui eum maxime sed in.	|2023-07-05 22:35:12	|2023-07-05 22:33:12	|2023-07-05 22:36:12|
|12	|8	|1	|Quo asperiores et id veritatis placeat. Aperiam ut sit exercitationem iste vel nisi fugit quia. Suscipit labore error ducimus quaerat distinctio quae quasi.	|2023-07-05 22:36:12	|2023-07-05 22:35:12	|2023-07-05 22:41:12|
|13	|8	|1	|Earum sunt quia sed harum modi accusamus. Quia dolor laboriosam asperiores aliquam quia. Sint id quasi et cumque qui minima ut quo. Autem sed laudantium officiis sit sit.	|2023-07-05 22:41:12	|2023-07-05 22:36:12	|2023-07-05 22:43:12|
|14	|4	|1	|Aut enim sint voluptas saepe. Ut tenetur quos rem earum sint inventore fugiat. Eaque recusandae similique earum laborum.	|2023-07-05 22:43:12	|2023-07-05 22:41:12	|2023-07-05 22:43:12|
|15	|4	|1	|Nisi rerum officiis officiis aut ad voluptates autem. Dolor nesciunt eum qui eos dignissimos culpa iste. Atque qui vitae quos odit inventore eum. Quam et voluptas quia amet.	|2023-07-05 22:43:12	|2023-07-05 22:43:12	|2023-07-05 22:45:12|
|16	|4	|1	|Consequatur ut et repellat non voluptatem nihil veritatis. Vel deleniti omnis et consequuntur. Et doloribus reprehenderit sed earum quas velit labore.	|2023-07-05 22:45:12	|2023-07-05 22:43:12	|2023-07-05 22:45:12|
|17	|2	|1	|Iste deserunt in et et. Corrupti rerum a veritatis harum. Ratione consequatur est ut deserunt dolores.	|2023-07-05 22:45:12	|2023-07-05 22:45:12	|2023-07-05 22:49:12|
|18	|8	|1	|Dicta non inventore autem incidunt accusamus amet distinctio. Aut laborum nam ab maxime. Maxime minima blanditiis et neque. Et laboriosam qui at deserunt magnam.	|2023-07-05 22:49:12	|2023-07-05 22:45:12	|2023-07-05 22:50:12|
|19	|8	|1	|Amet ad dolorum distinctio excepturi possimus quia. Adipisci veniam porro ipsum ipsum tempora est blanditiis. Magni ut quia eius qui.	|2023-07-05 22:50:12	|2023-07-05 22:49:12	|2023-07-05 22:58:12|
|20	|8	|1	|Porro aperiam voluptate quo eos nobis. Qui blanditiis cum id eos. Est sit reprehenderit consequatur eum corporis. Molestias quia quo sit architecto aut.	|2023-07-05 22:58:12	|2023-07-05 22:50:12| NULL|	
