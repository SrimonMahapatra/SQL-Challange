# Case Study #4 - Data Bank

## Solution - B. Customer Transactions

**1. What is the unique count and total amount for each transaction type?**

```` sql
select txn_type, count(customer_id), sum(txn_amount) as total_amount
from customer_transactions
group by txn_type
````
![B Q1](https://user-images.githubusercontent.com/98659820/159175455-c0b8ad53-ed9e-4e50-b023-d1e5f60b5d57.PNG)

**2. What is the average total historical deposit counts and amounts for all customers?**

```` sql
with t1 as 
(select customer_id, txn_type, count(customer_id) as txn_count, avg(txn_amount) as avg_amount
from customer_transactions
group by txn_type, customer_id)

select round(avg(txn_count),0) as avg_deposit, round(avg(avg_amount),2) as avg_amount
from t1
where txn_type = 'deposit'
````
![B Q2](https://user-images.githubusercontent.com/98659820/159175643-ad359bcb-6d12-4e96-b57f-17b1b5411bf1.PNG)

**3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?**

```` sql
select * from customer_transactions

select txn_date, extract(month from txn_date) as month
from customer_transactions

with t1 as 
(select customer_id, extract(month from txn_date) as month, 
sum(case when txn_type = 'deposit' then 0 else 1 end) as deposit_count,
sum(case when txn_type = 'purchase' then 0 else 1 end) as purchase_count,
sum(case when txn_type = 'withdrawl' then 1 else 0 end) as withdrawl_count
from customer_transactions
group by customer_id, month)

select month, count(distinct customer_id) as customer_count
from t1
where deposit_count >= 2 and (purchase_count > 1 or withdrawl_count > 1)
group by month
````
![B Q3](https://user-images.githubusercontent.com/98659820/159175660-d35b30dd-d81f-44df-9bc7-5bbdf0bfa264.PNG)

**4. What is the closing balance for each customer at the end of the month?**

```` sql

-- CTE 1 - To identify transaction amount as an inflow (+) or outflow (-)
WITH monthly_balances AS (
  SELECT 
    customer_id, 
    (DATE_TRUNC('month', txn_date) + INTERVAL '1 MONTH - 1 DAY') AS closing_month, 
    txn_type, 
    txn_amount,
    SUM(CASE WHEN txn_type = 'withdrawal' OR txn_type = 'purchase' THEN (-txn_amount)
      ELSE txn_amount END) AS transaction_balance
  FROM data_bank.customer_transactions
  GROUP BY customer_id, txn_date, txn_type, txn_amount
),

-- CTE 2 - To generate txn_date as a series of last day of month for each customer
last_day AS (
  SELECT
    DISTINCT customer_id,
    ('2020-01-31'::DATE + GENERATE_SERIES(0,3) * INTERVAL '1 MONTH') AS ending_month
  FROM data_bank.customer_transactions
),

-- CTE 3 - Create closing balance for each month using Window function SUM() to add changes during the month
solution_t1 AS (
  SELECT 
    ld.customer_id, 
    ld.ending_month,
    COALESCE(mb.transaction_balance, 0) AS monthly_change,
    SUM(mb.transaction_balance) OVER 
      (PARTITION BY ld.customer_id ORDER BY ld.ending_month
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS closing_balance
  FROM last_day ld
  LEFT JOIN monthly_balances mb
    ON ld.ending_month = mb.closing_month
      AND ld.customer_id = mb.customer_id
),

-- CTE 4 - Use Window function ROW_NUMBER() to rank transactions within each month
solution_t2 AS (
  SELECT 
    customer_id, ending_month, 
    monthly_change, closing_balance,
    ROW_NUMBER() OVER 
      (PARTITION BY customer_id, ending_month ORDER BY ending_month) AS record_no
  FROM solution_t1
),

-- CTE 5 - Use Window function LEAD() to query value in next row and retrieve NULL for last row
solution_t3 AS (
  SELECT 
    customer_id, ending_month, 
    monthly_change, closing_balance, 
    record_no,
    LEAD(record_no) OVER 
      (PARTITION BY customer_id, ending_month ORDER BY ending_month) AS lead_no
  FROM solution_t2
)

SELECT 
  customer_id, ending_month, 
  monthly_change, closing_balance,
  CASE WHEN lead_no IS NULL THEN record_no END AS criteria
FROM solution_t3
WHERE lead_no IS NULL;
````

![B Q4](https://user-images.githubusercontent.com/98659820/159175672-5895a155-485c-42d2-b5b4-602cedf7b9f8.PNG)
