use MYNTRA;
select * from MNT;

select count(*) from MNT

-- Data cleaning

-- Findout the dublicates values



select invoiceno, stockcode, description, quantity, invoicedate, unitprice, CustomerID, country,
count(*) as 'count' 
from MNT
group by invoiceno, stockcode, description, quantity, invoicedate, unitprice, CustomerID, country
having count(*) > 1

-- We need to delete duplicate values

with CTE AS (
select *, ROW_NUMBER() over(partition by invoiceno, stockcode, description,
quantity, invoicedate, unitprice, CustomerID, country order by (select null)) as 'rn'
from MNT
)
DELETE FROM CTE
WHERE RN >1;

-- find the null values

select 
	sum(case when invoiceno is null then 1 else 0 end ) as null_invoice,
	sum(case when stockcode is null then 1 else 0 end ) as null_stockcode,
	sum(case when description is null then 1 else 0 end ) as null_description,
	sum(case when quantity is null then 1 else 0 end ) as null_quantity,
	sum(case when invoicedate is null then 1 else 0 end ) as null_invoicedate,
	sum(case when unitprice is null then 1 else 0 end ) as null_unitprice,
	sum(case when customerid is null then 1 else 0 end ) as null_customerid,
	sum(case when country is null then 1 else 0 end ) as null_country
	from MNT;
-- there is no null values are present in our data

-- Findout the blank valuse 

select * from MNT
where invoiceno = ' ' or stockcode=' 'or description= ' 'or quantity= ' 'or 
CustomerID= ' 'or country= ' ';
--no blank values are present in our data

--Myntra Fashion Analytics – Pricing, Discount & Inventory Optimization Using SQL
-- Business KPI and insight problums

-- TOTAL REVENUE
SELECT ROUND(SUM(QUANTITY * UNITPRICE),2) 'REVENUE' FROM MNT
where Quantity > 0;

-- monthly trend
-- method 1
SELECT 
		year(INVOICEDATE) as 'year',
		month(invoicedate) as 'month',
		round(SUM(QUANTITY*UNITPRICE),2) AS 'REVENUE'
		from MNT
		group by year(INVOICEDATE),
				month(invoicedate)
		order by year(INVOICEDATE) asc,
				month(invoicedate) asc;
-- meythod 2

SELECT concat(
		(year(INVOICEDATE)),'-',
		(month(invoicedate))) as 'Month' ,
		round(SUM(QUANTITY*UNITPRICE),2) AS 'REVENUE'
		from MNT
		group by year(INVOICEDATE),
				month(invoicedate)
		order by year(INVOICEDATE) asc,
				month(invoicedate) asc;

-- Total Unique Customers
select count(distinct customerid) as 'total_customers' from MNT;

--Repeat Customer Rate
select count(distinct customerid) as 'REPEAT_CUSTOMER' 
from (
		select customerid from MNT
		group by customerid
		having count(invoiceno) >1) as t;

--Customer Lifetime Value (CLV)

SELECT TOP 10 CUSTOMERID,
ROUND(SUM(QUANTITY*UNITPRICE),2) AS 'TOTAL_AMOUNT' 
FROM MNT
GROUP BY CUSTOMERID
ORDER BY ROUND(SUM(QUANTITY*UNITPRICE),2) DESC;

--Top 10 Best-Selling Products

SELECT TOP 10 DESCRIPTION AS 'PRODUCT_NAME', 
SUM(QUANTITY) AS 'TOATL_QUANTITY_SOLD' 
FROM MNT
WHERE QUANTITY > 0
GROUP BY DESCRIPTION
ORDER BY SUM(QUANTITY) DESC;

--Top Revenue Generating Products

SELECT TOP 10 DESCRIPTION AS 'PRODUCT_NAME', 
ROUND(SUM(QUANTITY*UnitPrice),2) AS 'PRODUCT_REVANUE' 
FROM MNT
WHERE QUANTITY > 0
GROUP BY DESCRIPTION
ORDER BY ROUND(SUM(QUANTITY*UnitPrice),2) DESC;

--Cancellation Rate

select count(*) as 'Total_number_of_cancel_order_'  -- find the Total number of cancel order 
from (
select invoiceno from MNT
where InvoiceNo like 'C%') t;

select round(
count(case when invoiceno like 'C%' then 1 end)*100/count(invoiceno)
,2) as 'cancelaion_rate'
from MNT;

-- Average Order Value (AOV)

select
round(sum(quantity*unitprice)/ count(distinct InvoiceNo),2) as 'Avg_order_value'
from MNT;

--Revenue by Country

select Country,round(sum(quantity*unitprice),2)	as 'Total_Revenu'
from MNT
where Quantity > 0
group by Country 
order by round(sum(quantity*unitprice),2) desc;		

--Low Repeat Purchases

select count(*) as'one_time_purchase_customer_count'
from(
select customerid from MNT
group by CustomerID 
having(count(distinct invoiceno))=1
) t;

-- Inventory Overstock / Understock

select stockcode, description, sum(quantity)as 'total_quantity' from MNT
where Quantity > 0
group by stockcode, description
order by total_quantity desc;

-- Check Revenue Dependency on Few Customers

select customerid, round(sum(Quantity*unitprice),2) as 'Revenue' from MNT
where Quantity > 0
group by CustomerID
order by Revenue desc;
