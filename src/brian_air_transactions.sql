DROP PROCEDURE IF EXISTS trans_reserve;
DROP PROCEDURE IF EXISTS trans_add_customer;
DROP PROCEDURE IF EXISTS trans_add_contact;
DROP PROCEDURE IF EXISTS trans_pay;

DELIMITER //

-- reserve_seats as a transaction
CREATE PROCEDURE trans_reserve(IN seats INT, IN flight_number VARCHAR(64))
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;

START TRANSACTION;
	CALL reserve_seats(seats, flight_number);
	COMMIT;
END;

-- add_existing_passenger as a transaction
CREATE PROCEDURE trans_add_customer(IN booking_number INT, IN pid VARCHAR(64))
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;

START TRANSACTION;
	CALL add_existing_passenger(booking_number, pid);
	COMMIT;
END;

-- add_existing_passanger as a transaction
CREATE PROCEDURE trans_add_contact(IN booking_number INT, IN pid VARCHAR(64))
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;

START TRANSACTION;
	CALL add_contact_to_booking(booking_number, pid);
	COMMIT;
END;

-- pay_booking as a transaction
CREATE PROCEDURE trans_pay(IN booking_number INT, IN creditcard_number VARCHAR(64))
BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION ROLLBACK;
DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;

START TRANSACTION;
	CALL pay_booking(booking_number, creditcard_number);
	COMMIT;
END //


DELIMITER ;