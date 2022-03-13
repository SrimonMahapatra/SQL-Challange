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

### 6. Which item was purchased first by the customer after they became a member?

``` sql
with t1 as
(select s.customer_id, m.join_date, s.order_date, s.product_id 
from sales s
join members m on s.customer_id = m.customer_id
where s.order_date >= m.join_date),

t2 as 
(select *, dense_rank() over(partition by customer_id order by order_date) as rnk
from t1)

select customer_id, order_date, product_name
from t2
join menu m2 on m2.product_id = t2.product_id
where rnk = 1
```
### Output:
![Q6](https://user-images.githubusercontent.com/98659820/158076231-a7ac0566-810e-4146-baa0-1b85ae71fa8f.png)

### 7. Which item was purchased just before the customer became a member?

``` sql
with t1 as 
(select s.customer_id, s.order_date, m.join_date, s.product_id
from sales s 
join members m on s.customer_id = m.customer_id
where s.order_date < m.join_date)

select t1.customer_id, t1.order_date, t1.join_date, m2.product_name
from t1
join menu m2 on t1.product_id = m2.product_id

--Another way
with t1 as
(select s.customer_id, m.join_date, s.order_date, s.product_id 
from sales s
join members m on s.customer_id = m.customer_id
where s.order_date < m.join_date),

t2 as 
(select *, dense_rank() over(partition by customer_id order by order_date) as rnk
from t1)

select customer_id, order_date, join_date, product_name
from t2
join menu m2 on m2.product_id = t2.product_id
where rnk = 1
```
### Output:
![Q10](https://user-images.githubusercontent.com/98659820/158076340-927bb851-8086-46c9-afbd-ba0d5365136e.png)

### 8. What is the total items and amount spent for each member before they became a member?

``` sql
with t1 as 
(select s.customer_id, product_id
from sales s
join members m on s.customer_id = m.customer_id
where s.order_date < m.join_date)

select customer_id,sum(price)
from t1 
join menu m on t1.product_id = m.product_id
group by customer_id
```
### Output:
![Q8](https://user-images.githubusercontent.com/98659820/158076477-f6285fb9-b5c5-489b-ae34-3d7f1024c049.png)

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

``` sql
with t1 as 
(select *,
case when product_name = 'sushi' then price * 20
else price * 10 end as points
from menu)

select customer_id, sum(points)
from t1
join sales s on s.product_id = t1.product_id
group by customer_id
order by customer_id
```
### Output:
![Q9](https://user-images.githubusercontent.com/98659820/158076549-7663455f-669b-4210-8637-ad281d6d8b4a.png)

10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

1. Find member validity date of each customer and get last date of January

2. Use CASE WHEN to allocate points by date and product id

3. SUM price and points

``` sql
with t1 as 
(select customer_id, order_date, s.product_id, price, product_name
from sales s
join menu m on m.product_id = s.product_id
where customer_id <> 'c'),

t2 as 
(select *, join_date + 6 as valid_date, to_date('2021-01-31', 'YYYYMMDD') as last_date
from members)

select t1.customer_id, order_date, join_date, valid_date, last_date, product_name, price, 
sum(case when product_name = 'sushi' then 2 * 10 * price
	 when order_date between join_date and valid_date then 2 * 10 * price
	 else 10 * price end) as points
from t1
join t2 on t1.customer_id = t2.customer_id
where order_date < valid_date
group by t1.customer_id, order_date, join_date, valid_date, last_date, product_name, price
```
### Output:
![image](https://user-images.githubusercontent.com/98659820/158076652-0ec2424a-9965-45e7-9c22-b7d3d022b01b.png)






