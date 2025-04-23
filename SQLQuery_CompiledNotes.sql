--alter authorization on database::[Sales_Demo]
--this command changes the compartibility level property from one release year to another. SSMS 2022 runs from 100 - 160
--Alternatively, right click on the dB. Click on properties; options
ALTER DATABASE [SalesDB]
SET COMPATIBILITY_LEVEL =  90 
go
--OR use the below
-- to upgrade compartibility level: https://youtu.be/ciWKxRQ0R-I?si=BrAkAE2EDIjLKFL1
select name, compartibility_level, from sys.database where name = 'salesDB'

select @@VERSION[SalesDB]




/*

DDL				DDL				DDL				DDL				DDL				DDL
	CREATING A NEW TABLE CALLED PERSONS
	ALTER -- ADD A NEW COLUMN, EMAIL O THE PERSONS TABLE
	DROP -- if you wan to change the position of acolumn in a table, or you don't need the columm
*/

CREATE table persons(
	ID int not null, --identity(1,1) to set it to an SK
	PersonName nvarchar(50) not null,
	BirthDate date,
	Phone nvarchar(50) not null,
	constraint pk_persons primary key (id)  --DDL create
)

-- ALTER
alter table persons
add email nvarchar(50) not null

select * from persons


--DROP column
alter table persons
drop column email

--DROP TABLES
drop table persons    -- execute and refresh dB


/*
DML					DML					DML				DML				DML
	INSERT VALUES MANUALLY
	inserting data from one table to another
	CRUD -- Insert, Retrieve, Update, Delete
*/


select * from sales.Customers

  --INSERT INTO                        --A>>>>INSERT INTO                  --INSERT INTO
INSERT INTO table_name (colum1, colum2, colum3,... column)
VALUES (value1, value2, value3, ..., valuen),
	   (value1, value2, value3, ..., valuen),
	   (value1, value2, value3, ..., valuen) -- multiple inserts

insert into sales.Customers (CustomerID, firstname, LastName, country, score)
values 
	(6, 'Anna', 'Server' , 'USA', null),
	(7, 'Jon', 'Boyega', null, 100)


--B>>>> Copying data from 'customers' table into 'persons'

insert into persons (id, personname, birthdate, phone)
select
	CustomerID,
	firstname,
	null emptyCol,
	'unknown' phone
from Sales.Customers

select * from persons	

	
--UPDATE                    --UPDATE			 --UPDATE			 --UPDATE    --UPDATE
select * from sales.employees where FirstName = 'Ann'

update sales.employees
set firstname = 'Ann'
where firstname = 'Mary'

--Example 2: Change the score of customer with ID 10 to 0 and update the country to UK
select * from sales.customers

update sales.Customers
set Score = 200,
	country = 'UK'
where CustomerID = 7

--Example 3: Update all customers where score is null to 0
update sales.Customers
set Score = 0
where score is null

select * from sales.Customers where score is null


--DELETE RECORDS				--DELETE RECORDS					--DELETE RECORDS

delete from employees
where companyname = 'Small Bank Corporation'

--Example2: Delete all customers with IDs greater than 5
delete from sales.Employees
where employeeid  > 5


select* from sales.Employees where employeeid  > 5

--DELETING DATA FROM A TABLE USING TRUNCATE FOR LARGE DATA
truncate table persons




use[Sales_Demo]

select * from sales.Orders

-- Step 1: Find the total sales per customer

WITH CTE_Total_Sales AS
		(
		select
			customerID,
			sum(sales) TotalSales
		from sales.Orders
		group by CustomerID
		)
--Main Query
select customerid from CTE_Total_Sales

select 
	CustomerID,
	FirstName,
	LastName
from sales.Customers c
left join CTE_Total_Sales cts
on cts.CustomerID = c.CustomerID



select 
	customerid,
	country,
	avg(score) avgscore
from sales.Customers 
where score != 0                  -- filters other
group by CustomerID, Country      -- sorts aggregates
having avg(score) > 430           -- only filters aggregates


--2 most recent orders
select top 2 
	OrderID,
	OrderDate,
	Sales,
	'New customer' customerType   -- static value
from sales.Orders
order by OrderDate desc           -- sorts other

/*
WHERE CLAUSE

COMPARISON OPERATRORS: =,   <>/=!   ,   > ,  >=,    <,  <=
LOGICAL OPERATORS: AND, OR, NOT   --and(all conditions must be true)   --or(atleast one condition must be true),  --not(excludes matching values)
RANGE OPERATPRS: BETWEEN    --check if a value is within a range
MEMBERSHIP OPRATORS: IN, NOT IN    -- checks if a value exists in a list
SEARCH OPERATOR: LIKE --to search for a pattern in a text
*/

--Example 

--OR
select * from sales.Customers where country = 'germany' or country = 'usa'
--IN    same result, cleaner read
select * from sales.Customers where country in ('germany','usa')

--LIKE
select * from sales.Customers where country like '%a'
select * from sales.Customers where country like '_%a'


/*
JOINS AND SET OPERATORS   ...COMBINE TABLES
JOINS combine tables side by side by their columns while SET OPERATORS combine tables by stacking rows, one tale on top of the other.

JOIN TYPES: INNER, OUTER, LEFT, RIGHT, FULL, .>>>>    ADV: LEFT-ANTI, CROSS,  RIGHT-ANTI, FULL ANTI - they exclude common data between tables

SET OPERATOR TYPES: UNION, UNION ALL, EXCEPT and INTERSECT

*/

--JOIN
select * from sales.Customers

select * from sales.Orders

--EXAMPLE: GET ALL CUTOMERS ALONG WITH THEIR ORDERS, BUT ONLY FOR CUSTOMERS WHO HAVE PLACED AN ORDER --inner join
--EXMAPLE: GET ALL CUSTOMERS ALONG WITJ THEIR ORDERS INCLUDING THOSE WITHOUT ORDERS --left join
--EXAMPLE: GET ALL CUSTOMERS ALONG WITH THEIR ORDERS, INCLUDING ORDERS WITHOUT MATCHING CUSTOMERS - right join 
--EXMAPLE: GET ALL CUSTOMERS AND ORDERS, EVEN IF THERE'S NO MATCH --full join


select 
	c.CustomerID,
	c.FirstName,
	o.orderid,
	o.sales
from Sales.Customers c
inner join Sales.Orders o
on o.CustomerID = c.CustomerID

--LEFT JOIN returns all the rows on the left table and all the matching data on the right. Vice versa RIGHT JOIN  

/*
ANTI JOINS returns only unmatching data --reverse of the above joins  --uses filters(where clause)
*/
--EXMAPLE: GET ALL CUSTOMERS THAT DIDN'T PLACE ANY ORDERS --left anti join ... where orders.id  is null
--EXAMPLE: GET ALL ORDERS THAT DON'T HAVE CUSTOMERS INPUTED -- right anti join ... where customers.id is null
select * 
from sales.Customers c
full join sales.orders o
on o.customerid = c.CustomerID
where c.customerid is null or o.CustomerID is null

--get all customers along with their orders, but only for customers who have placed an order (without using INNER JOIN)

select *
from Sales.Customers c
full join Sales.Orders o
on o.customerid = c.CustomerID
where o.Quantity is not null

select *
from Sales.Orders o
left join Sales.Customers c
on o.customerid = c.CustomerID
where o.CustomerID is not null

--Using  the SalesDB, retrieve a list of all orders along with the related customer, product, and employee details.

select * from sales.products
select * from sales.Customers
select * from sales.Employees
select * from sales.Orders

select o.OrderID, e.employeeID,	
	(e.FirstName + ' ' + e.LastName) SalesPerson,
	(c.FirstName + ' ' + c.LastName) CustomerName,
	p.Product,
	p.Price,
	o.OrderDate
from sales.Orders o
inner join Sales.Customers c on c.CustomerID = o.CustomerID
inner join Sales.Employees e on e.EmployeeID = o.SalesPersonID
inner join Sales.Products p on p.ProductID = o.ProductID

update Sales.Employees
set LastName = 'Jonah'
where EmployeeID = 3
-- SIDE NOTE: WHILE JOINING TABLES, ANY NULL COLUMN, IF CONCATINATED WITH A NON-NULL CELL, WILL RETURN A NULL VALUE


/*
SET OPERATORS: UNION, UNION ALL, EXCEPT, INTERCEPT
ALL COULUMNS MUST MATCH IN LENGTH AND DATA TYPE...EXAMPLE TO BE EXECUTED IN ORDER. ADD:CUSTOMERID COL = EMPLOYEEID --> SAME COLUMN LENGTH AND DATA TYPE
ORDER OF COLUMNS i.e same columns must match orderly in each query unioned e.g employeeid, firstname from table 1  = customerid, firstname from table 2
only the first query requires an alias, subsequent queries take on the aliased name
order by can only be used at the once, at the end of the query

*/

select 
	firstname,
	LastName
from Sales.Customers

select 
	firstname,
	LastName
from Sales.Employees

--UNION stacks the rows and arranges in alphabetical order. It returns distinct rows from both querys
--UNION ALL doesn't remove duplicates. it returns values faster and helps find duplicates within tables
--EXCEPT returns distinct values in the first table that are not in the second table		e.g.  find customers that are not employees at the same time
--INTERSECT returns all values an 'inner join' does i.e matching values on both or all tables joined


select 
	firstname,
	LastName
from Sales.Customers

EXCEPT

select 
	firstname,
	LastName
from Sales.Employees


/*
DATA ANALYSIS EXPRESSION
orders data are stored in  separate tables (orders and ordersArchive)
combine all orders data into one report without duplicates

*/

select * from Sales.Orders
select * from Sales.OrdersArchive

select 
	'orders' as SourceTable,
	[OrderID]
   ,[ProductID]
   ,[CustomerID]
   ,[SalesPersonID]
   ,[OrderDate]
   ,[ShipDate]
   ,[OrderStatus]
   ,[ShipAddress]
   ,[BillAddress]
   ,[Quantity]
   ,[Sales]
   ,[CreationTime]
from Sales.Orders

union

select
	'ordersarchive' as SourceTable
	  ,[OrderID]
      ,[ProductID]
      ,[CustomerID]
      ,[SalesPersonID]
      ,[OrderDate]
      ,[ShipDate]
      ,[OrderStatus]
      ,[ShipAddress]
      ,[BillAddress]
      ,[Quantity]
      ,[Sales]
      ,[CreationTime]
from Sales.OrdersArchive

order by OrderID

 --SQL functions

--TRIM :: Find customers whose first name contains leading or trailing spaces 
select *from Sales.Customers

select
	firstname,
	len(firstname) fName_Len,
	len(trim(firstname)) fnameTrim_len
from Sales.Customers
where	len(firstname) !=	len(trim(firstname))

--REPLACE can replce an unwanted value with a wanted value or blank (' ')
select
'123-456-7805',
replace('123-456-7805', '-', ' ')

select
'report.txt' old_name,
replace('report.txt', 'txt', 'csv') new

--SUBSTRING :: retrieve a list of all customers' first names after removing the first character
--substring(value, start_position, end position)

select 
	firstname,
	substring(firstname, 2, len(firstname)) altered
from sales.customers


/*
DATE & TIME FUNCTOIN
*/

--date & time snippet
SELECT GETDATE() TODAY
FROM SALES.ORDERS

/*
PART EXTRACTION
extracting the date, day , month, year
*/

SELECT 
	orderid,
	creationTime,
	year(creationtime) year,
	month(creationtime) month,
	day(creationtime) day
from Sales.Orders

--date part
--DatePart(part, date) <--part you want to extract & date you want to extract from


SELECT 
	orderid,
	creationTime,
	datepart(year, creationtime) dp_year,
	datepart(month, creationtime) dp_month,
	datepart(day, creationtime) dp_day,
	datepart(hour, creationtime) dp_hour,
	datepart(quarter, creationtime) Quater,
	datepart(weekday, creationtime) weekday,
	year(creationtime) year,
	month(creationtime) month,
	day(creationtime) day
from Sales.Orders

--DateName returns the name of the dates as string data types  e.g. months, day etc

SELECT 
	orderid,
	creationTime,
	datename(month, creationtime) dm_month,
	datename(weekday,  creationtime) dn_day
from Sales.Orders

--DATETRUNC
SELECT 
	orderid,
	creationTime,
	dateTRUNC (minute, creationtime) dt_minute,
	dateTRUNC (year, creationtime) dt_year,
	dateTRUNC (second, creationtime) dt_secs,
	datename(weekday,  creationtime) dn_day
from Sales.Orders

--eomonth returns the last day of the month
sELECT 
	orderid,
	creationTime,
	year(creationtime) year,
	eomonth(creationtime) eo_month,
	datetrunc(MONTH, eomonth(creationtime)) dt_EOmonth,
	month(creationtime) month
from Sales.Orders

--EXAMPLE :: HOW MANY ORDERS WERE PLACED EACh YEAR?
--EXAMPLE :: HOW MANY ORDERS WERE PLACED EACh monht?
--EXAMPLE :: SOW ALL ORDERS PLACED DURING THE MONTH OF FEBRUARY -- FILTER ON ORDERDATE = 2 



select * from sales.orders

select 
	count(*) orders,
	datename(month, creationtime) month,
	year(creationtime) year
from sales.orders
group by datename(month, creationtime), year(creationtime) 
--order by orders 

update sales.Customers
set Score = 0
where customerid = 6

--MATHEMATICAL OPERATIONS    --IS NULL & COALESCE 
select * from sales.Customers

select
	customerid, 
	firstName + ' ' + coalesce(LastName, '') Name,
	score,
	coalesce(score, 0) + 10 ScoreBonus
from sales.Customers
--EXAMPLE:: SORT THE CUSTOMERS FROM LOWEST TO HIGHEST SCORES, WITH NULLS APPEARING LAST

select 
	customerid,
	score
--	case when score is null then 1 else 0 end flag
from sales.Customers
order by 	case when score is null then 1 else 0 end, score 

--Find the sales price for each order by dividing the sales by the quantity     NULLIF
select * from sales.Orders

select 
	orderid,
	customerid,
	sales,
	Quantity,
	sales / nullif(Quantity,0) SalesPrice
from sales.orders

-- IS NULL RETURNS TRUE IF THE VALUE IS NULL; IS NOT NULL returns true if a value is not null    RETURNS BOOLEANS


--list all customers who do not have scores
select * from sales.customers where score is null

--list all customers who have scores
select * from sales.customers where score is not null

--list all details for customers who have not placed any orders
/*
select * from sales.Customers
select * from sales.Orders

select 
	o.OrderID
		,c.*
from sales.Customers c
inner join sales.Orders o
on o.CustomerID = c.CustomerID
*/

select 
	o.OrderID,
	c.*
from sales.Customers c
left join sales.Orders o
on o.CustomerID = c.CustomerID
where orderid is null


-- case statement
/*
--generate a report showing the total sales for each category:
- High: If the sales higher tjan 50
- Medium: If the sales between 20 and 50
- Low: If the sales equal or lower than 20
sort the result from highest to lowest
*/
select * from sales.orders
select * from sales.Products

select
	category,
	sum(sales) TotalSales
from
	(select
		OrderID
		,sales
		,case 
			when Sales > 50 then 'High'
			when Sales > 20 then 'Medium'
			else 'Low'
		end Category
	from sales.Orders o
	) t
group by  Category
order by TotalSales desc


--EXAMPLES:: Generating full text names of gender
select * from sales.Employees

select 
	EmployeeID
	firstname,
	lastname,
	case 
		when gender = 'm' then 'Male'
		when gender = 'f' then 'Female'
	end FullGender
from Sales.Employees

--it can also be written as:
select 
	EmployeeID,
	firstname,
	lastname,
	case Gender
		when 'm' then 'Male'
		when 'f' then 'Female'
	end FullGender
from Sales.Employees



/*
		WINDOW FUNCTION							WINDOW FUNCTION						WINDOW FUNCTION
these are used in place of group by when there are multiple parameters to be grouped by
		*/
--EXAMPLE:: Find the average scores of customers and treat nulls as 0. Additionally provide details such as CustomerID and LastName

select
	customerid,
	lastname,
	score,
	case 
		when score is null then 0
		else score
	end CleanScore,								---	case statement
	avg(score) OVER() AvgScore,					--- window function
	avg(case 
			when score is null then 0 
			else score			
		end) OVER() AvgScore2				    --- window function
from sales.Customers



--EXAMPLE:  Find the total sales for each product. Additionally, provide details such as orderID, orderDate

select
	orderID, orderdate,
	productid,
	sum(sales) over(partition by productid) TotalSalesByProducts
from sales.orders


--EXAMPLE:  Find the total sales for each product. 
--Additionally, provide details such as orderID, orderDate
--Find the total sales for each combination of product and order status
--Additionally, provide details such as ordrid, order date

select
	productid, orderid, orderdate, OrderStatus,
	sales,
	sum(sales) over() TotalSales,
	sum(sales) over(partition by productid) TotalSalesbyProduct,
	sum(sales) over(partition by productid, orderstatus) TotalSalesbyProductandStatus
from sales.orders

--RANK
select orderid, orderdate, sales,
	rank() over(order by sales desc) rankSales
from sales.Orders

--baRAA CLASS: 9:49:04