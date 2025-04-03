--1. Top Selling Products
--Query the top 10 products by total sales value.
--products, order_items, 

--add new total_sales column
alter table order_items
add column total_sales float;

update order_items
set total_sales=quantity*price_per_unit;
select * from order_items;

select 
	oi.product_id,
	p.product_name, 
	oi.quantity, 
	sum(oi.total_sales) as total_sale
from orders o
join order_items oi
on o.order_id=oi.order_id
join products p
on p.product_id=oi.product_id
group by 1,2,3
order by total_sale desc
limit 10

--2. Revenue by Category
--Calculate total revenue generated by each product category.

select p.category_id,
	c.category_name,
	sum(oi.total_sales) as total_revenue, 
	sum(oi.total_sales)/(select sum(total_sales) from order_items) * 100 as contribution
from order_items oi
join products p
on p.product_id=oi.product_id
join category c
on c.category_id=p.category_id
group by 1,2
order by 1

select sum(total_sales) from order_items

--3. Average Order Value (AOV)
--Compute the average order value for each customer.

select c.customer_id, c.first_name, c.last_name,sum(oi.total_sales) as Total_rev_per_cust,
	count(oi.order_id) as total_no_orders,
	sum(oi.total_sales)/count(oi.order_id) as AOV
	
	
--select *
from customers c
join orders o
on c.customer_id=o.customer_id
join order_items oi
on o.order_id=oi.order_id
group by 1,2,3
order by customer_id


--4. Monthly Sales Trend
--Query monthly total sales over the past year.
-- Basically find out current month sales & last month sales 

--This is for entire last year
select 
	Extract(month from o.order_date) as months, 
	Extract(year from o.order_date) as years, 
	sum(oi.total_sales) as total_rev,
	lag(sum(oi.total_sales)) over () as prev_month_sales,
	sum(oi.total_sales)-lag(sum(oi.total_sales)) over () as Profit_or_Loss
from orders o
join order_items oi
on o.order_id=oi.order_id
where Extract(year from o.order_date)=(select max(Extract(year from order_date)-1) from orders)
group by 1,2
order by months

--Below is for last year since this current date
with cte as (
select 
	Extract(month from o.order_date) as months, 
	Extract(year from o.order_date) as years, 
	ROUND(SUM(oi.total_sales::NUMERIC), 2) AS total_rev
from orders o
join order_items oi
on o.order_id=oi.order_id
where o.order_date>=(select max(order_date) from orders) - interval '1 year'
group by 1,2
order by years, months
)
select *,
	lag(total_rev) over () as prev_month_sales,
	total_rev-(lag(total_rev) over ()) as profit_or_loss
from cte

--5. Customers with No Purchases
--Find customers who have registered but never placed an order.

select distinct(c.customer_id), c.first_name, c.last_name
from customers c
left join orders o
on c.customer_id=o.customer_id
where o.customer_id is null


--6. Best-Selling Categories by State
--Identify the best-selling product category for each state.

with cte as (select cs.state, c.category_name, sum(oi.total_sales) as total_sales,
	rank() over (partition by state order by sum(oi.total_sales) desc) as ranking
from category c
join products p
on c.category_id=p.product_id
join order_items oi
on p.product_id=oi.product_id
join orders o
on o.order_id=oi.order_id
join customers cs
on cs.customer_id=o.customer_id
group by 1,2
order by state)

select state, category_name, total_sales
from cte
where ranking=1

/*
7. Customer Lifetime Value (CLTV)
Calculate the total value of orders placed by each customer over their lifetime and rank them
*/

select distinct(c.customer_id), max(o.order_date), min(o.order_date)
	 ,sum(oi.total_sales) as total_sales
	,max(o.order_date) - min(o.order_date) as clt
	from orders o
join customers c
on o.customer_id=c.customer_id
join order_items oi
on oi.order_id=o.order_id
group by 1
order by total_sales desc


/*
8. Inventory Stock Alerts
Query products with stock levels below a certain threshold (e.g., less than 10 units).
Challenge: Include last restock date and warehouse information.
*/

select *
select distinct(i.product_id), i.warehouse_id, i.last_stock_date, p.product_name, sum(i.stock) as stock_left
from inventory i
join products p
on p.product_id=i.product_id
where i.stock<=10
group by 1,2,3,4
order by stock_left
 

/* 9. Shipping Delays
Identify orders where the shipping date is later than 3 days after the order date.
Challenge: Include customer, order details, and delivery provider.
*/

select s.shipping_id, s.order_id, s.shipping_date, o.order_date, c.customer_id, 
concat(c.first_name,' ',c.last_name) as full_name,
s.shipping_providers
from shippings s
join orders o
on o.order_id=s.order_id
join customers c
on c.customer_id=o.customer_id
where s.shipping_date>o.order_date+3


/*
10. Payment Success Rate 
Calculate the percentage of successful payments across all orders.
Challenge: Include breakdowns by payment status (e.g., failed, pending).
*/

select p.payment_status,
	Count(*) as total_count,
	(count(*)::numeric/(select count(*) from payments)::numeric) *100 as percentage
from payments p
join orders o
on p.order_id=o.order_id
group by 1

/*
11. Top Performing Sellers
Find the top 5 sellers based on total sales value.
Challenge: Include both successful and failed orders, and display their percentage of successful orders.
*/

with top_sellers as (
select s.seller_id, s.seller_name, sum(oi.total_sales) as total_sales
from orders o
join sellers s
on s.seller_id=o.seller_id
join order_items oi
on oi.order_id=o.order_id
group by 1,2
order by total_sales desc
limit 5
),
seller_reports as
(select o.seller_id, t.seller_name, o.order_status, count(*) as count_status
from orders o
join top_sellers t
on t.seller_id=o.seller_id
where
	o.order_status not in ('Inprogress', 'Returned')
group by 1,2,3
order by 1
)
select 
--	*
	seller_id, seller_name, order_status, count_status,
	--sum(count_status) over (partition by seller_id) as total_count,
	round(count_status/sum(count_status) over (partition by seller_id),2) as percentage
from seller_reports


/*
12. Product Profit Margin
Calculate the profit margin for each product (difference between price and cost of goods sold).
Challenge: Rank products by their profit margin and total_profit, showing highest to lowest.
*/


with cte as (
select distinct(p.product_id), p.product_name, p.price, p.cogs, sum(oi.quantity) as quantity,
	round(((p.price - p.cogs)*sum(oi.quantity))::numeric,2) as total_profit
from products p
join order_items oi
on p.product_id=oi.product_id
group by 1,2,3,4
)
select *,
	round((total_profit/(price*quantity))::numeric,3) *100 as profit_margin,
	DENSE_RANK() OVER (ORDER BY (total_profit / (price * quantity)) DESC) AS profit_margin_rank
from cte
order by total_profit desc, profit_margin_rank 


/*
13. Most Returned Products
Query the top 10 products by the number of returns.
Challenge: Display the return rate as a percentage of total units sold for each product.
*/

with cte as (
select p.product_id, p.product_name, count(o.order_status) as total_count,
	sum(case 
		when o.order_status='Returned' then 1 else 0 end) as return_count	
from products p
join order_items oi
on p.product_id=oi.product_id
join orders o
on o.order_id=oi.order_id
group by 1,2
order by return_count desc
)
select *, 
	(return_count*100.0/total_count)  as percentage_return
from cte
order by percentage_return desc

/*
14. Orders Pending Shipment
Find orders that have been paid but are still pending shipment.
Challenge: Include order details, payment date, and customer information.
*/

select order_status, count(*) from orders group by 1
select *  from order_items
select *  from customers
select * from payments
select *  from orders

select p.payment_date, count(c.customer_id) --c.first_name,c.last_name,c.state 
from orders o
join payments p
on o.order_id=p.order_id
join customers c
on c.customer_id=o.customer_id
where p.payment_status='Payment Successed' and o.order_status='Inprogress'
group by 1
order by 2 desc


/*
15. Inactive Sellers
Identify sellers who haven’t made any sales in the last 6 months.
Challenge: Show the last sale date and last sales from those sellers.
*/

with cte as (
select distinct(s.seller_id), s.seller_name, max(o.order_date) as last_sale_date
from sellers s
join orders o
on o.seller_id=s.seller_id
where s.seller_id not in (select seller_id from orders where order_date >= current_date - interval '6 months')
group by 1,2
order by 1
)
select c.seller_id,c.last_sale_date,
	sum(oi.total_sales) as last_sale_amount
from cte c
join order_items oi
on c.seller_id=oi.order_id
join order_items o
on oi.order_id=o.order_id
group by 1,2
order by 1


/*
16. IDENTITY customers into returning or new
if the customer has done more than 5 return categorize them as returning otherwise new
Challenge: List customers id, name, total orders, total returns
*/

with cte as (
select c.customer_id, c.first_name, c.last_name, count(o.order_id) as Total_orders,
	sum
		(case when order_status='Returned' then 1 else 0 end) as order_returned
from orders o
join customers c
on c.customer_id=o.customer_id
group by 1,2,3
order by order_returned desc
)
select *, 
	case when order_returned >5 then 'Returning' else 'New' end as Status
from cte	


/*
17. Top 5 Customers by Orders in Each State
Identify the top 5 customers with the highest number of orders for each state.
Challenge: Include the number of orders and total sales for each customer.
*/

with cte as (
	select o.customer_id, c.first_name,c.last_name, c.state, count(o.order_id) as order_count
	, dense_rank() over(partition by c.state order by count(o.order_id) desc) as ranks
	,ROUND(SUM(oi.total_sales::numeric), 2) as total_sales
from orders o
join customers c
on c.customer_id=o.customer_id
join order_items oi
on o.order_id=oi.order_id
group by 1,2,3,4
)
SELECT * 
FROM cte c 
WHERE ranks < 6
ORDER BY state, ranks


/*
18. Revenue by Shipping Provider
Calculate the total revenue handled by each shipping provider.
Challenge: Include the total number of orders handled and the average delivery time for each provider.
*/


select s.shipping_providers, sum(oi.total_Sales) as total_sales, sum(s.order_id) as order_count,
	avg(s.shipping_date-o.order_date) as avg_shipping_time
from shippings s
join orders o 
on s.order_id=o.order_id
join order_items oi
on oi.order_id=o.order_id
group by 1

/*
20. Top 10 product with highest decreasing revenue ratio compare to last year(2022) and current_year(2023)
Challenge: Return product_id, product_name, category_name, 2022 revenue and 2023 revenue decrease ratio at end Round the result

Note: Decrease ratio = (cr-ls/ls)* 100 (cs = current_year ls=last_year)
*/


with cte as (
	select p.product_id, p.product_name, c.category_name, 
		sum(case when Extract(year from o.order_date)=2023 then oi.total_sales else 0 end) as revenue_2023,
		sum(case when Extract(year from o.order_date)=2022 then oi.total_sales else 0 end) as revenue_2022
from order_items oi
join products p 
on oi.product_id=p.product_id
join orders o
on oi.order_id=o.order_id
join category c
on p.category_id=c.category_id
group by 1,2,3
)
select *,	
	revenue_2023 - revenue_2022 as rev_diff,
	ROUND(
        COALESCE((revenue_2023 - revenue_2022) * 100.0 / NULLIF(revenue_2022, 0), 0)::numeric, 2
    ) AS revenue_ratio
from cte
where revenue_2023>revenue_2022
order by revenue_ratio desc
limit 10





/*
Store Procedure
create a function as soon as the product is sold the the same quantity should reduced from inventory table
after adding any sales records it should update the stock in the inventory table based on the product and qty purchased
*/

select * from inventory
--prod id 1 --stock = 55
--prod id 2 --stock==39

create or replace procedure add_sales
(
p_order_id int,
p_customer_id int,
p_seller_id int,
p_order_item_id int,
p_product_id int,
p_quantity int
)
language plpgsql
as $$

declare 
v_count INT;
v_price FLOAT;
v_product VARCHAR(50);

begin
--check stock and product availability
	select price, product_name 
	into v_price, v_product
	from products
	where product_id=p_product_id;

	select count(*)
	into v_count
	from inventory
	where  product_id=p_product_id
	and stock>=p_quantity;
	
if v_count>0 then
	--add into orders and order_items table
	--update inventory
	insert into orders(order_id, order_date, customer_id, seller_id)
	values (p_order_id, current_Date, p_customer_id, p_seller_id);

	insert into order_items(order_item_id, product_id, quantity, price_per_unit, total_sales)
	values(p_order_item_id, p_product_id, p_quantity, v_price, v_price*p_quantity );

	update inventory
	set stock = stock - p_quantity
	where product_id=p_product_id;

	RAISE NOTICE 'Product: % has been added', v_product;

	else
	raise notice 'Product not available';

	end if;

	
end
$$


call add_sales
(25000,2,5,25001,1,40);


