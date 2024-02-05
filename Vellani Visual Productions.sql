USE imdb;

-- Total number of rows in each table of the schema?


select count(*) from director_mapping;
select count(movie_id) from director_mapping;

-- total number of columns in the movie column is 3867;

-- Columns in the movie table have null values?


show columns from movie;

select  count(*) - count(title) as title,
	    count(*) - count(year) as year,
        count(*) - count(date_published) as date_published,
		count(*) - count(duration) as duration,
		count(*) - count(country) as country,
		count(*) - count(worlwide_gross_income) as worlwide_gross_income,
		count(*) - count(languages) as languages,
		count(*) - count(production_company)  as production_company
from movie;

/*  so here three columns named as worlwid_gross_income, languages, production_company have null values;*/


-- movie released by year

select  year, 
		count(id) as no_movie_released
from movie
group by year;

-- movies released by months

select 	month(date_published),
		count(id) as no_movie_released
from movie
group by month(date_published)
order by no_movie_released desc;


-- The highest number of movies is produced in the month of March.


-- Movies were produced in the USA or India in the year 2019.

select count(id) 
from movie 
where year = '2019' and country  in ('india', 'usa');

-- USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.

-- Unique list of the genres present in the data set.

select distinct(genre) from genre;


-- So, VVP plans to make a movie of one of these genres.

-- Genre that had highest number of movies produced overall.

select * from genre;

select 	g.genre, 
		count(m.id) as no_of_movies
from genre g inner join movie m on g.movie_id = m.id
group by g.genre;


/* So, based on the insight that you just drew, VVP should focus on the ‘Drama’ genre. 

-- Movies belong to only one genre*/

select count(movie_id) 
from (
		select  movie_id, 
				count(movie_id) as diff_genre
		from genre
		group by movie_id
		having diff_genre = 1) 
as total_movie;

-- 3289 movies having unique genre

with unique_genre as(
						select  movie_id, 
								count(movie_id) as diff_genre
						from genre
						group by movie_id
						having diff_genre = 1
					)
                    

select  genre, 
		count(g.movie_id) as no_of_movie
from genre g join unique_genre u on g.movie_id = u.movie_id
group by genre;

-- Here in both the senario(unique genre and more then one genre movies) Drama genre movie are leading among all genres.


/* There are more than three thousand movies which has only one genre associated with them.

Now, let's find out the possible duration of VVP next project.*/

-- Average duration of movies in each genre.

select 	g.genre,
		avg(m.duration) as avg_duration
from movie m inner join genre g on m.id = g.movie_id
group by g.genre;


-- Movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.

-- Rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced.

select * from (
				select 	genre,
						count(movie_id) as total_movies, 
						row_number() over(order by count(movie_id) desc) as rnk
				from genre
				group by genre) 
as result 
where genre = 'Thriller';


-- Thriller movies is in top 3 among all genres in terms of number of movies
 

-- Q10.  Minimum and maximum values in  each column of the ratings table except the movie_id column.


select  min(avg_rating) as min_avg_rating,
		max(avg_rating) as max_avg_rating,
        min(total_votes) as min_total_votes,
        max(total_votes) as max_total_votes,
        min(median_rating) as min_median_rating,
        max(median_rating) as max_median_rating
from ratings;


/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. */


-- Top 10 movies based on average rating.

select * from (select 	m.title, 
		r.avg_rating, 
		row_number() over(order by r.avg_rating desc) as movie_rank
from movie m inner join ratings r on m.id = r.movie_id
group by m.title, r.avg_rating) as res where movie_rank <= 10;


/* Favourite movie FAN in the top 10 movies with an average rating of 9.6.

-- Summarise the ratings table based on the movie counts by median ratings.*/

select  median_rating, 
		count(movie_id) as movie_count
from ratings 
group by median_rating
order by median_rating;


/* Movies with a median rating of 7 is highest in number. 


-- Production house has produced the most number of hit movies (average rating > 8).*/


select 	m.production_company, 
		count(m.id) as movie_count,
        row_number() over (order by count(m.id) desc) as prod_company_rank
from movie m inner join ratings r on m.id = r.movie_id
where r.avg_rating > 8 and production_company is not null
group by m.production_company;

-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Movies released in each genre during March 2017 in the USA had more than 1,000 votes.


select  g.genre, 
		count(m.id) as movie_count
from movie m 
	inner join ratings r on m.id = r.movie_id 
    inner join genre g on r.movie_id = g.movie_id
where month(m.date_published) = 3 and m.year = 2017 and m.country = 'USA' and r.total_votes > 1000
group by g.genre;


-- Movies of each genre that start with the word ‘The’ and which have an average rating > 8

select  m.title, 
		r.avg_rating,
        g.genre
from movie m inner join genre g on m.id = g.movie_id inner join ratings r on m.id = r.movie_id
where r.avg_rating >= 8 and m.title like ("The %");


-- Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8

select  r.median_rating,
		count(m.id) as total_movie
from movie m inner join ratings r on m.id = r.movie_id
where r.median_rating >= 8 and date_published between '2018-04-01' and '2019-04-01'
group by r.median_rating;


--  Do German movies get more votes than Italian movies
--  Here you have to find the total number of votes for both German and Italian movies.

select 	m.country, 
		sum(r.total_votes) as total_votes ,
        rank() over(order by sum(r.total_votes) desc) as voting_rank
from movie m inner join ratings r on m.id = r.movie_id
where m.country like ( "Germany")  or m.country like ("Italy")
group by m.country;


-- Answer is Yes


-- Columns in the names table have null values.

select 	count(*) - count(name) as name_nulls,
		count(*) - count(height) as height_nulls,
        count(*) - count(date_of_birth) as date_of_birth_nulls,
        count(*) - count(known_for_movies) as known_for_movies_nulls
from names;

select count(*) as name_nulls from names where name is null;
select count(*) as height_nulls from names where height is null;
select count(*) as date_of_birth_nulls from names where date_of_birth is null;
select count(*) as known_for_movies_nulls from names where known_for_movies is null;


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Top three directors in the top three genres whose movies have an average rating > 8.
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)

with top3_genre as (
					select genre from (
									select genre, 
									count(movie_id) as total_movie,
									row_number() over(order by count(movie_id) desc) as genre_ranking
									from genre 
									group by genre
                                    ) 
					as top3
					where genre_ranking <= 3
)

select name, total_movies from (
				select n.name,
					   count(g.movie_id) as total_movies,
					   row_number() over(partition by genre order by count(g.movie_id) desc) as director_ranking
        
				from names n inner join director_mapping d on n.id = d.name_id 
							 inner join genre g on d.movie_id = g.movie_id
							 inner join ratings r on r.movie_id = g.movie_id            
				where r.avg_rating > 8 and genre in (select genre from top3_genre)
				group by g.genre, n.name) as res
		where director_ranking <= 3 
        order by total_movies desc;


/* James Mangold can be hired as the director for VVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 

-- Top two actors whose movies have a median rating >= 8.*/

select * from (
				select  n.name, 
						count(m.movie_id) as total_movies,
						row_number() over(order by count(m.movie_id) desc) as actor_ranking
				from role_mapping m inner join  ratings r on m.movie_id = r.movie_id 
									inner join names n on m.name_id = n.id
				where m.category = "Actor" and r.median_rating >= 8
				group by n.name
) as fav_actor
where actor_ranking <=2 ;


/*  favourite actor is 'Mohanlal' . If no, please check your code again. 
 VVP plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Top three production houses based on the number of votes received by their movies.


select * from (
				select m.production_company, 
						sum(r.total_votes) as vote_count,
						dense_rank() over(order by sum(r.total_votes) desc) as prod_comp_rank
				from movie m inner join ratings r on m.id = r.movie_id
				group by m.production_company
) 
as top3_prod_company
where prod_comp_rank <= 3;


/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since VVP is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel.*/

-- Rank actors with movies released in India based on their average ratings and actor is at the top of the list.
--  The actor should have acted in at least five Indian movies. 
--  You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

 /* weighted mean - The weighted arithmetic mean is similar to an ordinary arithmetic mean, 
 except that instead of each of the data points contributing equally to the final average, 
 some data points contribute more than others. This is calculate when the results have some biased 
 value like in this case some actors may have less avg_rating but more total_votes and vice versa 
 so to avoid this we calculate weighted mean.
 
 w(weighted mean) = sum of (weight * quantity)/sum of weight */
 
 
with Indian_actors as (
				select  n.name, 
						t.*,
                        (t.total_votes * t.avg_rating) as weighted_mean
						from role_mapping r inner join movie m on r.movie_id = m.id 
											inner join names n on n.id = r.name_id
                                            inner join ratings t on t.movie_id = r.movie_id
						where r.category = "Actor" and m.country = "India"
			)
            
select  name, 
		sum(total_votes) as total_votes, 
		count(movie_id) as movie_count, 
		avg(avg_rating) as actor_avg_rating,
        dense_rank() over(order by sum(weighted_mean)/sum(total_votes)desc) as actor_rank
from Indian_actors 
group by name 
having count(movie_id) >= 5;
		
-- Top actor is Vijay Sethupathi

-- The top five actresses in Hindi movies released in India based on their average ratings. 
-- Note: The actresses should have acted in at least three Indian movies. 
-- You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)


with Indian_actresses as (
				select  n.name, 
						t.*,
                        (t.total_votes * t.avg_rating) as weighted_mean
						from role_mapping r inner join movie m on r.movie_id = m.id 
											inner join names n on n.id = r.name_id
                                            inner join ratings t on t.movie_id = r.movie_id
						where r.category = "actress" and m.country = "India" and m.languages = "Hindi"
			)
            
select  name, 
		sum(total_votes) as total_votes, 
		count(movie_id) as movie_count, 
		avg(avg_rating) as actor_avg_rating,
        dense_rank() over(order by sum(weighted_mean)/sum(total_votes)desc) as actress_rank
from Indian_actresses 
group by name 
having count(movie_id) >= 3;


/* Taapsee Pannu tops with average rating 7.74. 

/* Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/

select m.title, case when r.avg_rating > 8 then "Superhit movies" 
			when r.avg_rating between 7 and 8 then "Hit movies"
			when r.avg_rating between 5 and 7 then "One-time-watch movies"
			when r.avg_rating < 5 then "Flop movies"
			end as category 
from genre g inner join ratings r on g.movie_id = r.movie_id inner join movie m on m.id = r.movie_id
where g.genre = "Thriller";


--  Genre-wise running total and moving average of the average movie duration. 

select 	g.genre, 
		round(avg(m.duration)) as avg_duration,
        sum(round(avg(m.duration))) over (partition by g.genre order by avg(m.duration) rows between unbounded preceding and current row) as running_total_duration,
        round(avg(avg(m.duration)) over (partition by g.genre order by avg(m.duration) rows between unbounded preceding and current row)) as running_avg_duration
from genre g inner join ratings r on g.movie_id = r.movie_id inner join movie m on m.id = r.movie_id
group by g.genre, m.duration;


--  Five highest-grossing movies of each year that belong to the top three genres. 
-- (Note: The top 3 genres would have the most number of movies.)




-- Top 3 Genres based on most number of movies

with top3_genre as (
					select * from (
									select 	genre, 
											count(genre),
											row_number() over(order by count(genre) desc) as ranking
									from genre 
									group by genre
								) 
					as top3
					where ranking <= 3
)

select  g.genre, 
		m.year,        
		m.title, 
		case when worlwide_gross_income like"%INR%" then replace (worlwide_gross_income, "INR", "$")
        else worlwide_gross_income end 
        as worlwide_gross_income, 
		dense_rank() over(order by worlwide_gross_income desc) as movie_rank
        
from movie m inner join genre g on m.id = g.movie_id
where g.genre in (select genre from top3_genre)
group by g.genre, m.year, m.title, worlwide_gross_income;


-- Top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies.


select * from (select  m.production_company,
						count(id) as movie_count, 
						dense_rank() over(order by count(id) desc)  as prod_comp_rank
				from movie m inner join ratings r on m.id = r.movie_id
				where median_rating >= 8 and languages like "%,%" and production_company is not null
				group by m.production_company
                )
as top2_production_company
where prod_comp_rank <= 2;


-- Top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre.

select * from (
				select  n.name as actress_name, 
						count(r.total_votes) as total_votes, 
						count(g.movie_id) as movie_count,
						avg(r.avg_rating) as actress_avg_rating,
						dense_rank() over(order by count(r.movie_id)desc) as actress_ranking
                        
				from genre g inner join ratings r on g.movie_id = r.movie_id 
							 inner join role_mapping m on m.movie_id = r.movie_id
							 inner join names n on n.id = m.name_id
                            
				where m.category = "Actress" and r.avg_rating >= 8 and g.genre = "Drama"
				group by n.name
                )
as top3_actress
where actress_ranking <= 3;


/* Details of top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations */

select * from (
			with movie_with_lagging_date as (
								select *,
										abs(datediff( m.date_published, coalesce(lag(m.date_published) over(order by d.name_id), 1))) as pre_released_date
								from movie m inner join director_mapping d on m.id = d.movie_id
			)

			select  d.name_id as director_id,
					n.name as director_name,
					count(m.id) as no_of_movies,
					round(avg(m.pre_released_date),0) as avg_inter_movie_days,
					avg(r.avg_rating) as avg_rating,
					sum(r.total_votes) as total_votes,
					min(r.avg_rating) as min_rating,
					max(r.avg_rating) as max_rating,
					sum(m.duration) as total_duration,
					row_number() over(order by count(m.id) desc) as director_ranking
					
			from  movie_with_lagging_date m inner join director_mapping d on m.id = d.movie_id
						  inner join ratings r on m.id = r.movie_id
						  inner join names n on n.id = d.name_id
						  
			group by d.name_id, n.name
)
as top9_director 
where director_ranking <= 9;





