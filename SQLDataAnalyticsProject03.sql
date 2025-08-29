-- SQL Mentor User Performance Analysis

-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)

select distinct user_id
from user_submissions;

select  username, count(id) as total_submissions, sum(points) as total_points
from user_submissions
group by username
order by total_submissions desc;


-- Q.2 Calculate the daily average points for each user.

select
	to_char(submitted_at, 'DD-MM') as day,
	username,
	avg(points) as daily_avg_points
from user_submissions
group by day, username
order by username;

-- Q.3 Find the top 3 users with the highest correct submissions for each day.

select * from user_submissions;

with daily_submissions 
as (
			select
			to_char(submitted_at, 'DD-MM') as daily,
			username,
			avg(points) as daily_avg_points,
			sum (case 
					when points > 0 then 1 else 0
				end) as correct_submissions
			from user_submissions
			group by daily, username
	),
users_rank as
(select 
	daily,
	username, 
	correct_submissions,
	dense_rank() over(partition by daily order by correct_submissions desc) as rank
from daily_submissions)

select 
	daily, 
	username, 
	correct_submissions
from users_rank
where rank <= 3;

-- Q.4 Find the top 5 users with the highest number of incorrect submissions.

select
	username,
	sum(
		case
			when points < 0 then 1 else 0
		end
	) as incorrect_submissions
from user_submissions
group by username
order by incorrect_submissions desc
limit 5;


select
    username,
    sum(case when points < 0 then 1 else 0 end) as incorrect_submissions,
    sum(case when points > 0 then 1 else 0 end) as correct_submissions,
    sum(points) as points_earned,
    sum(case when points > 0 then points else 0 end) as correct_submissions_points,
    sum(case when points < 0 then points else 0 end) as incorrect_submissions_points
from
    user_submissions
group by
    username
order by
    incorrect_submissions desc
limit 5;

-- Q.5 Find the top 10 performers for each week.


select * from user_submissions;

select username, extract(week from submitted_at)
from user_submissions;

select *,
extract(week from submitted_at)
from user_submissions;

select * 
from (select 
	extract(week from submitted_at) as week_no,
	username, sum(points) as total_points,
	dense_rank() over(partition by extract(week from submitted_at) order by sum(points) desc) as rank
from user_submissions
group by week_no, username
order by week_no, total_points desc)
where rank <= 10;
