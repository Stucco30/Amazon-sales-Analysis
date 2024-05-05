create database sales;
use sales;
create table sales
(
invoice_id



VARCHAR(30),

branch



VARCHAR(5),

city



VARCHAR(30),

customer_type



VARCHAR(30),

gender

VARCHAR(10),

product_line
VARCHAR(100),

unit_price
DECIMAL(10, 2),

quantity
INT,

VAT

FLOAT(6, 4),

total

DECIMAL(10, 2),

date
DATE,

time
TIMESTAMP,

payment_method

varchar(30),

cogs

DECIMAL(10, 2),


gross_margin_percentage


FLOAT(11, 9),

gross_income
DECIMAL(10, 2),

rating
FLOAT(2, 1)
)

-- Feature engineering
-- Time of day payment_method

    ALTER TABLE sales 
ADD COLUMN time_of_day VARCHAR(30);


UPDATE sales
SET time_of_day = CASE
                    WHEN HOUR(SALES.TIME) >= 0 AND HOUR(SALES.TIME) < 12 THEN 'MORNING'
                    WHEN HOUR(SALES.TIME) >= 12 AND HOUR(SALES.TIME) < 18 THEN 'AFTERNOON'
                    ELSE 'EVENING'
                  END;
-- ADDING NEW COLUMNS DAYNAME
ALTER TABLE sales
ADD COLUMN day_name VARCHAR(50);

UPDATE sales
SET day_name = DATE_FORMAT(sales.date, '%W');

-- ADDING NEW COLUMNS MONTH 
ALTER TABLE sales
ADD COLUMN month_name VARCHAR(50);

UPDATE sales
SET month_name = DATE_FORMAT(sales.date, '%M');

-- Business Questions To Answer:
-- Q1.What is the count of distinct cities in the dataset?
select count(distinct(city))as distinct_city from sales; -- There are only three city in my dataset

-- Q2.For each branch, what is the corresponding city?
select distinct branch,city from sales;

-- Q3 What is the count of distinct product lines in the dataset?
select count(distinct(product_line))as distinct_product from sales; -- There are total 6 distinct products in this data
-- Q4 Which payment method occurs most frequently?
select max(payment_method),count(*)  from sales  group by payment_method order by payment_method desc -- Ewallet occur most frequently
-- Q5 Which product line has the highest sales?

select product_line,sum(gross_income) as highest_sales from sales group by product_line order by highest_sales desc
 -- Food and breveges has highest share  
 -- Q6. How much revenue is generated each month?
 select month_name,sum(total) as revenue from sales group by month_name order by revenue desc -- Jan month account for highest revenue
 
 -- Q7.In which month did the cost of goods sold reach its peak? 
 select month_name,max(cogs) as highest from sales group by month_name order by highest desc -- feb has highest cogs
 
 -- Q8. Which product line generated the highest revenue?
 select product_line,sum(total) as revenue from sales  group by product_line order by revenue desc -- Food and beverages as highest revenue
 -- Q9. In which city was the highest revenue recorded?
 select city,sum(total) as revenue from sales group by city order by revenue desc
 -- # city, revenue 'Naypyitaw' has highest among all.
 
 -- Q10. Which product line incurred the highest Value Added Tax?
 select product_line,max(vat) as tax from sales group by product_line order by tax desc 
 -- #  tax Fashion accessories, 49.65 is highest 
 -- Q11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
 select product_line,
 case 
 when gross_income > (select avg(gross_income) from sales ) then 'Good'
 else 'BAD'
 end as sales_performance 
 from  sales -- There are more no product that is performing below average
 
 -- Q12. Identify the branch that exceeded the average number of products sold.
 SELECT branch, SUM(quantity) AS total_quantity
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (
    SELECT AVG(branch_quantity)
    FROM (
        SELECT SUM(quantity) AS branch_quantity
        FROM sales
        GROUP BY branch
    ) AS avg_table
);
 --  branch   A has exceed the avg product sold
-- Q13. Which product line is most frequently associated with each gender?
with gender_product_count as (
select product_line,gender,count(*) as frequency,row_number () over(partition by gender order by count(*) desc) as rn
  from sales group by gender,product_line)
  select gender,product_line,frequency from gender_product_count where rn=1; -- male health and beauty and for female fashion and accesories 
-- Q14. Calculate the average rating for each product line?
select product_line, round(avg(rating),2) as avg_rating from sales group by product_line order by avg_rating desc
-- food and beverages has highest rating among all product
-- Q15. Count the sales occurrences for each time of day on every weekday ? 
select time_of_day,day_name,count(*) as sales_occurence from sales group by time_of_day,day_name order by time_of_day,day_name;

-- Q16. Identify the customer type contributing the highest revenue.
select customer_type,sum(total) as revenue from sales group by customer_type order by revenue desc 
-- Member customer type contributing highest revenue.

-- Q17. Determine the city with the highest VAT percentage.
select city,max(vat) as vat from sales group by city order by vat desc limit 1 
-- naypytiaw has highest vat percentage 

-- Q18. Identify the customer type with the highest VAT payments.
select customer_type,max(vat) as vat from sales group by customer_type order by vat desc limit 1 
-- member customer_type has highest vat payment.

-- Q19 What is the count of distinct customer types in the dataset?
select count(distinct(customer_type)) from sales -- distinct customer type are only member and only.
-- Q20. What is the count of distinct payment methods in the dataset?
select  count(distinct(payment_method)) as distinct_payment from sales
 -- there are three distinct payment method
 
 -- Q21.Which customer type occurs most frequently?
 select customer_type, count(*) as frequency from sales group by customer_type order by frequency desc
 -- member customer type are more frequent
 
 -- Q22. Identify the customer type with the highest purchase frequency.
 select customer_type, count(distinct(invoice_id)) as purchase_frequency from sales group by customer_type order by  purchase_frequency desc
 -- member has higher purchase frequency.
 
 -- Q23. Determine the predominant gender among customers.
 select gender,count(gender) as count from sales group by gender order by count desc
 -- Female is more in number than male 
 
 -- Q24. Examine the distribution of genders within each branch.
 select branch,gender,count(gender) as gender_count from sales group by branch,gender order by branch, gender
 -- branch A has more total(male and female)  but branch c has highest female 
 
 -- Q25. Identify the time of day when customers provide the most ratings.
 select time_of_day,count(*) as rating_frequency from sales group by time_of_day order by rating_frequency desc 
 -- In afternoon rating frequency is highest 
 -- Q26. Determine the time of day with the highest customer ratings for each branch.
select time_of_day,branch,rating_frequency from (
select time_of_day,branch,count(*) as rating_frequency,
Row_number() over (partition by branch order by count(*) desc) as rn 
from sales group by branch,time_of_day ) as rating_time where rn=1 order by branch;
-- Afternoon has has highest customer rating 

-- Q27. Identify the day of the week with the highest average ratings.
select day_name,avg(rating) as avg_rating from sales group by day_name order by avg_rating desc limit 1
-- monday has highest rating among all day.

-- Q28. Determine the day of the week with the highest average ratings for each branch.

select day_name,branch,avg_rating from (
select day_name,branch,round(avg(rating),2) as avg_rating,
Row_number() over (partition by branch order by avg(rating) desc) as rn 
from sales group by branch,day_name ) as avg_rating_time where rn=1 order by branch;
 -- day of week with highest average rating 









    
    

    



