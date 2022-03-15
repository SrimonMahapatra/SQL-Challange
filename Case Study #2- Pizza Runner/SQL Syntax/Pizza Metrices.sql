CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
select * from runners
select * from customer_orders 
select * from runner_orders
select * from pizza_names
select * from pizza_recipes
select * from pizza_toppings 

🧼 Data Cleaning & Transformation
🔨 Table: customer_orders
Looking at the customer_orders table below, we can see that there are

In the exclusions column, there are missing/ blank spaces ' ' and null values.
In the extras column, there are missing/ blank spaces ' ' and null values.

Our Course of action to clean the table:

Create a temporary table with all the columns
Remove null values in exlusions and extras columns and replace with blank space ' '.

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

select * from customer_orders_temp

🔨 Table: runner_orders
Looking at the runner_orders table below, we can see that there are

In the exclusions column, there are missing/ blank spaces ' ' and null values.
In the extras column, there are missing/ blank spaces ' ' and null values

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

drop table runner_orders_temp

select * from runner_orders_temp

delete from runner_orders_temp
where cancellation in ('Customer Cancellation', 'Restaurant Cancellation')

ALTER TABLE runner_orders_temp
ALTER COLUMN pickup_time TYPE date USING pickup_time::date,
ALTER COLUMN distance TYPE float USING distance::float,
ALTER COLUMN duration TYPE INTEGER USING duration::INTEGER

--1. How many pizzas were ordered?

select count(*) as pizza_ordered
from customer_orders_temp

--2. How many unique customer orders were made?

with t1 as 
(select distinct order_id as unique_order_id
from customer_orders_temp)

select count(unique_order_id)
from t1

--Another way 

select count(distinct order_id) as unique_order_id
from customer_orders_temp

--3.How many successful orders were delivered by each runner?

select runner_id, count(order_id) as successful_orders
from runner_orders_temp
where distance <> 0
group by runner_id
order by runner_id

--4.How many of each type of pizza was delivered?
select * from customer_orders_temp
select * from runner_orders_temp
select * from pizza_names

with t1 as 
(select co.order_id, pizza_id
from customer_orders_temp as co
join runner_orders_temp as ro on co.order_id = ro.order_id)

select pizza_name, count(t1.pizza_id) as pizza_count 
from t1
join pizza_names as pn on t1.pizza_id = pn.pizza_id
group by pizza_name

--5.How many Vegetarian and Meatlovers were ordered by each customer?
select * from pizza_names
select * from customer_orders_temp

select customer_id, pizza_name, count(1) as order_count
from customer_orders_temp co
join pizza_names pn on co.pizza_id = pn.pizza_id
group by customer_id, pizza_name
order by customer_id

--6.What was the maximum number of pizzas delivered in a single order?

select co.order_id, count(pizza_id) as pizza_per_order
from customer_orders_temp co
join runner_orders_temp ro on ro.order_id = co.order_id
where distance <> 0 
group by co.order_id
order by pizza_per_order desc
limit 1

--7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select co.customer_id,
sum(case when co.exclusions <> '' or co.extras <> '' then 1 else 0 end) as at_least_1_change,
sum(case when co.exclusions <> '' and co.extras <> '' then 1 else 0 end) as no_change
from customer_orders_temp co
join runner_orders_temp ro on co.order_id = ro.order_id
group by customer_id
order by customer_id

--8.How many pizzas were delivered that had both exclusions and extras?
select * from customer_orders_temp
select * from runner_orders_temp

select co.customer_id,
sum(case when co.exclusions <> '' and co.extras <> '' then 1 else 0 end) as change_done
from customer_orders_temp co
join runner_orders_temp ro on co.order_id = ro.order_id
group by customer_id
order by change_done desc
limit 1

--9.What was the total volume of pizzas ordered for each hour of the day?

select extract(hour from order_time) as hour_of_day, count(order_id) as Pizza_count
from customer_orders
group by hour_of_day
order by Pizza_count desc

--10.What was the volume of orders for each day of the week?

select * from customer_orders_temp

select to_char(order_time, 'Day') as weekdays, count(order_id) as pizza_ordered
from  customer_orders
group by weekdays
order by pizza_ordered desc








