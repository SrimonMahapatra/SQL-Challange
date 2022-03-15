# 🍕 Case Study 2 Pizza Runner

## Solution - B. Runner and Customer Experience

### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

```` sql
with t1 as
(select runner_id, registration_date, 
date_part('week', registration_date) as registration_week
from runners)

select registration_week, count(runner_id) as runner_sign_up
from t1
group by registration_week
````
### Output:
![Q1](https://user-images.githubusercontent.com/98659820/158360852-ea93f5af-b124-4222-9528-477fa03ad0b8.png)

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

```` sql
with t1 as 
(select c.order_id, c.order_time, r.pickup_time, r.pickup_time - c.order_time as pickup_mins
from runner_orders_temp r
join customer_orders c on c.order_id = r.order_id 
where r.distance <> '0'
group by c.order_id, c.order_time, r.pickup_time),

t2 as 
(select extract('minutes' from pickup_mins) as pickup_time_mins
from t1)

select round(avg(pickup_time_mins),2) as avg_pickup_time
from t2
where pickup_time_mins > 1
````
### Output:
![Q2](https://user-images.githubusercontent.com/98659820/158361545-90cf9cdd-3fb8-4fd1-9a9e-a05154f600c2.png)


### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

```` sql
with t1 as 
(select c.order_id, count(c.order_id) as pizza_ordered, c.order_time, r.pickup_time, r.pickup_time - c.order_time as prep_mins
from runner_orders_temp r
join customer_orders c on c.order_id = r.order_id 
where r.distance <> '0'
group by c.order_id, c.order_time, r.pickup_time),

t2 as 
(select *, extract('minutes' from prep_mins) as prep_time_mins
from t1)

select pizza_ordered, avg(prep_time_mins) as avg_prep_time
from t2
group by pizza_ordered
````
### Output:
![Q3](https://user-images.githubusercontent.com/98659820/158361719-6d3f5285-cc78-46be-8dab-ed5c124ec168.png)

### 4. 4.What was the average distance travelled for each customer?

```` sql
select c.customer_id, round(avg(r.distance)) as avg_distance
from runner_orders_temp r
join customer_orders c on c.order_id = r.order_id 
where r.distance <> '0'
group by c.customer_id
order by c.customer_id
````
### Output:
![Q4](https://user-images.githubusercontent.com/98659820/158362027-5b1c3fd5-8104-404b-9872-1a4e2db0b97f.png)

### 5. What was the difference between the longest and shortest delivery times for all orders?

```` sql
with t1 as 
(select max(duration) as longest_delivery_time, min(duration) as shortest_delivery_time
from runner_orders_temp)

select longest_delivery_time - shortest_delivery_time as diff
from t1 
````
### Output:
![Q5](https://user-images.githubusercontent.com/98659820/158362436-73821030-110c-4d38-a627-f6d250d01e4d.png)

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

```` sql
 select runner_id, round(distance/duration * 60) as speed
 from runner_orders_temp

select r.runner_id, c.customer_id, c.order_id, distance, round(distance/duration * 60) as speed
from customer_orders_temp c 
join runner_orders_temp r on c.order_id = r.order_id
where distance <> '0'
````
### Output:
![Q6](https://user-images.githubusercontent.com/98659820/158366159-869ccb20-1fad-4ae9-983e-2aefc3b79949.png)

### 7. What is the successful delivery percentage for each runner?

```` sql
with t1 as 
(select runner_id, count(order_id) as successful_deliveries
from runner_orders_temp
where distance <> '0'
group by runner_id),

t2 as 
(select sum(successful_deliveries) as total_successful_deliveries
from t1)

select t1.runner_id, t2.total_successful_deliveries,t1.successful_deliveries, 
round(t1.successful_deliveries/t2.total_successful_deliveries * 100, 2) as Sucess_perct
from t1, t2
````
### Output:
![Q7](https://user-images.githubusercontent.com/98659820/158366484-11182dbf-8d96-4ac0-a8d3-29df295b38ef.png)



