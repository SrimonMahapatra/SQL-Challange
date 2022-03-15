## Solution: A Customers's Journey

Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

```` sql
select s.customer_id, s.plan_id, p.plan_name, s.start_date
from plans p
join subscriptions s on  p.plan_id = s.plan_id
where s.customer_id in (1,2,11,13,15,16,18,19)
order by customer_id
````
![A  Customer Journey](https://user-images.githubusercontent.com/98659820/158400905-91bfbbab-a42a-4d0a-b8c8-b5b609d4905f.png)

- From the above results i will choose 3 customers and their onboarding journey
- Customer 1 Joined foodie fi on 1st August 2021 and after 7 days trail period he subscribed to basic monthly plan
- Customer 11 Joined foodie fi on 19th November 2021 and after 7 days od trail period he unsubcribed the service
- Customer 13 Joined foodie fi on 15th December 2021 and after 7 days of trail period on 15th December 2020 he subscribed to basic monthly, and again after 3 months on 29th March 2021 he upgraded his subscription to pro monthly pack

***

Click [here](https://github.com/SrimonMahapatra/SQL-Challange/blob/main/Case%20Study%20%233%20-%20Foodie%20Fi/B.%20Data%20Analytics%20Question.md) to solutions for B. Data Analytics Question 

