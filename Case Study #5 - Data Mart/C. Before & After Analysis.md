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





