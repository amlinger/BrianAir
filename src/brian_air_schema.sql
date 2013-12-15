-- CREATE DATABASE IF NOT EXISTS brian_air;
-- USE brian_air;

DROP TABLE IF EXISTS passenger_on CASCADE;
DROP TABLE IF EXISTS passenger_factor CASCADE;
DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS booking CASCADE;
DROP TABLE IF EXISTS regular_flight CASCADE;
DROP TABLE IF EXISTS weekly_flight CASCADE;
DROP TABLE IF EXISTS weekday_factor CASCADE;
DROP TABLE IF EXISTS weekday CASCADE;
DROP TABLE IF EXISTS route CASCADE;
DROP TABLE IF EXISTS base_price CASCADE;
DROP TABLE IF EXISTS airport CASCADE;
DROP TABLE IF EXISTS creditcard CASCADE;
DROP TABLE IF EXISTS creditcard_type CASCADE;
DROP TABLE IF EXISTS creditcard_customer CASCADE;
DROP TABLE IF EXISTS contact_customer CASCADE;
DROP TABLE IF EXISTS customer CASCADE;

-- STEP 1
-- Create Database

CREATE TABLE customer (
	personal_id VARCHAR(64) NOT NULL,
	title ENUM("Mr", "Ms", "Mrs", "Dr", "Dawgh"),
	first_name VARCHAR(64) NOT NULL,
	last_name VARCHAR(64) NOT NULL,
	age INT,
	PRIMARY KEY (personal_id)
) ENGINE=InnoDB;

CREATE TABLE contact_customer (
	personal_id VARCHAR(64) PRIMARY KEY REFERENCES customer(personal_id),
	email VARCHAR(64) NOT NULL,
	phone VARCHAR(64) NOT NULL
) ENGINE=InnoDB;


CREATE TABLE creditcard_customer (
	personal_id VARCHAR(64) PRIMARY KEY REFERENCES customer(personal_id)
) ENGINE=InnoDB;

CREATE TABLE creditcard_type (
	id INT NOT NULL auto_increment,
	type VARCHAR(64) NOT NULL,
	PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE creditcard (
	card_number VARCHAR(64) NOT NULL,
	expires_month ENUM("jan", "feb", "mar", "apr", "may","jun","jul", "aug","sep", "oct", "nov", "dec") NOT NULL,
	expires_year INT NOT NULL,
	type INT NOT NULL,
	customer VARCHAR(64) NOT NULL,
	PRIMARY KEY (card_number),
	FOREIGN KEY (type)		REFERENCES creditcard_type(id),
	FOREIGN KEY (customer) 	REFERENCES customer(personal_id)
) ENGINE=InnoDB;

CREATE TABLE airport (
	id INT NOT NULL auto_increment,
	name VARCHAR(64),
	PRIMARY KEY(id)
) ENGINE=InnoDB;

CREATE TABLE base_price (
	id INT NOT NULL auto_increment,
	price INT NOT NULL,
	PRIMARY KEY(id)
) ENGINE=InnoDB;

CREATE TABLE route (
	id INT NOT NULL auto_increment, 
	arrives INT NOT NULL,
	departs INT NOT NULL,
	price INT NOT NULL,
	PRIMARY KEY(id),
	FOREIGN KEY (arrives)   REFERENCES airport(id),
	FOREIGN KEY (departs)   REFERENCES airport(id),
	FOREIGN KEY (price) 	REFERENCES base_price(id)
) ENGINE=InnoDB;

CREATE TABLE weekday (
	id INT NOT NULL auto_increment,
	name VARCHAR(64) NOT NULL,
	PRIMARY KEY(id)
) ENGINE=InnoDB;

CREATE TABLE weekday_factor (
	id INT NOT NULL auto_increment,
	year YEAR(4),
	factor INT NOT NULL,
	weekday INT NOT NULL,
	PRIMARY KEY(id),
	FOREIGN KEY (weekday) REFERENCES weekday(id)
) ENGINE=InnoDB;

CREATE TABLE weekly_flight (
	id INT NOT NULL auto_increment,
	year INT NOT NULL,
	departure_time TIME NOT NULL,
	flies_on INT NOT NULL,
	route INT NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (route) 	REFERENCES route(id),
	FOREIGN KEY (flies_on) 	REFERENCES weekday(id)
) ENGINE=InnoDB;

CREATE TABLE regular_flight (
	flight_number VARCHAR(64) NOT NULL,
	date DATE NOT NULL,
	from_weekly INT NOT NULL,
	PRIMARY KEY (flight_number),
	FOREIGN KEY (from_weekly) REFERENCES weekly_flight(id)
) ENGINE=InnoDB;

CREATE TABLE booking (
	booking_number INT NOT NULL auto_increment, 
 	ticket_number VARCHAR(32), 
 	contact VARCHAR(64),
 	flight VARCHAR(64) NOT NULL,
	PRIMARY KEY(booking_number),
    FOREIGN KEY (contact) REFERENCES contact_customer(personal_id),
	FOREIGN KEY (flight)  REFERENCES regular_flight(flight_number)
) ENGINE=InnoDB;

CREATE TABLE payment (
	id INT NOT NULL auto_increment,
	amount INT NOT NULL,
	paid_with VARCHAR(64) NOT NULL,
	paid_for INT NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (paid_with) REFERENCES creditcard(card_number),
	FOREIGN KEY (paid_for)  REFERENCES booking(booking_number)
) ENGINE=InnoDB;

CREATE TABLE passenger_factor (
	year INT NOT NULL,
	factor INT NOT NULL,
	PRIMARY KEY(year)
) ENGINE=InnoDB;

-- STEP 5 
-- Extracting the only N <-> M relation in the 
-- EER diagram in a separate table. This enables
-- several customers to be a part of several flights.
CREATE TABLE passenger_on (
	id INT NOT NULL auto_increment,
	customer VARCHAR(64),
	booking INT NOT NULL,
	payed INT DEFAULT 0,
	PRIMARY KEY (id),
	FOREIGN KEY (customer) REFERENCES customer(personal_id),
	FOREIGN KEY (booking)  REFERENCES booking(booking_number)
) ENGINE=InnoDB;

source LiU/brian_air_procedures.sql;
source LiU/brian_air_data.sql;