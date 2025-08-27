-- Dataset Link - https://maven-datasets.s3.amazonaws.com/Restaurant+Orders/Restaurant+Orders+CSV.zip

/*
You've just been hired as a Data Analyst for the Taste of the World Cafe,
 a restaurant that has diverse menu offerings and serves generous portions.

The Taste of the World Cafe debuted a new menu at the start of the year. 
You've been asked to dig into the cusotmer data to see which menu items are doing well/ 
not well and what the top customers seem to like best. 

*/

/*

Objectives,

1. Explore the menu_items table to get an idea of what's on the new menu
2. Explore the order_details table to get an idea of the data that's been collected
3. Use both tables to understand how customers reacting to the new menu

*/

create database restaurant_orders;

-- View the menu items table and write a query to find the number of items on the menu

select count(*) from menu_items;

-- What are the least and most expensive items on the menu?

select * from menu_items;

select item_name, min(price)
from menu_items
group by item_name
order by min(price)
limit 1;

select item_name, max(price)
from menu_items
group by item_name
order by max(price) desc
limit 1;

-- How many Italian dishes are on the menu? What are the least and most expensive Italian dishes are on the menu?

select count(*) from menu_items
where category = 'Italian';

select item_name, min(price)
from menu_items
where category = 'Italian'
group by item_name
order by min(price)
limit 1;

select item_name, max(price)
from menu_items
where category = 'Italian'
group by item_name
order by max(price) desc
limit 1; 

-- How many dishes are in each category?

select * from menu_items;

select category, count(item_name) 
from menu_items
group by category;

-- What is the average price within each category?

select category, round(avg(price),2)
from menu_items
group by category;

-- View the order_details table. What is the data range of the table? 

select * from order_details;

select min(order_date), max(order_date)
from order_details;

-- How many orders were made within this data range? 

select * from order_details;

select count(distinct order_id) 
from order_details;

-- How many items were ordered within this date range? 

select * from order_details;

select count(item_id)
from order_details;

-- Which orders had the most number of items?

select * from order_details;

select order_id, count(item_id) as item_count
from order_details
group by order_id
having item_count = 14
order by item_count desc
;

-- How many orders had more than 12 items?

select count(*) as order_with_more_than_12_items
from 
(select order_id, count(item_id) as item_count
from order_details
group by order_id) order_item_count
where item_count > 12;

-- Combine the menu_items and order_details tables into a single table


select * from menu_items;
select * from order_details;

select * from menu_items m
join order_details o
on m.ï»¿menu_item_id = o.item_id;

-- What were the least and most ordered items? What categories were they in? 

select * from menu_items;

select * from order_details;

select item_id, count(item_id)
from order_details
group by item_id
order by count(item_id) desc;

-- Most ordered item with it's category
select item_name, category
from menu_items
where ï»¿menu_item_id = (select item_id from (
select item_id, count(item_id)
from order_details
group by item_id
order by count(item_id) desc
limit 1) a ) ;

select item_id, count(item_id)
from order_details
group by item_id
order by count(item_id) desc
limit 1;

-- Least ordered item with its category
select item_name, category
from menu_items
where ï»¿menu_item_id = (select item_id from (
select item_id, count(item_id)
from order_details
group by item_id
order by count(item_id) 
limit 1 offset 1) a ) ;

-- All the info about the most sold and and least sold items with their category and name. 
select item_name, category, count(item_name)
 from menu_items m
join order_details o
on m.ï»¿menu_item_id = o.item_id
group by item_name, category
order by count(item_name) desc;

-- What were the top 5 orders that spent the most money?
select * from order_details;
select * from menu_items;

select * from order_details;

select order_id, sum(item_id * price)
from order_details o
join menu_items m
on m.ï»¿menu_item_id = o.item_id
group by order_id
order by sum(item_id * price) desc
limit 5;

-- View the details of the highest spent order

select category, count(item_id) as num_items
from order_details o
join menu_items m
on m.ï»¿menu_item_id = o.item_id
where order_id = 440
group by category;

select * from menu_items;
select * from order_details;

select category, count(item_id) as num_items
from order_details o
join menu_items m
on m.ï»¿menu_item_id = o.item_id
where order_id in (440, 2075, 1957, 330, 2675)
group by category;

select order_id, category, count(item_id) as num_items
from order_details o
join menu_items m
on m.ï»¿menu_item_id = o.item_id
where order_id in (440, 2075, 1957, 330, 2675)
group by order_id, category;


