# Case Study #4 - Data Bank

## Solution - A.Customer Nodes Exploration

**1. How many unique nodes are there on the Data Bank system?**

```` sql
select count(distinct node_id) 
from customer_nodes
````
![A Q1](https://user-images.githubusercontent.com/98659820/159175126-6cb77ec1-77c1-4ed3-b4d2-5eb438c4c574.PNG)

**2. What is the number of nodes per region?**

```` sql
select r.region_id, region_name, count(node_id) as no_of_nodes
from regions r
join customer_nodes cn on r.region_id = cn.region_id
group by region_name, r.region_id
order by r.region_id
````
![A Q2](https://user-images.githubusercontent.com/98659820/159175140-8eb2e12d-db3b-4206-a76b-e3eeb6d4acb7.PNG)


**3. How many customers are allocated to each region?**

```` sql

select r.region_id, region_name, count(customer_id) as no_of_customers
from regions r
join customer_nodes cn on r.region_id = cn.region_id
group by r.region_id, region_name 
order by region_id
````
![A Q3](https://user-images.githubusercontent.com/98659820/159175151-726392d9-62c9-4cdf-9c59-dc0f2ce97299.PNG)


**4. How many days on average are customers reallocated to a different node?**

```` sql
with t1 as 
(select customer_id, node_id, start_date, end_date, end_date - start_date as diff
from customer_nodes
where end_date <> '9999-12-31'
group by customer_id, node_id, start_date, end_date
order by customer_id, node_id),

t2 as 
(select customer_id, node_id, sum(diff) as sum_date_diff
from t1
group by customer_id, node_id)

select 
round(avg(sum_date_diff),0) as avg_reallocat_days
from t2
````
![A Q4](https://user-images.githubusercontent.com/98659820/159175162-676f80f2-6236-4bd3-8267-dabd04d80309.PNG)


**5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?**

***

