
--- Creating database
CREATE DATABASE MUSIC_STORE;

--- Working inside the database
USE MUSIC_STORE;

--- Query-1:Who is the senior most employee based on job title?
 
SELECT TOP(1) first_name,last_name,title,levels FROM employee$ ORDER BY levels DESC ;
 
----------------------------------------------------------------------------------------------------------------------------------
--- Query-2: Which countries have the most invoices?

SELECT TOP(1) billing_country, COUNT(*) No_of_billing from invoice$ group by billing_country order by 2 desc;

-------------------------------------------------------------------------------------------------------------------------------------------------------
--- Query-3: What are the top 3 values of total invoice?

SELECT TOP(3) invoice_id , round((total),1) as total FROM invoice$ order by 2 desc

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Query-4: Which city has the best customers? We would like to throw a promotional music festival in the city we made the most money.
---Write a query that returns one city that has the highest sum of invoice totals. Return both the city name and sum of all invoice totals.

 SELECT TOP(1) billing_city, sum(total) total_of_billing from invoice$ group by billing_city order by 2 desc;

------------------------------------------------------------------------------------------------------------------------------------------------------
--- Query-5 Who is the best customer? The customer who has spent the most money will be declared as the best customer.

 select top(1) customer$.customer_id,first_name,last_name, sum(total) total_of_billing from invoice$ 
 join customer$ on customer$.customer_id = invoice$.customer_id
 group by customer$.customer_id,first_name,last_name
 order by 4 desc;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Query-6 A query to return the email,firstname,lastname & genre of all rock musiclistners.Return ur list order alphabatically by email starting with A

select DISTINCT c.email,c.first_name,c.last_name from customer$ c
join invoice$ as i on c.customer_id = i.customer_id 
join invoice_line$  as il on i.invoice_id = il.invoice_id 
join track$ as t on t.track_id = il.track_id 
join genre$ as g on g.genre_id = t.genre_id 
where g.name = 'Rock'
group by c.email,c.first_name,c.last_name
order by c.email;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Query-7 Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the artist name and total track count of the top 10 rock bands.

select TOP(10) a.artist_id,a.name,count(*) as Total_no_of_tracks from  artist$ as a
join album$ as  al on a.artist_id = al.artist_id 
join track$  as t  on al.album_id = t.album_id 
join genre$ as g on g.genre_id = t.genre_id 
where g.name = 'Rock'
group by a.artist_id,a.name
order by 3 desc

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Query-8 Return  all the tracks names that have a song length longer than the average song length.
-- Return the name and milliseconds for the each track. Order by the song length with the longest songs listed first.
select name,milliseconds from track$
where milliseconds > (select avg(milliseconds) avg_song_length from  track$)
order by milliseconds desc

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Query-9 Find how much amount spent by each customer on the best sellling artists? 
 --	Write a query to return customer name , artist name and total spent.

 select c.customer_id,c.first_name,c.last_name,sum(il.unit_price*il.quantity) as Total_Amt_Spent, 
 ( 
 select top (1) a.name from  customer$ c
join invoice$ as i on c.customer_id = i.customer_id 
join invoice_line$  as il on i.invoice_id = il.invoice_id 
join track$ as t on t.track_id = il.track_id 
join album$ as  al on t.album_id = al.album_id 
join artist$ as a on a.artist_id = al.album_id
group by a.name
order by sum(il.unit_price*il.quantity)
) as best_artist 
from  customer$ c
join invoice$ as i on c.customer_id = i.customer_id 
join invoice_line$  as il on i.invoice_id = il.invoice_id 
join track$ as t on t.track_id = il.track_id 
join album$ as  al on t.album_id = al.album_id 
join artist$ as a on a.artist_id = al.album_id
group by c.first_name,c.last_name
order by 3 desc


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Query-10 We want to find out the most popular music genre for each country. We determine the most popular genre as genre with the 
     -- highest amount of purchases. 
	 --A. Write a query that returns each country along with the top genre.
select * from(
select *,ROW_NUMBER() over(partition by billing_country order by cnt desc) as rnk from
( 
select i.billing_country, g.name, count(il.quantity) as cnt from invoice$ as i 
join invoice_line$  as il on i.invoice_id = il.invoice_id 
join track$ as t on t.track_id = il.track_id 
join genre$ as g on g.genre_id = t.genre_id 
group by i.billing_country,g.name 
) as t1
) as t2 where rnk=1;

---------------------------------------------------------OR--------------------------------------------------------------------------

 With popular_genre AS (
     SELECT COUNT(il.quantity) AS purchases, 
	             c.country, 
				 g.name, 
				 g.genre_id,
 	             ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS RowNo 
    FROM invoice_line$ il
 	JOIN invoice$ i ON i.invoice_id = il.invoice_id
 	JOIN customer$ c ON c.customer_id = i.customer_id
 	JOIN track$ t ON t.track_id = il.track_id
 	JOIN genre$ g ON g.genre_id = t.genre_id
 	GROUP BY c.country, g.name, g.genre_id 
 )
	
 select * from popular_genre 
 where rowno <=1
 	ORDER BY country ASC, purchases DESC

--B. For countries where maximum number of purchases is shared return all genres.
select g.name, count(il.quantity) as cnt from invoice$ as i 
join invoice_line$  as il on i.invoice_id = il.invoice_id 
join track$ as t on t.track_id = il.track_id 
join genre$ as g on g.genre_id = t.genre_id  
where i.billing_country = ( select top(1) i.billing_country from invoice$ as i 
                              join invoice_line$  as il on i.invoice_id = il.invoice_id 
                              group by i.billing_country
                              order by  count(il.invoice_line_id) desc  )
group by g.name
order by 2 desc

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Query-11 Write a query that determines the customer that has spent the most on music for each country.
--      Write a query that returns the country along with the top customer and how much they spent. 
--      For countries where the to amount spent is shared, provide all customers who spent this amount.;

select customer_id,first_name,last_name from customer$;
select distinct billing_country from invoice$;
select sum(unit_price*quantity) from invoice_line$

create view customer_country1 as
   (select c.customer_id,
           CONCAT(c.first_name,' ',c.last_name) as c_name ,
		   i.billing_country,
		  round(( SUM(il.unit_price*il.quantity)),1) as Total_amt_spent
     from 
	       customer$ as c 
           join invoice$ as i on c.customer_id = i.customer_id 
           join invoice_line$  as il on i.invoice_id = il.invoice_id
     group by c.customer_id, c.first_name, c.last_name, i.billing_country)
   
create view best_customer as
(
	select c.customer_id,
           CONCAT(c.first_name,' ',c.last_name) as c_name ,
		   round(( SUM(il.unit_price*il.quantity)),1) as Total_amt_spent
     from 
	       customer$ as c 
           join invoice$ as i on c.customer_id = i.customer_id 
           join invoice_line$  as il on i.invoice_id = il.invoice_id
     group by 
	       c.customer_id, 
		   c.first_name, 
		   c.last_name 
	order by 
	       SUM(il.unit_price*il.quantity) desc  )

create view best_country2 as
(
	select i.billing_country,c.customer_id,
		   round(( SUM(il.unit_price*il.quantity)),1) as Total_amt_spent
     from 
	       customer$ as c 
           join invoice$ as i on c.customer_id = i.customer_id 
           join invoice_line$  as il on i.invoice_id = il.invoice_id
     group by 
	        i.billing_country,c.customer_id
			)

-- Top customer with all countries & total amount spent
select distinct billing_country, bc.customer_id,bc.c_name,bc.Total_amt_spent from invoice$ i
         join best_customer bc on i.customer_id=bc.customer_id

-- Top customer with top country and total amount spent
select top(1)  billing_country, bc.customer_id,bc.c_name,bc.Total_amt_spent from invoice$ i
         join best_customer bc on i.customer_id=bc.customer_id	

-- Top country with total amount spent by all the cutsomers
create view top_country as 
(select top (1) bc.billing_country,sum(bc.Total_amt_spent) as Total_amt_spent
      from best_country2 as bc
      join customer_country1 as cc on bc.customer_id=cc.customer_id
	  group by bc.billing_country
order by 2 desc);

-- Best country With all its cutsomers and total amount spent by each customer in that country
select c.customer_id,
       CONCAT(c.first_name,' ',c.last_name) as c_name, 
	   tc.billing_country,
	   round((sum(il.unit_price*il.quantity)),1) as total_amt_spent 
from top_country tc 
     join invoice$ i  on  tc.billing_country=i.billing_country
     join invoice_line$  as il on i.invoice_id = il.invoice_id
     join customer$ c on c.customer_id = i.customer_id
group by
     c.customer_id,
	 tc.billing_country,
	 c.first_name,
	 c.last_name



	 
  SELECT * FROM (
 		SELECT customer$.customer_id,
		       first_name,
			   last_name,
			   billing_country,
			   SUM(total) AS total_spending,
 	           ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
 		FROM invoice$
 		     JOIN customer$ ON customer$.customer_id = invoice$.customer_id
 		GROUP BY customer$.customer_id,
		         first_name,
				 last_name,
				 billing_country
 		)
Customter_with_country 
WHERE RowNo <= 1 
ORDER BY 4 ASC,5 DESC


