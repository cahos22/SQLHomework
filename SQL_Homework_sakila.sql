	USE sakila;
    
    -- 1a. Display the first and last names of all actors from the table actor.
	SELECT first_name,
		   last_name
	FROM   actor;


-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
	SELECT UPPER(CONCAT(first_name, last_name)) as `Actor Name`
	FROM   actor;


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
-- What is one query would you use to obtain this information?
	SELECT actor_id,
		   first_name,
		   last_name
	FROM   actor
	WHERE  first_name LIKE '%Joe%';

-- 2b. Find all actors whose last name contain the letters GEN:
	SELECT actor_id,
		   first_name,
		   last_name,
		   last_update
	FROM   actor
	WHERE  last_name LIKE '%GEN%';



-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
	SELECT actor_id,
		   first_name,
		   last_name,
		   last_update
	FROM   actor
	WHERE  last_name LIKE '%LI%'
	ORDER BY last_name, first_name;

    
-- 2d. Using IN, display the country_id and country columns of the following 
-- countries: Afghanistan, Bangladesh, and China:
	SELECT country_id,
		   country
	FROM   country
	WHERE  country IN ('Afghanistan', 'Bangladesh', 'China');
	   


-- 3a. Add a middle_name column to the table actor. Position it between first_name 
-- and last_name. Hint: you will need to specify the data type.
	ALTER table sakila.actor 
	ADD COLUMN middle_name VARCHAR(45) NOT NULL AFTER first_name;


-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the middle_name column to blobs.
	ALTER table sakila.actor MODIFY middle_name BLOB NOT NULL;


-- 3c. Now delete the middle_name column.
	ALTER table sakila.actor DROP COLUMN middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
	SELECT last_name,
		   count(*) as same_last_name
	FROM   sakila.actor
	GROUP BY last_name;
    

-- 4b. List last names of actors and the number of actors who have that 
-- last name, but only for names that are shared by at least two actors
	SELECT last_name,
		   count(DISTINCT(actor_id)) as same_last_name
	FROM   sakila.actor
	GROUP BY last_name
	HAVING same_last_name>=2;



-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the 
-- actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's 
-- husband's yoga teacher. Write a query to fix the record.
	UPDATE actor
	SET first_name='HARPO'
	WHERE first_name='GROUCHO' AND last_name='WILLIAMS';


-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
-- Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
    
	ALTER TABLE actor
	ADD CONSTRAINT UC_actor_name UNIQUE (first_name, last_name);


    SET sql_mode = '';
    
	UPDATE actor
	SET first_name = CASE WHEN first_name = 'HARPO' THEN 'GROUCHO'
					 WHEN first_name = 'GROUCHO' THEN 'MUCHO GROUCHO' 
					 ELSE first_name END;
	
    
	select * 
    from actor
    where first_name='HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
	DROP TABLE IF EXISTS address;
    

	CREATE TABLE `address` (
	  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
	  `address` varchar(50) NOT NULL,
	  `address2` varchar(50) DEFAULT NULL,
	  `district` varchar(20) NOT NULL,
	  `city_id` smallint(5) unsigned NOT NULL,
	  `postal_code` varchar(10) DEFAULT NULL,
	  `phone` varchar(20) NOT NULL,
	  `location` geometry NOT NULL,
	  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	  PRIMARY KEY (`address_id`),
	  KEY `idx_fk_city_id` (`city_id`),
	  SPATIAL KEY `idx_location` (`location`),
	  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
	) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

	SHOW TABLES;


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
	SELECT  s.first_name,
			s.last_name,
            a.address
	FROM    staff as s
    LEFT JOIN address as a
    ON  a.address_id = s.address_id;


-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
	SELECT  s.first_name,
			s.last_name,
            p.amount,
            p.payment_date
	FROM    sakila.staff as s
    LEFT JOIN sakila.payment as p
    ON  s.staff_id = p.staff_id
    WHERE p.payment_date between '2005-08-01' AND '2005-08-31';

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
	SELECT  fa.film_id,
			f.title,
            COUNT(*) `number_of_actors`
	FROM    sakila.film as f
    INNER JOIN sakila.film_actor as fa
    ON  fa.film_id = f.film_id
    GROUP BY fa.film_id, f.title;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
	SELECT COUNT(*) number_of_copies
    FROM sakila.inventory i
    INNER JOIN sakila.film f
    ON i.film_id=f.film_id
	WHERE f.title LIKE '%Hunchback%Impossible%';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
--    ![Total amount paid](Images/total_payment.png)
	SELECT  	c.customer_id,
				c.last_name,
				SUM(p.amount) as total_paid
    FROM		sakila.customer c
    INNER JOIN 	sakila.payment p
    ON p.customer_id = c.customer_id
    GROUP BY c.customer_id, c.last_name;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
	SELECT title
    FROM sakila.film
    WHERE title IN (SELECT title 
					FROM sakila.film
					WHERE title LIKE 'K%'
                    UNION ALL
                    SELECT title 
					FROM sakila.film
					WHERE title LIKE 'Q%')
	AND language_id = 1;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
	SELECT a.first_name, a.last_name, CONCAT(a.first_name, ' ', a.last_name) as full_name
    FROM   sakila.actor a
    WHERE a.actor_id in (	SELECT actor_id 
							FROM sakila.film_actor
							WHERE film_id IN (SELECT film_id 
											  FROM film
                                              WHERE title LIKE '%Alone%Trip%')	
						);


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
	SELECT c.first_name, c.last_name, c.email
    FROM       sakila.customer c
    INNER JOIN sakila.address a
    ON a.address_id = c.address_id
    INNER JOIN sakila.city ci
    ON ci.city_id = a.city_id
    INNER JOIN sakila.country co
    ON co.country_id = ci.country_id
    WHERE co.country = 'Canada';
    
			

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
	SELECT 	f.film_id,
			f.title,
            fc.category_id
	FROM    sakila.film f
    INNER JOIN sakila.film_category fc
    ON fc.film_id = f.film_id
    INNER JOIN sakila.category c
    ON c.category_id = fc.category_id
    WHERE c.name = 'Family';
    
	SELECT 	f.film_id,
			f.title,
            fc.category_id
	FROM    sakila.film f
    INNER JOIN sakila.film_category fc
    ON fc.film_id = f.film_id
    INNER JOIN sakila.category c
    ON (c.category_id = fc.category_id AND c.name = 'Family');

-- 7e. Display the most frequently rented movies in descending order.
	SELECT 	f.film_id,
			f.title,
            COUNT(*) as number_of_rentals
	FROM    sakila.film f
    INNER JOIN sakila.inventory i
    ON f.film_id = i.film_id
    INNER JOIN sakila.rental r
    ON r.inventory_id = i.inventory_id
    GROUP BY f.film_id, f.title
    ORDER BY number_of_rentals DESC
    LIMIT 1000;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
	SELECT 	s.store_id,
			SUM(p.amount) total_rent_amount
	FROM    sakila.store s
    INNER JOIN sakila.inventory i
    ON i.store_id = s.store_id
    INNER JOIN sakila.rental r
    ON r.inventory_id = i.inventory_id
	INNER JOIN sakila.payment p
    ON p.rental_id = r.rental_id
    GROUP BY s.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.
	SELECT 	s.store_id,
			c.city,
            co.country
	FROM    sakila.store s
    INNER JOIN sakila.address a
    ON a.address_id = s.address_id
    INNER JOIN sakila.city c
    ON c.city_id = a.city_id
	INNER JOIN sakila.country co
    ON co.country_id = c.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
	SELECT 	c.name,
			SUM(p.amount) total_gross_revenue
	FROM 	sakila.category c
    INNER JOIN sakila.film_category fc
    ON fc.category_id = c.category_id
    INNER JOIN sakila.inventory i
    ON i.film_id = fc.film_id
    INNER JOIN sakila.rental r
    ON r.inventory_id = i.inventory_id
    INNER JOIN sakila.payment p
    ON p.rental_id = r.rental_id
    GROUP BY c.name
    ORDER BY total_gross_revenue DESC
    LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
	USE sakila; 
    
    CREATE VIEW v_Total_Revenue_Genre AS
    SELECT 	c.name,
			SUM(amount) total_gross_revenue
	FROM 	sakila.category c
    INNER JOIN sakila.film_category fc
    ON fc.category_id = c.category_id
    INNER JOIN sakila.inventory i
    ON i.film_id = fc.film_id
    INNER JOIN sakila.rental r
    ON r.inventory_id = i.inventory_id
    INNER JOIN sakila.payment p
    ON p.rental_id = r.rental_id
    GROUP BY c.name
    ORDER BY total_gross_revenue DESC
    LIMIT 5;
    
  

-- 8b. How would you display the view that you created in 8a?
	SELECT * 
	FROM sakila.v_Total_Revenue_Genre;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
	DROP VIEW IF EXISTS sakila.v_Total_Revenue_Genre;


