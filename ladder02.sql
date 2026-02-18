-- 32) How many rows are in the `pets` table?
select count(*) from pets;

-- 33) How many female pets are in the `pets` table?
select count(*) as female_count from pets where sex ilike '%f%';

-- 34) How many female cats are in the `pets` table?
select count(*) as female_cats_count from pets where sex ilike '%f%' and species ilike '%cat%';

-- 35) What's the mean age of pets in the `pets` table?
select avg(age) as mean_age from pets;

-- 36) What's the mean age of dogs in the `pets` table?
select avg(age) as dogs_mean_age from pets where species = 'dog';

-- 37) What's the mean age of male dogs in the `pets` table?
select avg(age) as male_dogs_mean_age from pets where species ilike 'dog' and sex ilike 'm';

-- 38) What's the count, mean, minimum, and maximum of pet ages in the `pets` table?
--     * _NOTE:_ SQLite doesn't have built-in formulas for standard deviation or median!
select count(age), avg(age), max(age), min(age) from pets;

-- 39) Repeat the previous problem with the following stipulations:
--     * Round the average to one decimal place.
--     * Give each column a human-readable column name (for example, "Average Age")
select count(age) as pets_age_count, round(avg(age), 1) as pets_average_age, max(age) as maximum_pets_age, min(age) as minimum_pets_age from pets;


-- 40) How many rows in `employees_null` have missing salaries?
select count(*) from employees_null where salary is null;


-- 41) How many salespeople in `employees_null` having _non_missing_ salaries?
select count(*) from employees_null where salary is not null and job ilike '%sales%';


-- 42) What's the mean salary of employees who joined the company after 2010?
-- Go back to the usual `employees` table for this one.
--     * _Hint:_ You may need to use the `CAST()` function for this.
--     To cast a string as a float, you can do `CAST(x AS REAL)`
select avg(cast(salary as real)) from employees where startdate > '2010-12-31';

-- 43) What's the mean salary of employees in Swiss Francs?
--     * _Hint:_ Swiss Francs are abbreviated "CHF" and 1 USD = 0.97 CHF.
select avg(salary * 0.97) as mean_salary_chs from employees;

-- 44) Create a query that computes the mean salary in USD as well as CHF.
-- Give the columns human-readable names (for example "Mean Salary in USD").
-- Also, format them with comma delimiters and currency symbols.
--     * _NOTE:_ Comma-delimiting numbers is only available for integers in SQLite,
-- so rounding (down) to the nearest dollar or franc will be done for us.
--     * _NOTE2:_ The symbols for francs is simply `Fr.` or `fr.`.
-- So an example output will look like `100,000 Fr.`.

--no decimal 
select to_char(round(avg(salary)), '$fm999,999,999') as "mean salary in usd",to_char(round(avg(salary * 0.97)), 'fm999,999,999') || ' fr.' as "mean salary in chf" from employees;
--money() version 
select round(avg(salary))::money as "mean salary in usd", round(avg(salary * 0.97))::money as "mean salary in chf" from employees;

-- ## Aggregating Statistics with GROUP BY
-- 45) What is the average age of `pets` by species?
select species, avg(age) as avg_species_age from pets group by species;

-- 46) Repeat the previous problem but make sure the species label is also displayed! Assume this behavior is always being asked of you any time you use `GROUP BY`.
select species, avg(age) as avg_species_age from pets group by species;

-- 47) What is the count, mean, minimum, and maximum age by species in `pets`?
select species, count(age) as species_age_count, avg(age) as species_avg_age, max(age) as species_max_age, min(age) as species_min_age from pets group by species;

-- 48) Show the mean salaries of each job title in `employees`.
select job, avg(salary) as avg_salary from employees group by job;

-- 49) Show the mean salaries in New Zealand dollars of each job title in `employees`.
--     * _NOTE:_ 1 USD = 1.65 NZD.
select job, avg(salary * 1.65) as avg_salary_nzd from employees group by job;

-- 50) Show the mean, min, and max salaries of each job title in `employees`, as well as the numbers of employees in each category.
select job, count(*) as employees_count, avg(salary) as avg_salary_job, max(salary) as max_salary_job, min(salary) as min_salary_job from employees group by job;

-- 51) Show the mean salaries of each job title in `employees` sorted descending by salary.
select job, avg(salary) as avg_salary_job from employees group by job order by avg_salary_job desc;

-- 52) What are the top 5 most common first names among `employees`?
select firstname, count(*) as name_count from employees group by firstname order by name_count desc limit 5;

-- 53) Show all first names which have exactly 2 occurrences in `employees`.
select firstname, count(*) as name_count from employees group by firstname having count(*) = 2;

-- 54) Take a look at the `transactions` table to get a idea of what it contains.
-- Note that a transaction may span multiple rows if different items are purchased
-- as part of the same order. The employee who made the order is also given by their ID.
select * from transactions;

-- 55) Show the top 5 largest orders (and their respective customer) in terms of the numbers of items purchased in that order.
select order_id, customer, sum(quantity) as total_items from transactions group by order_id, customer order by total_items desc limit 5;

-- 56) Show the total cost of each transaction.
--     * _Hint:_ The `unit_price` column is the price of _one_ item. The customer may have purchased multiple.
--     * _Hint2:_ Note that transactions here span multiple rows if different items are purchased.
select order_id, customer, sum(unit_price*quantity) as total_cost from transactions group by order_id, customer order by order_id;

-- 57) Show the top 5 transactions in terms of total cost.
select order_id, customer, sum(unit_price*quantity) as total_cost from transactions group by order_id, customer order by sum(unit_price*quantity) desc limit 5;

-- 58) Show the top 5 customers in terms of total revenue (ie, which customers have we done the most business with in terms of money?)
select customer, sum(unit_price*quantity) as total_revenue from transactions group by customer order by total_revenue desc limit 5;

-- 59) Show the top 5 employees in terms of revenue generated (ie, which employees made the most in sales?)
select employee_id, sum(unit_price*quantity) as total_revenue from transactions group by employee_id order by total_revenue desc limit 5;

-- 60) Which customer worked with the largest number of employees?
--     * _Hint:_ This is a tough one! Check out the `DISTINCT` keyword.
select customer, count(distinct employee_id) as number_of_employees from transactions group by customer order by count(distinct employee_id) desc limit 1;

-- 61) Show all customers who've done more than $80,000 worth of business with us.
select customer, sum(unit_price*quantity) as total_revenue from transactions group by customer having sum(unit_price*quantity) > 80000 order by sum(unit_price*quantity) desc;