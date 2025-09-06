-- =========================================================
-- 1. Find top 3 outlets by cuisine type without using LIMIT or TOP
-- =========================================================
with cuisine_orders_cte as (
    select 
        cuisine, 
        restaurant_id, 
        count(*) as total_orders
    from orders
    group by cuisine, restaurant_id
)
select *
from (
    select 
        *, 
        row_number() over(partition by cuisine order by total_orders desc) as rn
    from cuisine_orders_cte
) ranked
where rn = 1;


-- =========================================================
-- 2. Find the numbers of new customers that we are acquiring everyday from the launch date
-- =========================================================
with first_orders_cte as (
    select 
        customer_code, 
        cast(min(placed_at) as date) as first_order_date
    from orders
    group by customer_code
)
select 
    first_order_date, 
    count(*) as num_of_new_customers
from first_orders_cte
group by first_order_date
order by first_order_date;


-- =========================================================
-- 3. Count of all the users who were acquired in Jan 2025 
--    and only placed one order in Jan and did not place any other order
-- =========================================================
with jan_customers_cte as (
    select 
        customer_code, 
        count(*) as jan_order_count, 
        min(placed_at::date) as first_order_date
    from orders
    where extract(month from placed_at) = 1
    group by customer_code
    having count(*) = 1
)
select *
from jan_customers_cte
where customer_code not in (
    select customer_code
    from (
        select 
            customer_code, 
            min(placed_at::date) as first_order_date
        from orders
        where extract(month from placed_at) <> 1
        group by customer_code
    ) other_orders
);


-- =========================================================
-- 4. List all the customers with no order in the last 7 days 
--    but were acquired one month ago with their first order on promo
-- =========================================================
with customer_order_dates_cte as (
    select 
        customer_code,
        min(placed_at) as first_order_date,
        max(placed_at) as latest_order_date
    from orders
    group by customer_code
)
select 
    cte.customer_code,
    cte.first_order_date,
    o.promo_code_name as first_order_promo
from customer_order_dates_cte cte
join orders o
    on cte.customer_code = o.customer_code
    and cte.first_order_date = o.placed_at
where cte.latest_order_date < (current_date - interval '7 days')
  and cte.first_order_date < (current_date - interval '1 month')
  and o.promo_code_name is not null;


-- =========================================================
-- 5. Growth team trigger: target customers after their every third order
-- =========================================================
with customer_orders_cte as (
    select *, 
           row_number() over(partition by customer_code order by placed_at) as order_number
    from orders
)
select *
from customer_orders_cte
where order_number % 3 = 0
  and placed_at::date = '2025-03-25';


-- =========================================================
-- 6. List customers who placed more than one order 
--    and all their orders were on a promo only
-- =========================================================
select 
    customer_code, 
    count(*) as total_orders, 
    count(promo_code_name) as promo_orders
from orders
group by customer_code
having count(*) > 1
   and count(*) = count(promo_code_name);


-- =========================================================
-- 7. What percent of customers were organically acquired in Jan 2025 
--    (Placed their first order without a promo)
-- =========================================================
with jan_orders_cte as (
    select *,
           row_number() over (partition by customer_code order by placed_at) as rn
    from orders
    where extract(month from placed_at) = 1
      and extract(year from placed_at) = 2025
)
select 
    count(case when rn = 1 and promo_code_name is null then customer_code end) * 100.0
    / count(distinct customer_code) as organic_percent
from jan_orders_cte;
