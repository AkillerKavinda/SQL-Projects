-- Create a practice table
CREATE TABLE netflix_practice (
    show_id SERIAL PRIMARY KEY,
    type VARCHAR(20),          -- Movie or TV Show
    title VARCHAR(100),
    country VARCHAR(100),      -- Multiple countries separated by commas
    duration VARCHAR(20),      -- '90 min' or '5 Seasons'
    listed_in VARCHAR(100),    -- Genres, comma separated
    director VARCHAR(100),     -- Multiple directors separated by commas
    casts VARCHAR(200),        -- Multiple actors separated by commas
    date_added VARCHAR(50),    -- e.g., 'September 9, 2020'
    release_year INT,
    description TEXT
);

-- Insert sample data
INSERT INTO netflix_practice (type, title, country, duration, listed_in, director, casts, date_added, release_year, description) VALUES
('Movie', 'Movie A', 'India, United States', '120 min', 'Action, Thriller', 'Rajiv Chilaka', 'Salman Khan, John Doe', 'January 15, 2022', 2022, 'A thrilling action movie with some violence.'),
('Movie', 'Movie B', 'United Kingdom', '90 min', 'Documentaries', 'Alice Smith', 'Jane Doe', 'March 10, 2020', 2020, 'An inspiring documentary.'),
('TV Show', 'Show A', 'India', '6 Seasons', 'Comedy, Family', 'Rajiv Chilaka', 'Actor 1, Actor 2', 'July 5, 2019', 2019, 'A fun family comedy show.'),
('TV Show', 'Show B', 'United States', '3 Seasons', 'Drama', 'Bob Brown', 'Actor 3, Actor 4', 'December 1, 2021', 2021, 'A dramatic story with some killings.'),
('Movie', 'Movie C', 'India', '150 min', 'Action, Drama', NULL, 'Salman Khan, Actor 5', 'May 20, 2018', 2018, 'High-octane action movie.');


-- =========================================
-- 1. basic select and viewing the table
-- =========================================
select * from netflix_practice;

-- count how many of each type are there
select type, count(*) 
from netflix_practice
group by type;

-- =========================================
-- 2️. working with strings and arrays
-- =========================================
-- split countries into individual rows
select *, unnest(string_to_array(country, ',')) as country
from netflix_practice;

-- extract numeric part of duration for movies
select *, split_part(duration, ' ', 1)::int as duration_in_min
from netflix_practice
where type = 'movie';

-- extract numeric part of duration for tv shows
select *, split_part(duration, ' ', 1)::int as num_of_seasons
from netflix_practice
where type = 'tv show';

-- =========================================
-- 3️. filtering with like / ilike
-- =========================================
-- find all documentaries (case sensitive)
select *
from netflix_practice
where listed_in like '%documentaries';

-- find all documentaries (case insensitive)
select *
from netflix_practice
where listed_in ilike '%documentaries';

-- =========================================
-- 4️. working with dates
-- =========================================
-- filter content added in the last 5 years
select *
from netflix_practice
where to_date(date_added, 'month dd, yyyy') >= current_date - interval '5 years';

-- extract year, month, day
select 
    extract(year from to_date(date_added, 'month dd, yyyy')) as year,
    extract(month from to_date(date_added, 'month dd, yyyy')) as month,
    extract(day from to_date(date_added, 'month dd, yyyy')) as day
from netflix_practice;

-- filter by specific year / month / day
select *
from netflix_practice
where extract(year from to_date(date_added, 'month dd, yyyy')) = 2020;

select *
from netflix_practice
where extract(month from to_date(date_added, 'month dd, yyyy')) = 3;

select *
from netflix_practice
where extract(day from to_date(date_added, 'month dd, yyyy')) = 15;

-- =========================================
-- 5️. case when
-- =========================================
-- categorize type
select type,
       case 
           when type = 'movie' then 'film'
           else 'series'
       end as category
from netflix_practice;

-- categorize duration
select title, type,
       case
           when type = 'movie' and split_part(duration, ' ', 1)::int > 100 then 'long movie'
           when type = 'movie' then 'short movie'
           else 'tv show'
       end as duration_category
from netflix_practice;

-- categorize content based on keywords
select title,
       case
           when description ilike '%kill%' or description ilike '%violence%' then 'bad'
           else 'good'
       end as category
from netflix_practice;

-- =========================================
-- 6️. coalesce / ifnull
-- =========================================
-- replace null directors with 'unknown'
select title, coalesce(director, 'unknown') as director_name
from netflix_practice;

-- =========================================
-- 7️. datediff (date difference)
-- =========================================
select title,
       current_date - to_date(date_added, 'month dd, yyyy') as days_since_added
from netflix_practice;

-- =========================================
-- 8️. concat
-- =========================================
-- combine title and type
select concat(title, ' - ', type) as full_title
from netflix_practice;

-- postgres alternative
select title || ' - ' || type as full_title
from netflix_practice;

-- =========================================
-- 9️. aggregate functions and group by
-- =========================================
-- count content by genre
select unnest(string_to_array(listed_in, ',')) as genre,
       count(*) as total_content
from netflix_practice
group by genre;

-- average duration of movies
select avg(split_part(duration, ' ', 1)::int) as avg_duration
from netflix_practice
where type = 'movie';

-- =========================================
-- 10. window functions
-- =========================================
-- rank tv shows by number of seasons
select title,
       split_part(duration, ' ', 1)::int as num_of_seasons,
       rank() over (order by split_part(duration, ' ', 1)::int desc) as rank
from netflix_practice
where type = 'tv show';

-- cumulative sum example
select type, title,
       sum(split_part(duration, ' ', 1)::int) over (partition by type order by title) as cumulative_duration
from netflix_practice;

-- =========================================
-- 1️1. common table expressions (ctes)
-- =========================================
-- count content by country
with countrycount as (
    select unnest(string_to_array(country, ',')) as country,
           count(*) as total_content
    from netflix_practice
    group by country
)
select *
from countrycount
order by total_content desc;

-- top 2 directors by number of movies
with directorcount as (
    select unnest(string_to_array(director, ',')) as director_name,
           count(*) as total_movies
    from netflix_practice
    where type = 'movie'
    group by director_name
)
select *
from directorcount
order by total_movies desc
limit 2;

-- =========================================
-- 1️2. recursive ctes
-- =========================================
-- generate numbers 1 to 10
with recursive numbers(n) as (
    select 1
    union all
    select n + 1
    from numbers
    where n < 10
)
select * from numbers;

-- generate years from earliest release_year to 2022
with recursive year_series as (
    select min(release_year) as year
    from netflix_practice
    union all
    select year + 1
    from year_series
    where year + 1 <= 2022
)
select *
from year_series;

-- =========================================
-- 1️3. subqueries
-- =========================================
-- scalar subquery: movies longer than average
select title, duration
from netflix_practice
where split_part(duration, ' ', 1)::int > (
    select avg(split_part(duration, ' ', 1)::int)
    from netflix_practice
    where type = 'movie'
);

-- in / column subquery: movies from countries with more than 1 content item
select *
from netflix_practice
where 'india' in (
    select unnest(string_to_array(country, ','))
    from netflix_practice
    group by 1
    having count(*) > 1
);

-- exists subquery: movies with salman khan
select *
from netflix_practice n
where exists (
    select 1
    from netflix_practice
    where casts ilike '%salman khan%'
      and title = n.title
);

-- correlated subquery: movies longer than average duration for their country
select title, country, split_part(duration, ' ', 1)::int as duration_min
from netflix_practice n1
where split_part(duration, ' ', 1)::int > (
    select avg(split_part(duration, ' ', 1)::int)
    from netflix_practice n2
    where n2.type = 'movie'
      and n2.country ilike '%' || n1.country || '%'
);

-- =========================================
-- 1️4. extra examples
-- =========================================
-- ranking by movie duration
with movieduration as (
    select title, split_part(duration, ' ', 1)::int as duration_min
    from netflix_practice
    where type = 'movie'
)
select title, duration_min,
       rank() over (order by duration_min desc) as rank
from movieduration;

-- count content by genre (alternative)
select genre, count(*) as total_content
from (
    select unnest(string_to_array(listed_in, ',')) as genre
    from netflix_practice
) as genre_table
group by genre;


-- Hard question 

with genre_counts as (
    select 
        type,
        unnest(string_to_array(listed_in, ',')) as genre,
        count(*) as genre_count
    from netflix_practice
    group by type, genre
),
ranked_genres as (
    select 
        type,
        genre,
        genre_count,
        rank() over (partition by type order by genre_count desc) as rank
    from genre_counts
)
select 
    type,
    genre as most_frequent_genre
from ranked_genres
where rank = 1;



