USE sakila;


-- Retrieving how many copies of the film Hunchback Impossible exist in the inventory system
SELECT 
    f.title, 
    COUNT(i.inventory_id) AS number_of_copies
FROM 
    film f
JOIN 
    inventory i ON f.film_id = i.film_id
WHERE 
    f.title = 'Hunchback Impossible'
GROUP BY 
    f.title;
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- Listing all films whose length is longer than the average of all the films.
SELECT 
    title, 
    length 
FROM 
    film 
WHERE 
    length > (SELECT AVG(length) FROM film);
--------------------------------------------------------------------------------------------------------------------------------------------------

-- Displaying all actors who appear in the film Alone Trip.
SELECT 
    a.actor_id, 
    a.first_name, 
    a.last_name
FROM 
    actor a
WHERE 
    a.actor_id IN (
        SELECT 
            fa.actor_id
        FROM 
            film_actor fa
        WHERE 
            fa.film_id = (
                SELECT 
                    f.film_id
                FROM 
                    film f
                WHERE 
                    f.title = 'Alone Trip'
            )
    );
-------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Identifying all movies categorized as family films to target for promotion, as sales have been lagging among young families.
SELECT 
    f.title, 
    c.name AS category
FROM 
    film f
JOIN 
    film_category fc ON f.film_id = fc.film_id
JOIN 
    category c ON fc.category_id = c.category_id
WHERE 
    c.name = 'Family';
--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Retrieving names and emails from customers from Canada using subqueries.

SELECT 
    c.first_name, 
    c.last_name, 
    c.email
FROM 
    customer c
WHERE 
    c.address_id IN (
        SELECT 
            a.address_id
        FROM 
            address a
        WHERE 
            a.city_id IN (
                SELECT 
                    ci.city_id
                FROM 
                    city ci
                WHERE 
                    ci.country_id = (
                        SELECT 
                            co.country_id
                        FROM 
                            country co
                        WHERE 
                            co.country = 'Canada'
                    )
            )
    );
------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Finding the films that are starred by the most prolific actor.

#Step1 : Finding the Most Prolific Actor
SELECT 
    actor_id, 
    COUNT(film_id) AS num_films
FROM 
    film_actor
GROUP BY 
    actor_id
ORDER BY 
    num_films DESC
LIMIT 1;

#Step2 : Finding the Films Starred by the Most Prolific Actor
SELECT 
    f.title
FROM 
    film f
JOIN 
    film_actor fa ON f.film_id = fa.film_id
WHERE 
    fa.actor_id = 107;


#Fianl Result :
SELECT 
    f.title
FROM 
    film f
JOIN 
    film_actor fa ON f.film_id = fa.film_id
WHERE 
    fa.actor_id = (
        SELECT 
            actor_id
        FROM 
            (SELECT 
                actor_id, 
                COUNT(film_id) AS num_films
            FROM 
                film_actor
            GROUP BY 
                actor_id
            ORDER BY 
                num_films DESC
            LIMIT 1) AS most_prolific_actor
    );
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Finding the films that are rented by the most profitable customer.

#Step 1: Identifying the Most Profitable Customer
SELECT 
    customer_id, 
    SUM(amount) AS total_spent
FROM 
    payment
GROUP BY 
    customer_id
ORDER BY 
    total_spent DESC
LIMIT 1;


#Step 2: Finding the Films Rented by the Most Profitable Customer
SELECT DISTINCT
    f.title
FROM 
    film f
JOIN 
    inventory i ON f.film_id = i.film_id
JOIN 
    rental r ON i.inventory_id = r.inventory_id
JOIN 
    payment p ON r.rental_id = p.rental_id
WHERE 
    p.customer_id = 526;



#Final Result :
SELECT DISTINCT
    f.title
FROM 
    film f
JOIN 
    inventory i ON f.film_id = i.film_id
JOIN 
    rental r ON i.inventory_id = r.inventory_id
JOIN 
    payment p ON r.rental_id = p.rental_id
WHERE 
    p.customer_id = (
        SELECT 
            customer_id
        FROM 
            (SELECT 
                customer_id, 
                SUM(amount) AS total_spent
            FROM 
                payment
            GROUP BY 
                customer_id
            ORDER BY 
                total_spent DESC
            LIMIT 1) AS most_profitable_customer
    );
------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Retrieving the customer_id and the total_amount_spent of those customers who spent more than the average of the total amount spent by each customer

SELECT 
    customer_id, 
    SUM(amount) AS total_amount_spent
FROM 
    payment
GROUP BY 
    customer_id
HAVING 
    total_amount_spent > (
        SELECT 
            AVG(total_amount_spent) 
        FROM 
            (SELECT 
                SUM(amount) AS total_amount_spent
            FROM 
                payment
            GROUP BY 
                customer_id) AS customer_totals
    );

























