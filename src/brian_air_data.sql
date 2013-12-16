
/*
 +----+-----------+
 | id | name      |
 +----+-----------+
 |  1 | Smallby   |
 |  2 | Lillville |
 +----+-----------+
 (2 rows)
*/

INSERT INTO airport (name) VALUES
	('Smallby'),
	('Lillville');

/*
+----+-------+
| id | price |
+----+-------+
|  1 |   200 |
|  2 |   350 |
+----+-------+
(2 rows)
*/

INSERT INTO base_price (price) VALUES
	(200),
	(350);

/*
+----+---------+---------+-------+
| id | arrives | departs | price |
+----+---------+---------+-------+
|  1 |       1 |       2 |     1 |
|  2 |       2 |       1 |     2 |
+----+---------+---------+-------+
(2 rows)
*/

INSERT INTO route (arrives,departs,price) VALUES
	(1,	2,	1),
	(2,	1,	2);

/*
+----+-----------+
| id | name      |
+----+-----------+
|  1 | Monday    |
|  2 | Tuesday   |
|  3 | Wednesday |
|  4 | Thursday  |
|  5 | Friday    |
|  6 | Saturday  |
|  7 | Sunday    |
+----+-----------+
(7 rows)
*/

INSERT INTO weekday (name) VALUES
	('Monday'),
	('Tuesday'),
	('Wednesday'),
	('Thursday'),
	('Friday'),
	('Saturday'),
	('Sunday');

/*
+----+------+--------+---------+
| id | year | factor | weekday |
+----+------+--------+---------+
|  1 | 2013 |    1.4 |       1 |
|  2 | 2013 |    1.6 |       2 |
|  3 | 2013 |    2.4 |       3 |
|  4 | 2013 |    1.8 |       4 |
|  5 | 2013 |    1.8 |       5 |
|  6 | 2013 |    2.8 |       6 |
|  7 | 2013 |    1.8 |       7 |
|  8 | 2014 |    1.8 |       1 |
|  9 | 2014 |    1.8 |       2 |
| 10 | 2014 |    1.8 |       3 |
| 11 | 2014 |    1.8 |       4 |
| 12 | 2014 |    3.8 |       5 |
| 13 | 2014 |    2.8 |       6 |
| 14 | 2014 |    1.8 |       7 |
+----+------+--------+---------+
(14 rows)
*/

INSERT INTO weekday_factor (year,factor,weekday) VALUES
	(2013,	2, 1),
	(2013,	1, 2),
	(2013,	3, 3),
	(2013,	2, 4),
	(2013,	4, 5),
	(2013,	8, 6),
	(2013,	1, 7),
	(2014,	2, 1),
	(2014,	5, 2),
	(2014,	1, 3),
	(2014,	1, 4),
	(2014,	3, 5),
	(2014,	2, 6),
	(2014,	1, 7);

/*
+----+------+----------------+----------+-------+
| id | year | departure_time | flies_on | route |
+----+------+----------------+----------+-------+
|  1 | 2013 | 08:00:00       |        1 |     1 |
|  2 | 2013 | 15:00:00       |        2 |     2 |
|  3 | 2014 | 10:00:00       |        3 |     2 |
|  4 | 2014 | 18:00:00       |        5 |     1 |
+----+------+----------------+----------+-------+
(4 rows)
*/

INSERT INTO weekly_flight (year,departure_time, flies_on, route) VALUES
	(2013,	'08:00',	1,	1),
	(2013,	'15:00',	2,	2),
	(2014,	'10:00',	3,	2),
	(2014, 	'09:30',	5,	2),
	(2014,	'10:15',	5,	1),
	(2014,	'18:00',	5,	1);


/*
+------+--------+
| year | factor |
+------+--------+
| 2013 |   10.6 |
| 2014 |   17.1 |
+------+--------+
(2 rows)
*/

INSERT INTO passenger_factor VALUES
	(2013, 1),
	(2014, 2);

/*
+-------------+-------+------------+-------------+------+
| personal_id | title | first_name | last_name   | age  |
+-------------+-------+------------+-------------+------+
| 090301-6483 | Mr    | Justin     | Bieber      |    4 |
| 170312-2467 | Mr    | Leif       | G.W Persson |  204 |
| 400316-1354 | Mrs   | Rock       | Olga        |   70 |
| 570826-6385 | Dr    | Dr         | Alban       |   56 |
| 600510-6493 | Mr    | Bono       | Hewson      |   53 |
| 630327-7253 | Mr    | Quentin    | Tarantino   |   50 |
| 810217-8485 | Ms    | Paris      | Hilton      |   32 |
| 820927-2461 | Dawgh | Lil        | Wayne       |   31 |
+-------------+-------+------------+-------------+------+
(8 rows)
*/

INSERT INTO customer VALUES
	('810217-8485',	2,	'Paris',	'Hilton',		32),
	('600510-6493',	1,	'Bono',		'Hewson',		53),
	('630327-7253',	1,	'Quentin',	'Tarantino',	50),
	('400316-1354',	3,	'Rock',		'Olga',			70),
	('090301-6483', 1,	'Justin',	'Bieber',		4),
	('570826-6385',	4,	'Dr',		'Alban',		56),
	('170312-2467',	1,	'Leif',		'G.W Persson',	204),
	('970621-8967',	1,	'Rebecca',	'Black',		16),
	('820927-2461',	5,	'Lil',		'Wayne',		31);

/*
+-------------+------------------+-----------+
| personal_id | email            | phone     |
+-------------+------------------+-----------+
| 570826-6385 | dr@alban.se      | 073946364 |
| 600510-6493 | bono@utwo.com    | 053759362 |
| 820927-2461 | little@wayne.com | 027365936 |
+-------------+------------------+-----------+
(3 rows)
*/

INSERT INTO contact_customer VALUES
	('600510-6493', 'bono@utwo.com',	'053759362'),
	('570826-6385', 'dr@alban.se',		'073946364'),
	('820927-2461', 'little@wayne.com',	'027365936');

INSERT INTO creditcard_customer VALUES
	('600510-6493'),
	('810217-8485');

INSERT INTO creditcard_type(type) VALUES
	('MasterCard'),
	('Visa'),
	('American Express');



CALL create_flights(CURRENT_DATE(),366);
CALL reserve_seats(50, 'BA1411250');
CALL add_existing_passenger(1, '810217-8485');
CALL add_existing_passenger(1, '600510-6493');
CALL add_existing_passenger(1, '400316-1354');
CALL add_existing_passenger(1, '970621-8967');
CALL add_contact_to_booking(1, '600510-6493');
CALL add_creditcard('01827D', 3, 2, 15, '600510-6493');
CALL pay_booking(1, '01827D');







