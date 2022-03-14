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


```` sql ALTER TABLE runner_orders_temp
ALTER COLUMN pickup_time TYPE date USING pickup_time::date,
ALTER COLUMN distance TYPE float USING distance::float,
ALTER COLUMN duration TYPE INTEGER USING duration::INTEGER````

1. How many pizzas were ordered?


