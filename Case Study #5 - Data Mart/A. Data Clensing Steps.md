# Case STudy #5 - Data Mart

## Solution - A. Data Clesnsing Steps

In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:

- Convert the week_date to a DATE format

- Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc

- Add a month_number with the calendar month for each week_date value as the 3rd column

- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values

- Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value

<img width="166" alt="image" src="https://user-images.githubusercontent.com/81607668/131438667-3b7f3da5-cabc-436d-a352-2022841fc6a2.png">
  
- Add a new `demographic` column using the following mapping for the first letter in the `segment` values:  

| segment | demographic | 
| ------- | ----------- |
| C | Couples |
| F | Families |

- Ensure all `null` string values with an "unknown" string value in the original `segment` column as well as the new `age_band` and `demographic` columns
- Generate a new `avg_transaction` column as the sales value divided by transactions rounded to 2 decimal places for each record

**Answer:**

## Create New Table `clean_weekly_sales`

Let's construct the structure of `clean_weekly_sales` table and lay out the actions to be taken.

_`*` represent new columns_

| Columns | Actions to take |
| ------- | --------------- |
| week_date | Convert to `DATE` using `TO_DATE`
| week_number* | Extract number of week using `DATE_PART` 
| month_number* | Extract number of month using `DATE_PART` 
| calendar_year* | Extract year using `DATE_PART`
| region | No changes
| platform | No changes
| segment | No changes
| age_band* | Use `CASE WHEN` and based on `segment`, 1 = `Young Adults`, 2 = `Middle Aged`, 3/4 = `Retirees` and null = `Unknown`
| demographic* | Use `CASE WHEN` and based on `segment`, C = `Couples` and F = `Families` and null = `Unknown`
| transactions | No changes
| avg_transaction* | Divide `sales` with `transactions` and round up to 2 decimal places
| sales | No changes

### Solution:

```` sql
drop table clean_weekly_sales
drop table if exists clean_weekly_sales;
create temp table clean_weekly_sales as 
(select 
to_date (week_date, 'DD/MM/YY') as week_date, 
extract (week from to_date (week_date, 'DD/MM/YY')) as week_number,
extract (month from to_date (week_date, 'DD/MM/YY')) as month,
extract (year from to_date (week_date, 'DD/MM/YY')) as calender_year,
region, platform,segment,
case 
when right(segment, 1) = '1' then 'Young Adults'
when right(segment, 2) = '2' then 'Middle Aged'
when right(segment,1) in ('3', '4') then 'Retirees'
else 'Unknown' end as age_band,
case
when left(segment, 1) = 'C' then 'couples'
when left(segment, 1) = 'F' then 'Families'
else 'Unknown' end as demographic, 
transactions,
round((sales::numeric/transactions),2) as avg_transaction,
sales
from data_mart.weekly_sales)
````
<img width="1148" alt="image" src="https://user-images.githubusercontent.com/81607668/131474035-528e0af6-d848-427b-bbd9-73956a775f86.png">




