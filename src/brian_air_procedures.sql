DROP PROCEDURE IF EXISTS create_flights;
DROP PROCEDURE IF EXISTS create_single_flight;
DROP PROCEDURE IF EXISTS reserve_seats;
DROP PROCEDURE IF EXISTS add_passenger;
DROP PROCEDURE IF EXISTS add_existing_passenger;
DROP PROCEDURE IF EXISTS add_creditcard;
DROP PROCEDURE IF EXISTS pay_booking;
DROP PROCEDURE IF EXISTS get_flight_price;
DROP PROCEDURE IF EXISTS get_seats_taken;
DROP PROCEDURE IF EXISTS flights_to;
DROP PROCEDURE IF EXISTS add_contact_to_booking;


DELIMITER //

-- Creates regular flights from weekly flight. Starting from 
-- the given date adding regular flights for the given number 
-- of days after this date.
CREATE PROCEDURE create_flights (IN start DATE, IN days INT)
BEGIN
	DECLARE nr INT;
	DECLARE cur_date DATE;

	SET cur_date = start;
	SET nr = 0;

	WHILE days > nr DO

		CALL create_single_flight(cur_date);
		SET nr 			= nr + 1;
	 	SET cur_date 	= DATE_ADD(cur_date, INTERVAL 1 DAY);

	END WHILE;

	SELECT "Flights created!" AS "Confirm Message";
END;

-- Used by "create_flights" to create a SINGLE flight. Only used internally.
CREATE PROCEDURE create_single_flight (IN cur_date DATE)
create_flight: BEGIN

	-- Initial declarations.
	DECLARE flight_id INT;
	DECLARE identifier VARCHAR(64);
	DECLARE done INT DEFAULT FALSE;
	DECLARE counter INT DEFAULT 0;
	DECLARE flight_exist INT;

	-- Cursor for looping over all flights matching the 
	-- date conditions.
	DECLARE cur CURSOR FOR 
		SELECT id 
		FROM weekly_flight 
		WHERE flies_on = DAYOFWEEK(cur_date) 
		AND year = YEAR(cur_date);

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	SET flight_exist = (SELECT COUNT(*) FROM regular_flight WHERE regular_flight.date=cur_date LIMIT 1);

	IF flight_exist > 0 THEN
		SELECT "Flights has already been generated for this date" AS "Error Message";
		LEAVE create_flight;
	END IF;

	OPEN cur;
		
	read_loop: LOOP
		
		SET identifier = CONCAT('BA', DATE_FORMAT(cur_date, '%y%m%d'), counter);

		FETCH cur into flight_id;
		
		IF done THEN
			LEAVE read_loop;
		END IF;

		INSERT INTO regular_flight VALUES
			(identifier, cur_date, flight_id);

		SET counter = counter+1;

	END LOOP;

	CLOSE cur;
END;

-- Reserves a given number of seats on a given flight
CREATE PROCEDURE reserve_seats(IN seats INT, IN flight_number VARCHAR(64))
reserve_label : BEGIN
		
	DECLARE i INT DEFAULT 0;
	DECLARE id INT;
	DECLARE payed_seats INT;
	DECLARE message VARCHAR(64);

	CALL get_seats_taken(flight_number,payed_seats);

	IF 60-payed_seats<seats THEN
		SELECT "Could not reserve seats" as "Error Message";
		LEAVE reserve_label;
	END IF;

	INSERT INTO booking(flight) VALUES
		(flight_number);

	SET id = LAST_INSERT_ID();

	WHILE seats > i DO

		INSERT INTO passenger_on(booking) VALUES
			(id);

		SET i = i+1;

	END WHILE;

	SET message = CONCAT(seats," seats have been reserved");

	SELECT message AS "Confirm Message";

END;

-- Adds a passenger to the database. It both adds it in the customer table and in a specific booking. Used for "first-time-fliers".
CREATE PROCEDURE add_passenger(	IN booking_number INT,
								IN pid VARCHAR(64),
								IN title INT,
								IN first_name VARCHAR(64),
								IN last_name VARCHAR(64),
								IN age INT)

BEGIN
	
	INSERT INTO customer VALUES
		(pid,title,first_name,last_name,age);

	CALL add_existing_passenger(booking_number,pid);
END;

-- Adds a customer that is already in the customer table to a specific booking.
CREATE PROCEDURE add_existing_passenger(IN booking_number INT, IN pid VARCHAR(64))
add_existing_label: BEGIN
	
	DECLARE seats_left_in_booking INT;
	
	SET seats_left_in_booking = (
		SELECT COUNT(*)
		FROM passenger_on
		WHERE 	booking = booking_number
		AND 	customer IS NULL
	);

	IF seats_left_in_booking = 0 THEN
		SELECT "The booking is full, try adding a new booking if the current number of passengers is not sufficient"
		AS "Error message";
		LEAVE add_existing_label;
	END IF;

	-- Adds passenger credentials to the first empty space
	-- For a customer on the boooking
	UPDATE passenger_on 
	SET customer=pid 
	WHERE booking=booking_number 
	AND customer IS NULL 
	LIMIT 1;

END;

-- PROCEDURE TO MARK A CUSTOMER AS CONTACT?

CREATE PROCEDURE add_contact_to_booking(IN booking_number INT, IN customer VARCHAR(64))
contact: BEGIN
	DECLARE exist INT;
	DECLARE is_contact INT;
	DECLARE in_booking INT;

	SET exist = (
		SELECT COUNT(*) 
		FROM customer 
		WHERE customer.personal_id=customer
		LIMIT 1
	);

	-- Checks if the customer exists.
	-- If not, an error message is displayed and procedure ends.
	IF exist = 0 THEN
		SELECT "Customer doesn't exist. Please add customer before." AS "Error Message";
		LEAVE contact;
	END IF;

	SET is_contact = (
		SELECT COUNT(*) 
		FROM contact_customer
		WHERE contact_customer.personal_id=customer
		LIMIT 1
	);

	IF is_contact = 0 THEN
		SELECT "Customer is not a contact customer. Please add as contact customer before." AS "Error Message";
		LEAVE contact;
	END IF;

	SET in_booking = (
		SELECT COUNT(*)
		FROM passenger_on
		WHERE passenger_on.customer = customer
		AND passenger_on.booking = booking_number
		LIMIT 1
	); 

	IF in_booking = 0 THEN
		SELECT "The customer is not a part of this booking." AS "Error Message";
		LEAVE contact;
	END IF;

	UPDATE booking
	SET booking.contact = customer
	WHERE booking.booking_number = booking_number;

	SELECT CONCAT("Successfully added ", customer, " as a contact customer to ", booking_number, ".") 
	AS "Confirmation Message";

END;



-- Adds a credit card to the database so it can be used to pay for a booking.
CREATE PROCEDURE add_creditcard (	IN card_number VARCHAR(64),
									IN type INT,
									IN expires_month INT,
									IN expires_year INT,
									IN customer VARCHAR(64))
add_card: BEGIN
	
	DECLARE exist VARCHAR(64);

	SET exist = (SELECT personal_id FROM customer WHERE personal_id=customer);

	-- Checks if the customer exists.
	-- If not, an error message is displayed and procedure ends.
	IF exist IS NULL THEN
		SELECT "Customer doesn't exist. Please add customer before." AS "Error Message";
		LEAVE add_card;
	END IF;

	SET exist = (SELECT personal_id FROM creditcard_customer WHERE personal_id=customer);

	-- Checks if the customer is already listed as a credit card customer.
	-- If not, add customer to creditcard_customer table.
	IF exist IS NULL THEN
		INSERT INTO creditcard_customer VALUES
			(customer);
	END IF;

	INSERT INTO creditcard VALUES
		(card_number,expires_month,expires_year,type,customer);

END;

-- Pays for a booking with a given credit card.
CREATE PROCEDURE pay_booking(IN booking_number INT, IN creditcard_number VARCHAR(64)) 
booking: BEGIN
	
	DECLARE tot_price INT DEFAULT 0;
	DECLARE flight_num VARCHAR(64);
	DECLARE passenger_in_booking INT;
	DECLARE passenger_on_flight INT;
	DECLARE year INT;
	DECLARE route INT;
	DECLARE day INT;
	DECLARE base_price INT;
	DECLARE weekday_factor INT;
	DECLARE passenger_factor INT;
	DECLARE contact VARCHAR(64);
	DECLARE message VARCHAR(64);

	SET flight_num 	  	 		= (SELECT flight FROM booking WHERE booking.booking_number=booking_number LIMIT 1);
	SET passenger_in_booking	= (SELECT COUNT(*) FROM passenger_on WHERE booking=booking_number);

	SET contact = (SELECT booking.contact FROM booking WHERE booking.booking_number=booking_number LIMIT 1);

	IF contact IS NULL THEN
		SELECT "Booking has no contact customer, please add one." AS "Error Message";
		LEAVE booking;
	END IF;

	CALL get_seats_taken(flight_num,passenger_on_flight);

	-- Check to if there is enough free to continue payment.
	-- Otherwise the booking is removed.
	IF 60 - passenger_on_flight < passenger_in_booking THEN
		DELETE FROM passenger_on WHERE booking = booking_number;
		DELETE FROM booking WHERE booking.booking_number = booking_number;
		SELECT "Reservation is not valid and has been removed" as "Error Message";
		LEAVE booking;
	END IF;

	CALL get_flight_price(flight_num,tot_price);

	SET tot_price = tot_price*passenger_in_booking;

	INSERT INTO payment(amount,paid_with,paid_for) VALUES
		(tot_price,creditcard_number,booking_number);

	UPDATE booking 
	SET booking.ticket_number=MD5(NOW()) 
	WHERE booking.booking_number=booking_number;

	-- Since the booking as a whole has been payed for, the status 
	UPDATE passenger_on 
	SET payed=1 
	WHERE booking=booking_number;

	SET message = CONCAT("Payment for booking number ", booking_number, " successful!");

	-- Confirmation
	SELECT message 
	AS "Confirmation Message";
	
END;

-- Returns the price of a flight given a flight number
CREATE PROCEDURE get_flight_price(IN flight_num VARCHAR(64), OUT price INT)
BEGIN
	
	DECLARE passenger_on_flight INT;
	DECLARE year INT;
	DECLARE route INT;
	DECLARE day INT;
	DECLARE passenger_factor INT;
	DECLARE weekday_factor INT;
	DECLARE base_price INT;

	CALL get_seats_taken(flight_num,passenger_on_flight);
	
	SELECT 	w.year, 	w.route, 	w.flies_on  
	INTO 	year,		route,		day
	FROM (
		regular_flight AS r 
		INNER JOIN weekly_flight AS w 
		ON r.from_weekly = w.id
	) 
	WHERE flight_number = flight_num 
	LIMIT 1;
	
	SET passenger_factor 	= (SELECT factor FROM passenger_factor WHERE passenger_factor.year = year);
	SET weekday_factor 		= (SELECT factor FROM weekday_factor WHERE weekday = day AND weekday_factor.year = year);
	SET base_price 			= (SELECT base_price.price FROM base_price WHERE id=route);
	SET price 				= base_price*weekday_factor*GREATEST(passenger_on_flight,1)*passenger_factor;

END;

-- Returns the number of payed seats on a given flight
CREATE PROCEDURE get_seats_taken(IN flight VARCHAR(64), OUT payed_seats INT)
BEGIN
	SET payed_seats = (
		SELECT COUNT(*) 
		FROM passenger_on 
		WHERE booking 
		IN (
			SELECT booking_number 
			FROM booking 
			WHERE booking.flight = flight
		) 
		AND payed=1
	);
END;

-- Lists all the available flight to a destination on a given date.
CREATE PROCEDURE flights_to(IN dest VARCHAR(64), IN date DATE)
BEGIN
	
	-- Initial declarations
	DECLARE stop_loop 			INT DEFAULT FALSE;
	DECLARE flight_id 			VARCHAR(64);
	DECLARE flight_date 		DATE;
	DECLARE flight_departure 	TIME;
	DECLARE flight_price 		INT;
	DECLARE seats_taken 		INT;
	DECLARE seats_free 			INT;

	-- Creates a table as a result, containing all flight information
	-- for a given destination, on a given date.
	DECLARE cur CURSOR FOR 	
		SELECT 	flight_number, date, departure_time 
		FROM 	regular_flight 
		INNER JOIN (
			SELECT * 
			FROM 	weekly_flight 
			WHERE 	route 
			IN (
				SELECT id 
				FROM route 
				WHERE arrives 
				IN (
					SELECT id 
					FROM airport 
					WHERE name = dest
				)
			) 
			AND year=YEAR(date)
			
		) 
		AS w 
		WHERE regular_flight.from_weekly=w.id
		AND regular_flight.date=date;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET stop_loop = TRUE;

	CREATE TEMPORARY TABLE temp_table(
		id VARCHAR(64),
		departure TIME,
		free INT,
		price INT 
		);

	OPEN cur;
	
	-- Reading from our cursor while there are valid
	-- results.
	read_loop: LOOP

		FETCH cur INTO flight_id, flight_date, flight_departure;
		
		IF stop_loop THEN
			LEAVE read_loop;
		END IF;

		CALL get_seats_taken(flight_id,seats_taken);

		SET seats_free = 60-seats_taken;

		IF seats_free > 0 THEN
			CALL get_flight_price(flight_id,flight_price);
			INSERT INTO temp_table 
			VALUES (flight_id,flight_departure,seats_free,flight_price);
		END IF;

	END LOOP;

	CLOSE cur;

	-- Display and then drop temporary table.
	SELECT * FROM temp_table;
	DROP TABLE temp_table;

END //

DELIMITER ;