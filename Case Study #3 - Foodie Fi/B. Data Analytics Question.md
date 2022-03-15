# Case Study #3 - Foodie Fi

## Solution: B. Data Analysis Question

### 1. How many customers has Foodie-Fi ever had?

```` sql
select count( distinct customer_id) as unique_customer
from subscriptions
````
![Q1](https://user-images.githubusercontent.com/98659820/158407550-ec21bccd-ae63-4aab-8077-fd623a5b3468.png)

### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

```` sql
with t1 as 
(select s.customer_id, s.plan_id, p.plan_name, to_char(s.start_date, 'month') as month_name, 
 extract (month from start_date) as month_date
from subscriptions s
join plans p on s.plan_id = p.plan_id
where p.plan_id = 0)

select month_date, month_name, count(1)
from t1 
group by month_name, month_date
order by month_date
````
![Q2](https://user-images.githubusercontent.com/98659820/158407921-e0699267-d494-4c5d-aed7-3317e52dff84.png)

### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.

```` sql
with t1 as 
(select s.customer_id, s.plan_id, p.plan_name , extract(year from start_date) as year 
from subscriptions s
join plans p on p.plan_id = s.plan_id),

t2 as 
(select plan_name, count(1) as events_2021
from t1 
where year <> 2020
group by plan_name
order by events_2021),

t3 as 
(select plan_name, count(1) as events_2020
from t1 
where year <> 2021
group by plan_name)

select t2.plan_name, events_2020, events_2021
from t2
join t3 on t2.plan_name = t3.plan_name
````
![Q3](https://user-images.githubusercontent.com/98659820/158408279-3c50ce8d-c1e8-4f79-b8d3-355801af76a1.png)

4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

```` sql
with t1 as 
(select distinct count(customer_id)::NUMERIC as churn_count
from subscriptions
where plan_id = 4),

t2 as 
(select t1.churn_count, count(distinct customer_id)::NUMERIC as unique_customer_count 
from subscriptions, t1
group by t1.churn_count)

select *, round(100 * churn_count / unique_customer_count,1 ) as churn_percentage
from t2
````
![Q4](https://user-images.githubusercontent.com/98659820/158408743-4f44c57d-157e-4235-a8a5-86516e79103c.png)

5. How many customers have churned straight after their initial free trial ? what percentage is this rounded to the nearest whole number?

```` sql
with t1 as 
(select s.customer_id, s.plan_id, p.plan_name, row_number() over(partition by s.customer_id order by s.plan_id) as plan_rank
from plans p
join subscriptions s on  p.plan_id = s.plan_id
order by customer_id),

t2 as 
(select *
from t1 
where plan_id = 4 and plan_rank = 2),

t3 as 
(select count(distinct t1.customer_id)::NUMERIC as unique_customers, count(distinct t2.customer_id)::NUMERIC as churn_count 	
from t1, t2)

select churn_count, unique_customers,round(100 * churn_count / unique_customers, 0) as churn_percentage
from t3
````
![Q5](https://user-images.githubusercontent.com/98659820/158409303-c88ebec0-6fca-4fc2-9f34-88e94b49dd06.png)

6. What is the number and percentage of customer plans after their initial free trial?

```` sql
with t1 as 
(select customer_id, plan_id, lead(plan_id, 1) over (partition by customer_id order by plan_id ) as next_plan
from subscriptions),

t2 as 
(select next_plan, count(*):: NUMERIC as conversions
from t1
where next_plan is not null and plan_id = 0
group by next_plan),

t3 as 
(select count(distinct customer_id):: NUMERIC as unique_customers
from subscriptions)

select t2.next_plan, t2.conversions, t3.unique_customers, round(100 * t2.conversions/t3.unique_customers,2) as Perct
from t2, t3
where t2.next_plan is not null
order by next_plan
````
![image](https://user-images.githubusercontent.com/98659820/158409573-b46c97e2-3012-45a4-a92a-8e42d1635191.png)

7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

```` sql
with t1 as 
(select customer_id, plan_id, start_date, lead(start_date,1) over (partition by customer_id order by start_date ) as next_date
from subscriptions
where start_date <= '2020-12-31'),

t2 as 
(select plan_id, count(distinct customer_id) as customers
from t1
where (next_date is not null and (start_date < '2020-12-31' and next_date > '2020-12-31'))
or (next_date is null and start_date < '2020-12-31')
group by plan_id)

select plan_id, customers, round(100 * customers::NUMERIC / (select count(distinct customer_id) from subscriptions), 1) as percentage
from t2
group by plan_id, customers	
order by plan_id
````
![Q7](https://user-images.githubusercontent.com/98659820/158410243-b5b16ca9-6bc0-494f-8e91-81a62ed13462.png)

8. How many customers have upgraded to an annual plan in 2020?

```` sql
select count(distinct customer_id) as unique_customer
from subscriptions 
where plan_id = 3 and start_date <= '2020-12-31'
````
![Q8](https://user-images.githubusercontent.com/98659820/158410625-c31d0799-9bdf-4c8b-8458-6123088109d1.png)

9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

```` sql
with t1 as 
(select customer_id, start_date as trial_date
from subscriptions 
where plan_id = 0),

t2 as 
(select customer_id, start_date as annual_date
from subscriptions
where plan_id = 3)

select round(avg(t2.annual_date - t1.trial_date),0) as avg_days_to_upgrade
from t1 join
t2 on t1.customer_id = t2.customer_id
````
![Q9](https://user-images.githubusercontent.com/98659820/158410955-a2a64f06-8271-48f0-b027-d03388b0046a.png)

10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

```` sql
-- Filter results to customers at trial plan = 0
WITH trial_plan AS 
(SELECT 
  customer_id, 
  start_date AS trial_date
FROM foodie_fi.subscriptions
WHERE plan_id = 0
),
-- Filter results to customers at pro annual plan = 3
annual_plan AS
(SELECT 
  customer_id, 
  start_date AS annual_date
FROM foodie_fi.subscriptions
WHERE plan_id = 3
),
-- Sort values above in buckets of 12 with range of 30 days each
bins AS 
(SELECT 
  WIDTH_BUCKET(ap.annual_date - tp.trial_date, 0, 360, 12) AS avg_days_to_upgrade
FROM trial_plan tp
JOIN annual_plan ap
  ON tp.customer_id = ap.customer_id)
  
SELECT 
  ((avg_days_to_upgrade - 1) * 30 || ' - ' || (avg_days_to_upgrade) * 30) || ' days' AS breakdown, 
  COUNT(*) AS customers
FROM bins
GROUP BY avg_days_to_upgrade
ORDER BY avg_days_to_upgrade;
````
![Q10](https://user-images.githubusercontent.com/98659820/158411423-dde88cc8-c3f4-4b9e-a524-3e01c7acc65a.png)

11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

```` sql
with t1 as 
(select customer_id, plan_id, start_date, lead(plan_id,1) over(partition by customer_id order by plan_id) as next_plan
from subscriptions)

select count(*)
from t1
where plan_id = 2 and next_plan = 1
````
![Q11](https://user-images.githubusercontent.com/98659820/158411647-eecd7fd5-101c-4a6d-a1bf-8dc17c414a76.png)

***













