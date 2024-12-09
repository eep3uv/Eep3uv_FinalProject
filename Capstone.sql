#GET THE DIM DATE TABLE
USE sakila;



#Export Data from  Entity into a JSON File
SELECT * from sakila.dim_customer;

#Export Data from Entity into a JSON file
SELECT * from sakila.dim_inventory;

#Export Data from Entity into a JSON file
SELECT * from sakila.dim_payment;

#ADD CUSTOMER AND FACT_ORDERS TABLES 
#modified customer table by dropping "active" column
#----------------------------------------------------
USE sakila;

CREATE TABLE `dim_customer` (
  `customer_id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `store_id` tinyint unsigned NOT NULL,
  `first_name` varchar(45) NOT NULL,
  `last_name` varchar(45) NOT NULL,
  `email` varchar(50) DEFAULT NULL,
  `address_id` smallint unsigned NOT NULL,
  `create_date` datetime NOT NULL,
  `last_update` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`customer_id`),
  KEY `idx_fk_store_id` (`store_id`),
  KEY `idx_fk_address_id` (`address_id`),
  KEY `idx_last_name` (`last_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `sakila`.`dim_customer`
(`customer_id`,
`store_id`,
`first_name`,
`last_name`,
`email`,
`address_id`,
`create_date`,
`last_update`)
SELECT `customer`.`customer_id`,
    `customer`.`store_id`,
    `customer`.`first_name`,
    `customer`.`last_name`,
    `customer`.`email`,
    `customer`.`address_id`,
    `customer`.`create_date`,
    `customer`.`last_update`
FROM `sakila`.`customer`;

SELECT * FROM sakila.dim_customer;

#Fact orders table 
CREATE TABLE `fact_orders` (
  `rental_id` int NOT NULL AUTO_INCREMENT,
  `rental_date` datetime NOT NULL,
  `inventory_id` mediumint unsigned NOT NULL,
  `customer_id` smallint unsigned NOT NULL,
  `return_date` datetime DEFAULT NULL,
  `staff_id` tinyint unsigned NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`rental_id`),
  UNIQUE KEY `rental_date` (`rental_date`,`inventory_id`,`customer_id`),
  KEY `idx_fk_inventory_id` (`inventory_id`),
  KEY `idx_fk_customer_id` (`customer_id`),
  KEY `idx_fk_staff_id` (`staff_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16050 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `sakila`.`fact_orders`
(`rental_id`,
`rental_date`,
`inventory_id`,
`customer_id`,
`return_date`,
`staff_id`,
`last_update`)
SELECT `rental`.`rental_id`,
    `rental`.`rental_date`,
    `rental`.`inventory_id`,
    `rental`.`customer_id`,
    `rental`.`return_date`,
    `rental`.`staff_id`,
    `rental`.`last_update`
FROM `sakila`.`rental`;
SELECT * FROM sakila.fact_orders;

#separate into 3...

SELECT COUNT(*) AS total_rows
FROM fact_orders;
#16044

#fact_orders1
SELECT *
FROM fact_orders
WHERE rental_id BETWEEN 1 AND 5348
ORDER BY rental_id ASC;

#fact_orders2
SELECT *
FROM fact_orders
WHERE rental_id BETWEEN 5349 AND 10695
ORDER BY rental_id ASC;

#fact_orders3
SELECT *
FROM fact_orders
WHERE rental_id BETWEEN 10696 AND 16044
ORDER BY rental_id ASC;




#----------------------------------------------------
#CREATES THE INVENtORY TABLE: 

USE sakila;
CREATE TABLE `dim_inventory` (
  `inventory_id` mediumint unsigned NOT NULL AUTO_INCREMENT,
  `film_id` smallint unsigned NOT NULL,
  `store_id` tinyint unsigned NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`inventory_id`),
  KEY `idx_fk_film_id` (`film_id`),
  KEY `idx_store_id_film_id` (`store_id`,`film_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4582 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `sakila`.`dim_inventory`
(`inventory_id`,
`film_id`,
`store_id`,
`last_update`)
SELECT `inventory`.`inventory_id`,
    `inventory`.`film_id`,
    `inventory`.`store_id`,
    `inventory`.`last_update`
FROM `sakila`.`inventory`;

SELECT * FROM sakila.dim_inventory;

#----------------------------------------------------
#CREATES THE PAYMENT TABLE:
USE sakila;
CREATE TABLE `dim_payment` (
  `payment_id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` smallint unsigned NOT NULL,
  `staff_id` tinyint unsigned NOT NULL,
  `rental_id` int DEFAULT NULL,
  `amount` decimal(5,2) NOT NULL,
  `payment_date` datetime NOT NULL,
  `last_update` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`payment_id`),
  KEY `idx_fk_staff_id` (`staff_id`),
  KEY `idx_fk_customer_id` (`customer_id`),
  KEY `fk_payment_rental` (`rental_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16050 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `sakila`.`dim_payment`
(`payment_id`,
`customer_id`,
`staff_id`,
`rental_id`,
`amount`,
`payment_date`,
`last_update`)
SELECT `payment`.`payment_id`,
    `payment`.`customer_id`,
    `payment`.`staff_id`,
    `payment`.`rental_id`,
    `payment`.`amount`,
    `payment`.`payment_date`,
    `payment`.`last_update`
FROM `sakila`.`payment`;

SELECT * FROM sakila.dim_payment;

#Creates the FILM table:
USE sakila;
CREATE TABLE `dim_film` (
  `film_id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL,
  `description` text,
  `release_year` year DEFAULT NULL,
  `language_id` tinyint unsigned NOT NULL,
  `original_language_id` tinyint unsigned DEFAULT NULL,
  `rental_duration` tinyint unsigned NOT NULL DEFAULT '3',
  `rental_rate` decimal(4,2) NOT NULL DEFAULT '4.99',
  `length` smallint unsigned DEFAULT NULL,
  `replacement_cost` decimal(5,2) NOT NULL DEFAULT '19.99',
  `rating` enum('G','PG','PG-13','R','NC-17') DEFAULT 'G',
  `special_features` set('Trailers','Commentaries','Deleted Scenes','Behind the Scenes') DEFAULT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`film_id`),
  KEY `idx_title` (`title`),
  KEY `idx_fk_language_id` (`language_id`),
  KEY `idx_fk_original_language_id` (`original_language_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `sakila`.`dim_film`
(`film_id`,
`title`,
`description`,
`release_year`,
`language_id`,
`original_language_id`,
`rental_duration`,
`rental_rate`,
`length`,
`replacement_cost`,
`rating`,
`special_features`,
`last_update`)
SELECT `film`.`film_id`,
    `film`.`title`,
    `film`.`description`,
    `film`.`release_year`,
    `film`.`language_id`,
    `film`.`original_language_id`,
    `film`.`rental_duration`,
    `film`.`rental_rate`,
    `film`.`length`,
    `film`.`replacement_cost`,
    `film`.`rating`,
    `film`.`special_features`,
    `film`.`last_update`
FROM `sakila`.`film`;

SELECT * FROM sakila.dim_film;




#------------------------------------------------------------
#QUERIES BELOW

#The below query calculates the total number of rentals for each customer using the fact orders table and the customer table 
SELECT 
    c.first_name, 
    c.last_name, 
    COUNT(f.rental_key) AS total_number_rentals
FROM 
    fact_orders f
JOIN 
    customer c ON f.customer_id = c.customer_id
GROUP BY 
    c.first_name, c.last_name
ORDER BY 
    total_number_rentals DESC;




#The below query joins the fact orders table with the inventory and film tables to calculate the total number of rentals for each film 
SELECT 
    fi.title, 
    COUNT(f.rental_key) AS total_number_rentals
FROM 
    fact_orders f
JOIN 
    inventory i ON f.inventory_id = i.inventory_id
JOIN 
    film fi ON i.film_id = fi.film_id
GROUP BY 
    fi.title
ORDER BY 
    total_number_rentals DESC;
    
#The below query gives us the information (total rentals and revenue) on films that are longer than a given duration (in this case 115 minutes)
SELECT 
    fi.title, 
    COUNT(f.rental_key) AS total_rentals,
    SUM(p.amount) AS total_revenue
FROM 
    film fi
JOIN 
    inventory i ON fi.film_id = i.film_id
JOIN 
    fact_orders f ON i.inventory_id = f.inventory_id
JOIN 
    payment p ON f.rental_key = p.rental_id
WHERE 
    fi.length > 120 
GROUP BY 
    fi.title
ORDER BY 
    total_revenue DESC;
    
#The below lists the business's 5 best customers by how much they have paid total
SELECT 
    c.first_name, 
    c.last_name, 
    SUM(p.amount) AS total_paid
FROM 
    payment p
JOIN 
    customer c ON p.customer_id = c.customer_id
GROUP BY 
    c.first_name, c.last_name
ORDER BY 
    total_paid DESC
LIMIT 5;

#The below query shows us customers who have rented films more than 3 times (and how many times each of them rented)
SELECT 
    c.first_name, 
    c.last_name, 
    COUNT(f.rental_key) AS total_rental_number
FROM 
    fact_orders f
JOIN 
    customer c ON f.customer_id = c.customer_id
GROUP BY 
    c.first_name, c.last_name
HAVING 
    total_rental_number > 3
ORDER BY 
    total_rental_number DESC;