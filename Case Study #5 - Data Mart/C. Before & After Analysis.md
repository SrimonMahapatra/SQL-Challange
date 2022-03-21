# Case Study #5 - Data Mart

## Solution - C. Before & After Analysis

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

Using this analysis approach - answer the following questions:

**1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?**

```` sql
with t1 as 
(select week_date, week_number, sum(sales) as total_sales
from clean_weekly_sales
where (week_number between 21 and 28) and (calender_year = 2020)
group by week_date, week_number),

t2 as 
(select 
sum(case when week_number between 21 and 24 then total_sales end) as before_change,
sum(case when week_number between 25 and 28 then total_sales end) as after_change
from t1)

select before_change, after_change, after_change - before_change as variance,
round(100 * (after_change-before_change)/ before_change,2) as perct
from t2
````
![C Q1](https://user-images.githubusercontent.com/98659820/159335906-9cbe14ab-08ba-4331-97a1-857f16e51c44.PNG)

**2. What is the total sales for the 12 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?**

```` sql
with t1 as 
(select week_date, week_number, sum(sales) as total_sales
from clean_weekly_sales
where (week_number between 13 and 37) and (calender_year = 2020)
group by week_date, week_number),

t2 as 
(select 
sum(case when week_number between 13 and 24 then total_sales end) as before_change,
sum(case when week_number between 25 and 37 then total_sales end) as after_change
from t1)

select before_change, after_change, after_change - before_change as variance,
round(100 * (after_change-before_change)/ before_change,2) as perct
from t2

````
**3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?**

**Part 1: How do the sale metrics for 4 weeks before and after compare with the previous years in 2018 and 2019?**

**Basically, the question is asking us to find the sales variance between 4 weeks before and after '2020-06-15' for years 2018, 2019 and 2020. Perhaps we can find a pattern here.**

**We can apply the same solution as above and add calendar_year into the syntax.**

```` sql
with t1 as 
(select calender_year, week_date, week_number, sum(sales) as total_sales
from clean_weekly_sales
where (week_number between 21 and 28) 
group by calender_year, week_date, week_number),

t2 as 
(select calender_year,
sum(case when week_number between 21 and 24 then total_sales end) as before_change,
sum(case when week_number between 25 and 28 then total_sales end) as after_change
from t1
group by calender_year)

select calender_year, before_change, after_change, after_change - before_change as variance,
round(100 * (after_change-before_change)/ before_change,2) as perct
from t2

select calender_year, before_change, after_change, after_change - before_change as variance,
round(100 * (after_change-before_change)/ before_change,2) as perct
from t2
````
![C Q3 1](https://user-images.githubusercontent.com/98659820/159339111-d951d7dd-1bbd-45f9-a6db-e0a325559d98.PNG)

**Part 2: How do the sale metrics for 12 weeks before and after compare with the previous years in 2018 and 2019?**

**Use the same solution above and change to week 13 to 24 for before and week 25 to 37 for after.**

```` sql
with t1 as 
(select calender_year, week_date, week_number, sum(sales) as total_sales
from clean_weekly_sales
where (week_number between 13 and 37) 
group by calender_year, week_date, week_number),

t2 as 
(select calender_year,
sum(case when week_number between 13 and 24 then total_sales end) as before_change,
sum(case when week_number between 25 and 37 then total_sales end) as after_change
from t1
group by calender_year)

select calender_year, before_change, after_change, after_change - before_change as variance,
round(100 * (after_change-before_change)/ before_change,2) as perct
from t2
````

![C Q3 2](https://user-images.githubusercontent.com/98659820/159339357-b7daa664-6cbe-4198-a82f-ee8298065101.PNG)






