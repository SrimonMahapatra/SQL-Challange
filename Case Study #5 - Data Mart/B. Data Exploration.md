 # Case Study #5 - Data Mart
 
 Solution - B. Data Exploration
 
 **1. What day of the week is used for each week_date value?**
 
 ```` sql
 select distinct(to_char(week_date, 'day')) as week_day
from clean_weekly_sales
````
![A Q1](https://user-images.githubusercontent.com/98659820/159183975-16746074-c33d-44c7-bcef-c5656a0df9a2.PNG)

**2. What range of week numbers are missing from the dataset?**

```` sql
with t1 as 
(select generate_series(1,52) as week_number)

select distinct t1.week_number
from t1 
left outer join clean_weekly_sales as cws on t1.week_number = cws.week_number
where cws.week_number is null
````
![A Q2](https://user-images.githubusercontent.com/98659820/159184202-20c4987e-ad8d-4101-b46b-e94ec0d9b4b9.PNG)


**3. How many total transactions were there for each year in the dataset?**

```` sql
select calender_year, sum(transactions) as total_transaction
from clean_weekly_sales
group by calender_year
````
![A Q3](https://user-images.githubusercontent.com/98659820/159184214-f649a9fb-6e3c-45a3-bac7-9abc8dba1da9.PNG)


**4. What is the total sales for each region for each month?**

```` sql
select region,month, sum(sales) as total_sales
from clean_weekly_sales
group by region, month
order by region, month
````
![A Q4](https://user-images.githubusercontent.com/98659820/159184217-2c513268-5ba3-4c2f-9c66-16bf545cf981.PNG)


**5. What is the total count of transactions for each platform?**

```` sql
select platform, sum(transactions) as count_transactions
from clean_weekly_sales
group by platform
````
![A Q5](https://user-images.githubusercontent.com/98659820/159184227-571696d5-296d-4485-b969-7728f1a30dd9.PNG)


**6. What is the percentage of sales for Retail vs Shopify for each month?**

```` sql
with t1 as 
(select calender_year, month, platform, sum(sales) as monthly_sale
from clean_weekly_sales
group by calender_year, month, platform)

select calender_year, month, 
round(100 * max(case 
when platform = 'Retail' then monthly_sale else null end)/ sum(monthly_sale),2) as retail_perct,
round(100 * max(case 
when platform = 'Shopify' then monthly_sale else null end)/ sum(monthly_sale),2) as Shopify_perct
from t1
group by calender_year, month
````
![A Q6](https://user-images.githubusercontent.com/98659820/159184235-e263c50b-162b-45ab-a90d-86ae2c5178c8.PNG)


**7. What is the percentage of sales by demographic for each year in the dataset ?**

```` sql
with t1 as 
(select calender_year, demographic, sum(sales) as yearly_sales
from clean_weekly_sales
group by calender_year, demographic)

select calender_year, 
round(100 * max(case 
when demographic = 'couples' then yearly_sales else null end) / sum(yearly_sales), 2) as couple_percentage,
round(100 * max(case 
when demographic = 'Families' then yearly_sales else null end) / sum(yearly_sales), 2) as couple_percentage,
round(100 * max(case 
when demographic = 'Unknown' then yearly_sales else null end) / sum(yearly_sales), 2) as couple_percentage
from t1
group by calender_year
````
![A Q7](https://user-images.githubusercontent.com/98659820/159184243-4e724058-db3e-4a68-8e9a-ceed471a2ea5.PNG)


**8. Which age_band and demographic values contribute the most to Retail sales?**

```` sql
with t1 as 
(select age_band, demographic, sum(sales) as retail_sales, (select sum(sales)
from clean_weekly_sales) as total_sales
from clean_weekly_sales
where platform = 'Retail'
group by age_band, demographic
order by retail_sales desc)

select age_band, demographic, retail_sales, round(retail_sales::numeric/total_sales::numeric * 100,2) as perct
from t1
````
![A Q8](https://user-images.githubusercontent.com/98659820/159184249-b4276d49-8eee-416d-8723-ceb5c39accec.PNG)


**9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?**

```` sql
select * from clean_weekly_sales

select calender_year, platform,
round(avg(avg_transaction),0) as avg_transaction_row,
sum(sales) / sum(transactions) as avg_transaction_total
from clean_weekly_sales
group by calender_year, platform
````
![A Q9](https://user-images.githubusercontent.com/98659820/159184252-103d02a3-d43a-4ebe-b2c0-726b1bd24c50.PNG)


view solution for C. Before & After Analysis

