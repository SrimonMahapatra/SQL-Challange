# 🍱 Case Study-1: Danny' Diner

## **Solution**

Find the complete Syntax [here](https://github.com/SrimonMahapatra/SQL-Challange/tree/main/Case%20Study%20%231%20-%20Danny's%20Diner/SQL%20Syntax)
** **
### 1. What is the total amount each customer spent at the restaurant?

```sql 
with t1 as 
(select customer_id, order_date, product_name, price
from sales as s
join menu as m on s.product_id = m.product_id)

select customer_id, sum(price) as total_sales
from t1
group by customer_id
order by customer_id 
```
### Output:
![Q1png](https://user-images.githubusercontent.com/98659820/158075520-b01996e4-9f22-47a1-9996-d8740af55455.png)

### 2. How many days has each customer visited the restaurant?

```sql 
with t1 as 
(select distinct customer_id, count(order_date) as days_visited
from sales
group by customer_id
order by customer_id)
```
### Output:
![Q2](https://user-images.githubusercontent.com/98659820/158075736-0b4be940-c1c8-47ae-8e3b-c2585c4c8ae8.png)

### 3. What was the first item from the menu purchased by each customer?

```sql 
with t1 as 
(select customer_id, order_date, product_name
from sales as s
join menu as m on s.product_id = m.product_id),

t2 as
(select *, dense_rank() over (partition by customer_id order by order_date) as rnk
from t1)

select customer_id, product_name
from t2
where rnk = 1
group by customer_id, product_name
```
### Output:
![Q3](https://user-images.githubusercontent.com/98659820/158075798-5a92e028-dc4d-4784-b536-bce729875f38.png)

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql 
with t1 as
(select customer_id, order_date, product_name
from sales as s
join menu as m on s.product_id = m.product_id),

t2 as
(select product_name, count(1) as item_ordered
from t1
group by product_name
)

select *
from t2
where item_ordered > 1
order by item_ordered desc
```
### Output:
![Q4](https://user-images.githubusercontent.com/98659820/158075947-6c885b01-6010-4fdc-9f6b-142b58107a46.png)

### 5. Which item was the most popular for each customer?

``` sql with t1 as
(select customer_id, order_date, product_name
from sales as s
join menu as m on s.product_id = m.product_id),

t2 as
(select customer_id, product_name, count(1) as order_count
from t1
group by customer_id, product_name
order by customer_id),

t3 as 
(select *, dense_rank () over (partition by customer_id order by order_count desc) as rnk
from t2)

select customer_id, product_name, order_count
from t3 
where rnk = 1
```
### Output:
![Q5](https://user-images.githubusercontent.com/98659820/158076083-38815486-5d62-4385-8327-27bc5a3bd87f.png)


