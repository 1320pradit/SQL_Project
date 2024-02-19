--Question Set 1 - Easy

-- Q1. Who is the senior most employee based on job title
SELECT * FROM employee 
ORDER BY levels DESC
LIMIT 1;

--Q2. Which countries have the most invoices
Select count(invoice_id),billing_country from invoice
Group by billing_country
order by count(invoice_id) DESC

--Q3.What are top 3 values of Total invoices
Select * from invoice
order by total desc
limit 3

-- Q4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made
-- the most money. Write a query that returns one city that hs the highest sum of invoice totals.Return both the city name
-- and sum of incvoice totals

Select sum(total),billing_city from invoice
group by billing_city
order by sum(total) desc


-- Q5.Who is the best customer? The customer who has spent the most money will be declared as the best customer. Write a query that
-- returns the person who has spent the most money
Select customer.customer_id,customer.first_name,customer.last_name,sum(invoice.total) as total
from customer 
join invoice
on customer.customer_id=invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

-- Question Set 2 - Moderate

-- Q1.Write query to return the email, first name, last name, and Genre of all the rock Music listeners. return your list ordered 
-- alphabetically by email starting with A
 
Select Distinct email,first_name,last_name
From customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in (
	Select track_id From track
	Join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
)
Order by email;

-- Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands
select artist.name,artist.artist_id,count(artist.artist_id) as number_of_song from  artist
join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_song Desc
limit 10

-- Q3. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track.
-- Order by the song length with the longest songs listed first
select name,milliseconds from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc

-- Question Set 3 - Advance

-- Q1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent?
with best_selling_artist as (
	select artist.name as artist_name, artist.artist_id as artist_id , sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by artist.artist_id
	order by total_sales desc
)
select c.customer_id,c.first_name,c.last_name,bsa.artist_name,sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc

-- Q2.We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount 
-- of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared
-- return all Genres
with popular_genre as (
Select count(invoice_line.quantity) as purchases , customer.country, genre.name,genre.genre_id,
row_number() over (partition by customer.country order by count(invoice_line.quantity) desc) as rowno
from Genre 
join track on genre.genre_Id = track.genre_ID
join invoice_line on track.track_id = invoice_line.track_id
join invoice on invoice_line.invoice_id = invoice.invoice_id
join customer on invoice.customer_id = customer.customer_id
group by 2,3,4
order by 2 asc, 1 desc
)
Select * from popular_genre where rowno<=1


-- Q3.Write a query to determine the customer that  has spent the most on music for each country. Write a query that returns the country 
-- along with the top customer and how much they spent.For countries where the top amount spent is shared, provide all customers who spent this
-- amount.
With recursive 
	customer_with_country as (
		Select customer.customer_id,first_name,last_name,billing_country, sum(total) as total_spending
		from invoice
		join customer on customer.customer_id = invoice.customer_id
		group by 1,2,3,4
		order by 5 desc,1),
		country_max_spending as (
		select billing_country , max(total_spending) as max_spending
			from customer_with_country
			group by billing_country
)
Select cc.billing_country,cc.total_spending,cc.first_name,cc.last_name,cc.customer_id
zcfrom customer_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1
																  
																  
																  
																  
																  
