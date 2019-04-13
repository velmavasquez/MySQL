USE sakila;
-- 1a. Display the first and last names of all actors from the table `actor`.
select  first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select concat(first_name,' ', last_name) as 'Actor Name'
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name,
--  "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name  from actor where first_name = 'Joe'; 

-- 2b. Find all actors whose last name contain the letters `GEN`:
select * from actor where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, 
-- in that order:
select * from actor where last_name like '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
select country_id, country from country where country  in ('Afghanistan', 'Bangladesh', 'China') ; 

/* 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description,
so create a column in the table `actor` named `description` and use the data type 
`BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).*/
Alter table actor Add description BLOB;

/*3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
Delete the `description` column.*/
Alter table actor drop description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(actor_id) as 'Number of actors with last name'
from actor 
group by last_name;

/*4b. List last names of actors and the number of actors who have that last name, but only for names that 
are shared by at least two actors*/
select last_name, count(actor_id) as 'Number of actors with last name'
from actor 
group by last_name
having count(actor_id) <=2; 

/* 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`.
 Write a query to fix the record.*/
 update actor 
 set first_name = 'HARPO' 
 where first_name = 'GROUCHO';

/*4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct
 name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`*/
 update actor 
 set first_name = 'GROUCHO' 
 where first_name = 'HARPO';

/*5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html]
(https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)*/
show create table address;

/*6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
Use the tables `staff` and `address`:*/
select s.first_name, s.last_name, a.address
from staff s
join address a
on s.address_id = a.address_id;

/*6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
Use tables `staff` and `payment`.*/
select s.first_name, s.last_name, sum(p.amount) as 'total amount rung'
from staff s JOIN payment p ON s.staff_id = p.staff_id
where payment_date between '2005-08-01' and '2005-08-31' 
group by s.first_name, s.last_name;

/*6c. List each film and the number of actors who are listed for that film. 
Use tables `film_actor` and `film`. Use inner join.*/
SELECT f.title, count(fa.actor_id) as 'number of actors'
FROM film f
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
group by f.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT title, count(i.inventory_id) as '# of film copies'
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
where title = 'Hunchback Impossible'
group by title ;

/*6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer.
 List the customers alphabetically by last name:*/

SELECT c.first_name, c.last_name, sum(p.amount) as 'total paid by customer'
FROM customer c
LEFT OUTER JOIN payment p
ON c.customer_id = p.customer_id
group by c.first_name, c.last_name
order by last_name;

/*7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity.
 Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English */
 select title as 'Movie Titles'
 from film 
 where language_id in 
 (select language_id from language where name = 'English') and (title like 'K%' or title like 'Q%');

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select first_name, last_name 
 from actor
 where actor_id in 
 (select actor_id from film_actor where  film_id in 
 (select film_id from film where  title = 'Alone Trip'));

/*7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
of all Canadian customers. Use joins to retrieve this information.*/
select concat(cr.first_name,' ', cr.last_name) as 'Canadian Customers', cr.email
from customer  cr
join address a 
	on cr.address_id = a.address_id
join city cty	
	on a.city_id = cty.city_id
join country co
	on cty.country_id = co.country_id
where country = 'Canada';

/*7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as _family_ films.*/
Select title as 'Family Films' 
from film f
join film_category fcat
	on f.film_id = fcat.film_id
join category cat 
	on fcat.category_id = cat.category_id
where cat.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
select f.title as 'Rented_Movies', count(r.inventory_id) as 'Rental_Frequency'
from rental r
join inventory i
	on r.inventory_id = i.inventory_id
join film f
	on i.film_id = f.film_id
Group by Rented_Movies 
order by Rental_Frequency desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select st.store_id, sum(p.amount) as 'store_revenue'
from payment p
join staff sf
	on p.staff_id = sf.staff_id
join store st
	on sf.store_id = st.store_id
group by st.store_id
order by store_revenue desc;

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, c.city, co.country 
from store s
join address a
	on s.address_id = a.address_id
join city c
	on a.city_id = c.city_id
join country co
	on c.country_id = co.country_id;
    
/* 7h. List the top five genres in gross revenue in descending order. 
(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)*/
select ca.name as 'Top_Five_Generes', sum(p.amount) as 'Gross_revenue'
from category ca
join film_category fc
	on ca.category_id = fc.category_id
join inventory i 
	on fc.film_id = i.film_id
join rental r 
	on i.inventory_id = r.inventory_id
join payment p 
	on r.rental_id = p.rental_id 
group by Top_Five_Generes
order by Gross_revenue desc limit 5;

/*8a. In your new role as an executive, you would like to have an easy way of viewing the Top five 
genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h,
 you can substitute another query to create a view.*/
create view genres_by_revenue as
(select ca.name as 'Top_Five_Generes', sum(p.amount) as 'Gross_revenue'
from category ca
join film_category fc
	on ca.category_id = fc.category_id
join inventory i 
	on fc.film_id = i.film_id
join rental r 
	on i.inventory_id = r.inventory_id
join payment p 
	on r.rental_id = p.rental_id 
group by Top_Five_Generes
order by Gross_revenue desc limit 5);

-- 8b. How would you display the view that you created in 8a?
select * from genres_by_revenue;
-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
Drop view genres_by_revenue;
-- ## Appendix: List of Tables in the Sakila DB

-- A schema is also available as `sakila_schema.svg`. Open it with a browser to view.



-- ## Uploading Homework

-- To submit this homework using BootCampSpot:

 -- Create a GitHub repository.
  -- Upload your .sql file with the completed queries.
 -- Submit a link to your GitHub repo through BootCampSpot.
