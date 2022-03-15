# Case Study #2 - Pizza Runner

## Solution - A. Pizza Metrices


🧼 Data Cleaning & Transformation
🔨 Table: customer_orders
Looking at the customer_orders table below, we can see that there are

In the exclusions column, there are missing/ blank spaces ' ' and null values.
In the extras column, there are missing/ blank spaces ' ' and null values.

Our Course of action to clean the table:

Create a temporary table with all the columns
Remove null values in exlusions and extras columns and replace with blank space ' '.

````sql
drop table if exists;
create temp table customer_orders_temp as 
select 
	order_id,
	customer_id,
	pizza_id,
	case 
			when exclusions is null or exclusions like 'null' then ''
			else exclusions
			end as exclusions,
	case
			when extras is null or extras like 'null' then ''
			else extras
			end as extras,
	order_time
from customer_orders
````	
![Customers Order Temp](https://user-images.githubusercontent.com/98659820/158333877-42093625-23e6-4363-a7cc-4c631b11b7a8.png)

**🔨 Table: runner_orders**
Looking at the runner_orders table below, we can see that there are

In the exclusions column, there are missing/ blank spaces ' ' and null values.
In the extras column, there are missing/ blank spaces ' ' and null values

````sql 
create temp table runner_orders_temp as 

select 
 order_id,
 runner_id,
 case 
 		when pickup_time like 'null' then ' '
		else pickup_time
		end as pickup_time,
 case 
 		when distance like 'null' then '0'
		when distance like '%km' then trim('km' from distance)
		else distance
		end as distance,
 case 
 		when duration is null then '0'
 		when duration like 'null' then '0'
		when duration like '%mins' then trim('mins' from duration)
		when duration like '%minute' then trim('minute' from duration)
		when duration like '%minutes' then trim('minutes' from duration)
		else duration
		end as duration,
 case 
 		when cancellation is null  then ''
 		when cancellation like 'null' then ''
		else cancellation
		end as cancellation
from runner_orders	
````

```` sql
delete from runner_orders_temp
where cancellation in ('Customer Cancellation', 'Restaurant Cancellation') 
````


```` sql 
ALTER TABLE runner_orders_temp
ALTER COLUMN pickup_time TYPE date USING pickup_time::date,
ALTER COLUMN distance TYPE float USING distance::float,
ALTER COLUMN duration TYPE INTEGER USING duration::INTEGER 
````
![Runner Order Temp](https://user-images.githubusercontent.com/98659820/158334296-28b778d0-5036-4902-b472-22bb1eeb13ca.png)


### 1. How many pizzas were ordered?
```` sql
select count(*) as pizza_ordered
from customer_orders_temp
````
![Q1](https://user-images.githubusercontent.com/98659820/158334528-160e9a1d-0ce6-463b-b47e-c2153621f8b9.png)

### 2. How many unique customer orders were made?

```` sql
with t1 as 
(select distinct order_id as unique_order_id
from customer_orders_temp)

select count(unique_order_id)
from t1

--Another way 

select count(distinct order_id) as unique_order_id
from customer_orders_temp
````
![Q2](https://user-images.githubusercontent.com/98659820/158334948-0d3d0c4e-21ab-4858-ae89-1ff705c8735b.png)

### 3. How many successful orders were delivered by each runner?

```` sql
select runner_id, count(order_id) as successful_orders
from runner_orders_temp
where distance <> 0
group by runner_id
order by runner_id
````
![Q3](https://user-images.githubusercontent.com/98659820/158335315-b2fb712a-ebe4-4018-9251-82f7849490c8.png)

### 4. How many of each type of pizza was delivered?

```` sql
with t1 as 
(select co.order_id, pizza_id
from customer_orders_temp as co
join runner_orders_temp as ro on co.order_id = ro.order_id)

select pizza_name, count(t1.pizza_id) as pizza_count 
from t1
join pizza_names as pn on t1.pizza_id = pn.pizza_id
group by pizza_name
````
![Q4](https://user-images.githubusercontent.com/98659820/158335917-b69b7489-f24a-4943-ac03-524707057403.png)

### 5. How many Vegetarian and Meatlovers were ordered by each customer?

```` sql
select customer_id, pizza_name, count(1) as order_count
from customer_orders_temp co
join pizza_names pn on co.pizza_id = pn.pizza_id
group by customer_id, pizza_name
order by customer_id
````
![image](https://user-images.githubusercontent.com/98659820/158336124-a6c5a496-da99-4ca9-abd8-3727271ea0f5.png)

### 6. What was the maximum number of pizzas delivered in a single order?

```` sql
select co.order_id, count(pizza_id) as pizza_per_order
from customer_orders_temp co
join runner_orders_temp ro on ro.order_id = co.order_id
where distance <> 0 
group by co.order_id
order by pizza_per_order desc
limit 1
````
![Q6](https://user-images.githubusercontent.com/98659820/158336437-62555107-1a63-478c-991f-a162fc92c4d4.png)

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

```` sql
select co.customer_id,
sum(case when co.exclusions <> '' or co.extras <> '' then 1 else 0 end) as at_least_1_change,
sum(case when co.exclusions <> '' and co.extras <> '' then 1 else 0 end) as no_change
from customer_orders_temp co
join runner_orders_temp ro on co.order_id = ro.order_id
group by customer_id
order by customer_id
````
![Q7](https://user-images.githubusercontent.com/98659820/158336859-dc3968b1-4a0b-4d48-88e6-d1926090d397.png)

### 8. How many pizzas were delivered that had both exclusions and extras?

```` sql
select co.customer_id,
sum(case when co.exclusions <> '' and co.extras <> '' then 1 else 0 end) as change_done
from customer_orders_temp co
join runner_orders_temp ro on co.order_id = ro.order_id
group by customer_id
order by change_done desc
limit 1
````
![Q8](https://user-images.githubusercontent.com/98659820/158337147-32f36502-a3e9-4b43-8bc7-6e08d09be294.png)

### 9. What was the total volume of pizzas ordered for each hour of the day?

```` sql
select extract(hour from order_time) as hour_of_day, count(order_id) as Pizza_count
from customer_orders
group by hour_of_day
order by Pizza_count desc
````
![Q9](https://user-images.githubusercontent.com/98659820/158337595-b05006a1-ea48-4130-804c-b7a5dee47bf1.png)

### 10. What was the volume of orders for each day of the week?

```` sql
select to_char(order_time, 'Day') as weekdays, count(order_id) as pizza_ordered
from  customer_orders
group by weekdays
order by pizza_ordered desc
````
![Q10](https://user-images.githubusercontent.com/98659820/158337630-bb371e33-accd-49d4-ae04-9b54700535b3.png)

***
View solution for B. Pizza Runner and Customer Experience [here](https://github.com/SrimonMahapatra/SQL-Challange/blob/main/Case%20Study%20%232-%20Pizza%20Runner/B.%20Runner%20%26%20Customer%20Experience.md)









