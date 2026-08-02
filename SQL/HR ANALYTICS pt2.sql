USE HR;
------------------------------------------------------------
-- Cleaning the data 
------------------------------------------------------------

SELECT COUNT(*) AS Total_Employees FROM empdata;

SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='empdata'AND TABLE_SCHEMA='hr';

SELECT * FROM empdata
WHERE Age IS NULL OR Attrition IS NULL OR Department IS NULL;

SELECT EmployeeNumber, COUNT(*) FROM empdata
GROUP BY EmployeeNumber HAVING COUNT(*)>1;

SELECT DISTINCT Department FROM empdata;

SELECT DISTINCT Attrition FROM empdata;

SELECT DISTINCT Gender FROM empdata;

SELECT DISTINCT OverTime FROM empdata;

SELECT MIN(Age) AS Minimum_Age, MAX(Age) AS Maximum_Age FROM empdata;

SELECT MIN(MonthlyIncome), MAX(MonthlyIncome) FROM empdata;

SELECT MIN(TotalWorkingYears), MAX(TotalWorkingYears) FROM empdata;

SELECT MIN(YearsAtCompany), MAX(YearsAtCompany) FROM empdata;

--------------------------------------------------------------------------

-- WHICH DEPARTMENT HAS THE HIGHEST EMPLOYEE ATTRITION?
-- to identify dept with higher turnover and investigate possible causes such as workload, management or environment. 

select Department, count(*) AS Total_Employees,
sum(case when Attrition='Yes' then 1 else 0 end) AS Employees_Left,
round(sum(case when Attrition='Yes' then 1 else 0 end) * 100.0 / count(*),2) AS Attrition_Rate
from empdata
group by Department order by Attrition_Rate desc;

-- DOES OVERTIME INCREASE EMPLOYEE ATTRITION?
-- to find the reason whether employees who work overtime more likely to leave the company or not. 

select overtime, count(*) AS Total_Employees,
sum(case when Attrition='Yes' then 1 else 0 end) AS Employees_Left,
round(sum(case when Attrition='Yes' then 1 else 0 end) * 100.0 / count(*),2) AS Attrition_Rate
from empdata
group by overtime;
    
-- DOES JOB SATISFACTION IMPACT EMPLOYEE RETENTION?
-- to analyze whether employees with lower satisfaction levels are more likely to resignal

select JobSatisfaction, count(*) AS Employees, 
sum(case when attrition='Yes' then 1 else 0 end) AS Left_company
from empdata
group by JobSatisfaction order by JobSatisfaction;

-- WHICH AGE GROUP HAS THE HIGHEST EMPLOYEE ATTRITION?
-- to identify these groups and help hr to create targeted retention strategies.

select 
case 
when age between 18 and 25 then '18-25'
when age between 26 and 35 then '26-35'
when age between 36 and 45 then '36-45'
else '46+' end AS Age_Group,
count(*) AS Employees,
sum(case when attrition='Yes' then 1 else 0 end) AS Employees_left
from empdata
group by Age_Group; 

-- WHO ARE THE HIGHEST PAID EMPLOYEES IN THE COMPANY?
-- wanted to demonstrate the use of window functions by ranking employees based on their monthly income without grouping the data.

select EmployeeNumber, JobRole, MonthlyIncome,
rank() over(order by MonthlyIncome desc) AS Salary_Rank
from empdata;

-- WHO ARE THE TOP THREE HIGHEST PAID EMPLOYEES IN EACH DEPARTMENT?
-- wanted to demonstrate how cte and window functions can be used together to rank employees within each department.

with SalaryRank AS 
(select EmployeeNumber, Department, MonthlyIncome, 
rank() over(partition by department order by MonthlyIncome desc) AS Top_Rank
from empdata)
select * from SalaryRank where Top_rank <=3;

-- WHICH EMPLOYEES EARN MORE THAN THE AVERAGE SALARY OF THEIR DEPARTMENT?
-- wanted to demonstrate the use of correlated subqueries by comparing each employees salary with the average salary of their department.

select EmployeeNumber, Department, MonthlyIncome 
from empdata e where MonthlyIncome > ( select avg(MonthlyIncome) from empdata 
where Department = e.Department);

-- HOW DOES AN EMPLOYEE'S SALARY COMPARE WITH THE PREVIOUS EMPLOYEE'S SALARY?
-- wanted to demonstrate the use of the lag() function for comparing values between consecutive rows without using self joins.

select EmployeeNumber, MonthlyIncome, 
lag(monthlyIncome) over(order by MonthlyIncome) AS Previous_Salary 
from empdata;
