CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
select * from members  

select * from menu

select * from sales

--1. What is the total amount each customer spent at the restaurant?

with t1 as 
(select customer_id, order_date, product_name, price
from sales as s
join menu as m on s.product_id = m.product_id)

select customer_id, sum(price) as total_sales
from t1
group by customer_id
order by customer_id 

--2. How many days has each customer visited the restaurant?

with t1 as 
(select distinct customer_id, count(order_date) as days_visited
from sales
group by customer_id
order by customer_id)

--3. What was the first item from the menu purchased by each customer?

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

--4. What is the most purchased item on the menu and how many times was it purchased by all customers? 

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

--5. Which item was the most popular for each customer?

with t1 as
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

--6. Which item was purchased first by the customer after they became a member?

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

--7. Which item was purchased just before the customer became a member?
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

--8. What is the total items and amount spent for each member before they became a member?

with t1 as 
(select s.customer_id, product_id
from sales s
join members m on s.customer_id = m.customer_id
where s.order_date < m.join_date)

select customer_id,sum(price)
from t1 
join menu m on t1.product_id = m.product_id
group by customer_id

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

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

--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
-- 1. Find member validity date of each customer and get last date of January
-- 2. Use CASE WHEN to allocate points by date and product id
-- 3. SUM price and points

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



 

