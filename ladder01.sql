-- # The Basics
-- ## Simple SELECTs

-- 1) Query all the data in the `pets` table.
SELECT * FROM PETS;

-- 2) Query only the first 5 rows of the `pets` table.
SELECT * FROM PETS LIMIT 5;

-- 3) Query only the names and ages of the pets in the `pets` table.
SELECT NAME , AGE FROM PETS;

-- 4) Query the pets in the `pets` table, sorted youngest to oldest.
SELECT * FROM PETS ORDER BY AGE;

-- 5) Query the pets in the `pets` table alphabetically.
SELECT * FROM PETS ORDER BY NAME;

-- 6) Query all the male pets in the `pets` table.
SELECT * FROM PETS WHERE SEX = 'M';

-- 7) Query all the cats in the `pets` table.
SELECT * FROM PETS WHERE SPECIES ILIKE '%CAT%';

-- 8) Query all the pets in the `pets` table that are at least 5 years old.
SELECT * FROM PETS where age >= 5;

-- 9) Query all the male dogs in the `pets` table. Do not include the sex or
-- species column, since you already know them.
SELECT name, age FROM PETS WHERE SEX = 'M';

-- 10) Get all the names of the dogs in the `pets` table that are younger
-- than 5 years old.
select name from pets WHERE SPECIES ILIKE '%dog%' and age >= 5;

-- 11) Query all the pets in the `pets` table that are either male dogs or
-- female cats.
select * from pets where (species ILIKE '%dog%' and SEX = 'M') or (species ILIKE '%cat%' and SEX = 'F');

-- 12) Query the five oldest pets in the `pets` table.
SELECT * FROM PETS where age >= 5 order by age desc limit 5;

-- 13) Get the names and ages of all the female cats in the `pets` table
-- sorted by age, descending.
SELECT name , age FROM PETS where species ILIKE '%cat%' and SEX = 'F' order by age desc;

-- 14) Get all pets from `pets` whose names start with P.
select * from pets where name ilike 'p%';

-- 15) Select all employees from `employees_null` where the salary is
-- missing.
select * from employees_null where salary is null;

-- 16) Select all employees from `employees_null` where the salary is below
-- $35,000 or missing.
select * from employees_null where salary < 35000 and salary > 0;

-- 17) Select all employees from `employees_null` where the job title is
-- missing. What do you see?
select * from employees_null where job is null;

-- 18) Who is the newest employee in `employees`? The most senior?
select * from employees order by startdate desc;

-- 19) Select all employees from `employees` named Thomas.
select * from employees where firstname ilike '%thomas%';

-- 20) Select all employees from `employees` named Thomas or Shannon.
select * from employees where firstname ilike '%thomas%' or firstname ilike '%shannon%';

-- 21) Select all employees from `employees` named Robert, Lisa, or any name
-- that begins with a J. In addition, only show employees who are _not_ in
-- sales. This will be a little bit of a longer query.
-- * _Hint:_ There will only be 6 rows in the result.
select * from employees where (firstname ilike '%Robert%' or firstname ilike '%Lisa%' or firstname ilike 'j%') and job != 'Sales';
-------------------------------------------------------------------------------------------------------------------------------------
-- ## Column Operations
-- 22) Query the top 5 rows of the `employees` table to get a glimpse of
-- these new data.
select * from employees limit 5;

-- 23) Query the `employees` table, but convert their salaries to Euros.
-- * _Hint:_ 1 Euro = 1.1 USD.
-- * _Hint2:_ If you think the output is ugly, try out the `ROUND()`
-- function.
select * , round(salary/1.1) as salary_euros from employees;

-- 24) Repeat the previous problem, but rename the column `salary_eu`.
select * , round(salary/1.1) as salary_eu from employees;

-- 25) Query the `employees` table, but combine the `firstname` and
-- `lastname` columns to be &quot;Firstname, Lastname&quot; format. Call this column
-- `fullname`. For example, the first row should contain `Thompson,
-- Christine` as `fullname`. Also, display the rounded `salary_eu` instead
-- of `salary`.
-- * _Hint:_ The string concatenation operator is `||`
select firstname , lastname , firstname || ' ' || lastname as fullname , round(salary/1.1) as salary_eu from employees;

-- 26) Query the `employees` table, but replace `startdate` with `startyear`
-- using the `SUBSTR()` function. Also include `fullname` and `salary_eu`.
select firstname || ' ' || lastname as fullname , round(salary/1.1) as salary_eu, date_part('YEAR',startdate) from employees;

-- 27) Repeat the above problem, but instead of using `SUBSTR()`, use
-- `STRFTIME()`.
select firstname || ' ' || lastname as fullname , round(salary/1.1) as salary_eu, to_char(startdate,'YYYY') from employees;

-- 28) Query the `employees` table, replacing `firstname`/`lastname` with
-- `fullname` and `startdate` with `startyear`. Print out the salary in USD
-- again, except format it with a dollar sign, comma separators, and no
-- decimal. For example, the first row should read `$123,696`. This column
-- should still be named `salary`.
-- * _Hint:_ Check out SQLite&#39;s `printf` function.
-- * _Hint2:_ The format string you&#39;ll need is `$%,.2d`. You should read
-- more about such formatting strings as they&#39;re useful in Python, too!

-- no decimal for salary version 
SELECT firstname || ' ' || lastname as fullname, date_part('YEAR',startdate) AS START_YEAR, to_char(salary,'$FM999,999,999') AS SALARY FROM EMPLOYEES;
-- MONEY() VERSION
SELECT firstname || ' ' || lastname as fullname, date_part('YEAR',startdate) AS START_YEAR, MONEY(SALARY) AS SALARY FROM EMPLOYEES;
-- ::MONEY VERSION... MAYBE EXTRA MARKS :D
SELECT firstname || ' ' || lastname as fullname, date_part('YEAR',startdate) AS START_YEAR, SALARY::MONEY AS SALARY FROM EMPLOYEES;

-- 29) Last year, only salespeople were eligible for bonuses. Create a
-- column `bonus` that is &quot;Yes&quot; if you&#39;re eligible for a bonus, otherwise
-- &quot;No&quot;.
select firstname , job, case 
	when job ilike '%sale%' then 'YES'
	ELSE 'NO'
	end as bonus
from employees;

-- 30) This year, only sales people with a salary of $100,000 or higher are
-- eligible for bonuses. Create a `bonus` column like in the last problem
-- for salespeople with salaries at least $100,000.
select firstname , job, case 
	when job ilike '%sale%' then 'YES'
	ELSE 'NO'
	end as bonus,
	salary
from employees
	where salary >= 100000;

-- 31) Next year, the bonus structure will be a little more complicated.
-- You&#39;ll create a `target_comp` column which represents an employee&#39;s
-- target total compensation after their bonus. Here is the company&#39;s bonus
-- structure:
select firstname, lastname, job, to_char(salary,'$FM999,999,999') AS SALARY ,to_char(
 salary + case 
 			when salary > 1000000 and job ilike '%sales%' then salary*0.10
			when salary < 1000000 and job ilike '%sales%' then salary*0.05
			when job ilike'%administrator%' then salary*0.05
			else 0
			end,
			'$FM999,999,999'
) as target_comp
from employees;