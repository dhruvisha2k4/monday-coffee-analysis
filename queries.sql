-- Monday Coffee Data Analysis 

create database monday_coffee;
use monday_coffee;

show tables;

SELECT COUNT(*) FROM city;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM sales;

SELECT * FROM sales LIMIT 10;

-- Make sure no sale refers to a product or customer that doesn’t exist
SELECT COUNT(*) AS orphan_products
FROM sales s
LEFT JOIN products p ON s.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT COUNT(*) AS orphan_customers
FROM sales s
LEFT JOIN customers c ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Report & Analysis

-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?
select city_name, round(population * 0.25/1000000, 2)as coffee_consumed_in_millions, city_rank from city
order by population desc;

-- Q.2
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
SELECT 
    ci.city_name,
    SUM(s.total) AS total_revenue
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON c.city_id = ci.city_id
WHERE YEAR(s.sale_date) = 2023
  AND QUARTER(s.sale_date) = 4
GROUP BY ci.city_name
ORDER BY total_revenue DESC;

-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?
select p.product_name, count(s.sale_id) as total_orders
 from products as p
left join sales as s 
on s.product_id = p.product_id
group by product_name
order by total_orders desc;

-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?
SELECT 
    ci.city_name,
    SUM(s.total) AS total_revenue,
    count(distinct s.customer_id) as total_cust,
    round(SUM(s.total) / count(distinct s.customer_id), 2)  as avg_sale_per_customer
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON c.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY avg_sale_per_customer DESC;

-- -- Q.5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)
with city_table as (
    select
        city_name,
        round(population * 0.25 / 1000000, 2) as coffee_consumers_in_millions,
        city_rank
    from city
),
customer_table as (
    select
        ci.city_name,
        count(distinct c.customer_id) as unique_customers
    from sales s
    join customers c on c.customer_id = s.customer_id
    join city ci on ci.city_id = c.city_id
    group by ci.city_name
)
select
    ct.city_name,
    ct.coffee_consumers_in_millions,
    cu.unique_customers,
    round(cu.unique_customers / (ct.coffee_consumers_in_millions * 1000000) * 100, 4) as penetration_pct
from city_table ct
join customer_table cu on ct.city_name = cu.city_name
order by ct.coffee_consumers_in_millions desc;


-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?
select *
from (
    select
        ci.city_name,
        p.product_name,
        count(s.sale_id) as total_orders,
        dense_rank() over (partition by ci.city_name order by count(s.sale_id) desc) as rnk
    from sales as s
    join products as p
    on s.product_id = p.product_id
    join customers as c
    on c.customer_id = s.customer_id
    join city as ci
    on ci.city_id = c.city_id
    group by ci.city_name, p.product_name
) as t1
where rnk <= 3;

-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?
select
    ci.city_name,
    count(distinct c.customer_id) as unique_customers
from sales as s
join customers as c on c.customer_id = s.customer_id
join city as ci on ci.city_id = c.city_id
group by ci.city_name
order by unique_customers desc;

-- Q.8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer
with city_table as
(
SELECT 
    ci.city_name,
    count(distinct s.customer_id) as total_cust,
    round(SUM(s.total) / count(distinct s.customer_id), 2)  as avg_sale_per_customer
    
    
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN city ci ON c.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY avg_sale_per_customer DESC),

city_rent as 
(
select city_name, estimated_rent from city
)

select cr.city_name, cr.estimated_rent, ct.total_cust, ct.avg_sale_per_customer,
	round(cr.estimated_rent/ct.total_cust, 2) as avg_rent_per_cust
 from city_rent as cr
join city_table as ct
on cr.city_name = ct.city_name
order by estimated_rent desc;

-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city
with monthly_sales as
(
select 
ci.city_name, month(sale_date) as months, year(sale_date) as years,
sum(s.total) as total_sale
 from sales as s
join customers as c
on c.customer_id = s.customer_id
join city as ci
on ci.city_id = c.city_id
group by city_name, months, years
order by city_name, years, months
),
growth_ratio as
(
select 
	city_name, months, years, total_sale as curr_month_sale,
	lag(total_sale, 1) over(partition by city_name order by years, months) as last_month_sale
from monthly_sales
)

select
	city_name, months, years, last_month_sale, curr_month_sale,
    round((curr_month_sale-last_month_sale)/ last_month_sale * 100, 2)
    as growth_ratios
from growth_ratio
where last_month_sale is not null 


-- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer
with city_sales as (
    select
        ci.city_name,
        sum(s.total) as total_revenue,
        count(distinct s.customer_id) as total_customers,
        round(sum(s.total) / count(distinct s.customer_id), 2) as avg_sale_per_customer
    from sales as s
    join customers as c on c.customer_id = s.customer_id
    join city as ci on ci.city_id = c.city_id
    group by ci.city_name
),
city_info as (
    select
        city_name,
        estimated_rent,
        round(population * 0.25 / 1000000, 2) as coffee_consumers_in_millions
    from city
)
select
    cs.city_name,
    cs.total_revenue,
    ci.estimated_rent as total_rent,
    cs.total_customers,
    ci.coffee_consumers_in_millions,
    cs.avg_sale_per_customer,
    round(ci.estimated_rent / cs.total_customers, 2) as avg_rent_per_customer
from city_sales as cs
join city_info as ci on ci.city_name = cs.city_name
order by cs.total_revenue desc
limit 3;