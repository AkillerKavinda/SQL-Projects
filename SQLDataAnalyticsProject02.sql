-- SQL Retail Sales Analysis

-- Create Table

-- drop table if exists retail_sales;
create table retail_sales  	
			(
				transactions_id int primary key,
				sale_date date,
				sale_time time,
				customer_id int,
				gender varchar(15),
				age int,
				category varchar(15),
				quantity int,
				price_per_unit float,
				cogs float,
				total_sale float
				
			);

select * from retail_sales;

select * from retail_sales
limit 10;

select count(*) from retail_sales;

-- Data Cleaning

-- Finding null rows

select * from retail_sales
where transactions_id is null;

select * from retail_sales
where sale_date is null;

select * from retail_sales
where sale_time is null;

select * from retail_sales
where transactions_id is null
	or sale_date is null
	or sale_time isnull
	or customer_id is null
	or gender is null
	or age is null
	or category is null
	or quantity is null
	or price_per_unit is null
	or cogs is null
	or total_sale is null;

-- Deleting null rows

delete from retail_sales
where transactions_id is null
	or sale_date is null
	or sale_time isnull
	or customer_id is null
	or gender is null
	or age is null
	or category is null
	or quantity is null
	or price_per_unit is null
	or cogs is null
	or total_sale is null;

-- Data exploration

-- How many records do we have?

select count(*) total_records from retail_sales;

-- How many unique customers do we have?

select count(distinct customer_id) total_customers from retail_sales; 

-- How many categories do we have?

select count(distinct category) categories from retail_sales;

-- View the categories we have

select distinct category category_names from retail_sales;


-- Data Analysis

-- Q1. Write a SQL query to retrieve all columns for sales made on '2022-11-05:

select * from retail_sales
limit 1;

select * from retail_sales
where sale_date = '2022-11-05';

/* Q2. Write a SQL query to retrieve all transactions where the 
	   category is 'Clothing' and the quantity sold is more than or equal 4 in the month of Nov-2022:
*/

select * from retail_sales
where 
	category = 'Clothing' 
	and 
	to_char(sale_date,'YYYY-MM') = '2022-11'
	and quantity >= 4;

-- Q3. Write a SQL query to calculate the total sales (total_sale) for each category.:

select * from retail_sales;

select category, sum(total_sale) total_sales, count(*) total_orders
from retail_sales
group by category;

-- Q4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:

select * from retail_sales;

select category, avg(age) average_age
from retail_sales
group by category
having category = 'Beauty';

-- Q5. Write a SQL query to find all transactions where the total_sale is greater than 1000.:

select * 
from retail_sales
where total_sale > 1000;

-- Q6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:

select gender,category, count(*) total_transactions
from retail_sales
group by gender, category;

-- Q7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:

select * from retail_sales;

select year, month, avg_total_sale
from 
	(select
extract(year from sale_date) as year, 
extract(month from sale_date) as month, 
avg(total_sale) as avg_total_sale
from retail_sales
group by year, month)
order by year asc, month asc;

select year, month, avg_total_sale
from 
	(select
extract(year from sale_date) as year, 
extract(month from sale_date) as month, 
avg(total_sale) as avg_total_sale
from retail_sales
group by year, month
order by year asc, month asc);

select year, month, avg_total_sale
from (
    select
        extract(year from sale_date) as year,
        extract(month from sale_date) as month,
        avg(total_sale) as avg_total_sale
    from retail_sales
    group by year, month
) as monthly_avg
where (year, avg_total_sale) in (
    select year, max(avg_total_sale)
    from (
        select
            extract(year from sale_date) as year,
            extract(month from sale_date) as month,
            avg(total_sale) as avg_total_sale
        from retail_sales
        group by year, month
    ) as yearly_max
    group by year
)
order by year;

-- Q8. **Write a SQL query to find the top 5 customers based on the highest total sales **:

select * from retail_sales;

select customer_id, sum(total_sale) as total_sales
from retail_sales
group by customer_id
order by total_sales desc
limit 5;

-- Q9. Write a SQL query to find the number of unique customers who purchased items from each category.:

select * from retail_sales;

select category, count(distinct customer_id) as unique_customers
from retail_sales
group by category;


-- Q10. Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):

select * from retail_sales;

select *,
	case
		when extract(hour from sale_time) < 12 then 'Morning' 
		when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
		when extract(hour from sale_time) > 17 then 'Evening'
	end as shift
from retail_sales;

-- Method 1
select
	case
		when extract(hour from sale_time) < 12 then 'Morning' 
		when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
		when extract(hour from sale_time) > 17 then 'Evening'
	end as shift, 
	count(transactions_id) as num_orders
from retail_sales
group by case
		when extract(hour from sale_time) < 12 then 'Morning' 
		when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
		when extract(hour from sale_time) > 17 then 'Evening'
	end;

-- Method 2
select
	case
		when extract(hour from sale_time) < 12 then 'Morning' 
		when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
		when extract(hour from sale_time) > 17 then 'Evening'
	end as shift, 
	count(transactions_id) as num_orders
from retail_sales
group by 
	case
		when extract(hour from sale_time) < 12 then 'Morning' 
		when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
		when extract(hour from sale_time) > 17 then 'Evening'
	end;

-- Method 3 using a CTE

with shift_name as (select
	case
		when extract(hour from sale_time) < 12 then 'Morning' 
		when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
		when extract(hour from sale_time) > 17 then 'Evening'
	end as shift
from retail_sales)
select shift, count(*) as total_orders
from shift_name
group by shift;

-- End of the project



