# Monday Coffee Expansion SQL Project

![Company Logo](https://github.com/najirh/Monday-Coffee-Expansion-Project-P8/blob/main/1.png)

## Objective
The goal of this project is to analyze the sales data of Monday Coffee, a company that has been selling its products online since January 2023, and to recommend the top three major cities in India for opening new coffee shop locations based on consumer demand and sales performance.

## Key Questions
1. **Coffee Consumers Count**  
   How many people in each city are estimated to consume coffee, given that 25% of the population does?
```sql
SELECT 
	city_id,
	city_name,
	CAST(ROUND((population * 0.25)/1000000,2 ) AS decimal(20,2)) as Population_in_Millions,
	city_rank
FROM CITY
ORDER BY Population_in_Millions DESC
```


2. **Total Revenue from Coffee Sales**  
   What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
```sql
SELECT 
    SUM(total) AS total_revenue
FROM sales
WHERE 
    YEAR(sale_date) = 2023
    AND DATEPART(QUARTER, sale_date) = 4;


SELECT
	CT.city_name,
	CT.city_id,
	S.sale_date,
	SUM(S.total) as Total_Revenue
FROM
SALES as S
JOIN customers as C
ON S.customer_id = C.customer_id
JOIN city as CT
ON CT.city_id = C.city_id
WHERE 
	YEAR(sale_date)= 2023
	AND
	DATEPART(QUARTER, sale_date) = 4
GROUP BY CT.city_name,
		 CT.city_id,
		 S.sale_date
ORDER BY Total_Revenue DESC
```

3. **Sales Count for Each Product**  
   How many units of each coffee product have been sold?
```sql
SELECT
	TOP 10
	P.product_name,
	COUNT(s.sale_id) as Total_Each_P_Sold
FROM
SALES as S
LEFT JOIN products as P
ON S.product_id = P.product_id
GROUP BY P.product_name
ORDER BY Total_Each_P_Sold DESC
```

4. **Average Sales Amount per City**  
   What is the average sales amount per customer in each city?
```sql
SELECT 
   CI.city_name,
   SUM(S.total) as total_revenue,
   COUNT(DISTINCT c.customer_id) as Avg_Total_CX,
   --ROUND will make the end number round to 2 Decimel number
   --CAST is to change the datatype from INT to Decimel
   --NULLIF is to make sure when result is 0 so not to divide it by 0
   CAST(ROUND(CAST(SUM(S.total) AS NUMERIC(38,2)) / NULLIF(CAST(COUNT(DISTINCT c.customer_id) AS NUMERIC(38,2)),0),2) as decimal(20,2)) as AVG_Sale_Pr_CX
   --ROUND(CAST(SUM(S.total) AS NUMERIC(38,2)) / NULLIF(CAST(COUNT(DISTINCT c.customer_id) AS NUMERIC(38,2)),0),2) as AVG_Sale_Pr_CX
FROM sales AS s
JOIN customers AS c
    ON s.customer_id = c.customer_id
JOIN city AS ci
    ON ci.city_id = c.city_id
GROUP BY ci.city_name
ORDER BY total_revenue DESC;
```

5. **City Population and Coffee Consumers**  
   Provide a list of cities along with their populations and estimated coffee consumers.
```sql
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers and Sales.
-- return city_name, total current cx, estimated coffee consumers (25%)


WITH City_Population
AS
(
SELECT
	city_name,
	CAST(ROUND(population * 0.25 / 1000000, 2) AS decimal (20,2)) as City_Pop
FROM city
),

Coffee_Consumers
AS
(
	SELECT
		CT.city_name,
		COUNT(DISTINCT C.customer_id) as Total_CX
	FROM 
	city as CT
	JOIN customers as C
	ON CT.city_id = C.city_id
	JOIN SALES as S
	ON S.customer_id = C.customer_id
	GROUP BY CT.city_name
)

SELECT * FROM
City_Population as CP
JOIN Coffee_Consumers as CC
ON CP.city_name = cc.city_name
ORDER BY cp.City_Pop DESC

```

6. **Top Selling Products by City**  
   What are the top 3 selling products in each city based on sales volume?
```sql
SELECT * FROM
(
	SELECT
	CT.city_name,
	P.product_name,
	COUNT(S.sale_id) as Total_Orders,
	DENSE_RANK() OVER(PARTITION BY CT.city_name ORDER BY COUNT(S.sale_id) DESC) as RANK
FROM 
city AS CT
JOIN customers as C
ON CT.city_id = C.city_id
JOIN SALES AS S
ON S.customer_id = C.customer_id
JOIN products as P
ON P.product_id = S.product_id
GROUP BY
	CT.city_name,
	P.product_name
) as T1
	Where RANK <= 3
```

7. **Customer Segmentation by City**  
   How many unique customers are there in each city who have purchased coffee products?
```sql
select
	CT.city_name,
	COUNT(DISTINCT C.customer_id) as Unique_CX
from
SALES AS S
JOIN city AS CT
ON S.customer_id = S.customer_id
LEFT JOIN customers AS C
ON C.city_id = CT.city_id
WHERE
	S.product_id IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
GROUP BY
	CT.city_name

```

8. **Average Sale vs Rent**  
   Find each city and their average sale per customer and avg rent per customer
```sql
/*
STEP 1: FIND EASCH city sale per customer
STEP 2:DINF avg rent per customer
*/

-- Conclusions

GO
WITH CTE_Avg_City_Sale
AS
(
	SELECT 
	CT.city_name,
	SUM(S.total) as Total_Sale,
	COUNT(DISTINCT C.customer_id) as Total_Cx,
	ROUND(CAST(SUM(S.total) AS decimal (38,2)) / CAST(COUNT(DISTINCT C.customer_id) AS decimal (38,2)) ,2)
	 as AVG_Sale_Pr_CX
	

FROM city as Ct
JOIN customers as C
ON C.city_id = CT.city_id
JOIN SALES as S
ON S.customer_id = C.customer_id
GROUP BY
	CT.city_name
--ORDER BY Total_Sale Desc -- Final Sorting can be done out of the CTE at the END aelect Statment
--OFFSET 0 ROWS -- IF still want to sort within the CTE so OFFSET 0 ROW can be used to can USE TOP whatever needed at the top.
	
),

CTE_City_Table
AS
(
	SELECT
		city_name,
		estimated_rent
	FROM city
)

SELECT 
	CTE_ACS.city_name,
	CTE_ACS.Total_Sale,
	CTE_ACS.Total_Cx,
	CTE_ACS.AVG_Sale_Pr_CX,
	CTE_CT.estimated_rent,
	ROUND(CAST(CTE_CT.estimated_rent AS decimal (38,2)) / CAST(CTE_ACS.Total_Cx AS decimal (38,2)) ,2) as avg_rent_per_cx
		
	--CAST ( (38,2))/ CAST (CTE_ACS.AVG_Sale_Pr_CX (38,2))
FROM CTE_Avg_City_Sale AS CTE_ACS
JOIN CTE_City_Table as CTE_CT
ON CTE_ACS.city_name = CTE_CT.city_name
ORDER BY CTE_ACS.AVG_Sale_Pr_CX DESC
```

9. **Monthly Sales Growth**  
   Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).
```sql
/*
	Step1: Exrtact Month and year > CTEs
	Step2: Get the sale through out Month and year base on the city name > CTEs
	Step3: Last Get all the the data from 1st and 2nd CTEs and Calculate the percentage growth
*/

--Step1: Exrtact Month and year > CTEs
WITH CTE_MandY
AS
(
	select	
	CT.city_name,
	DATEPART(MONTH, S.sale_date) AS M_sale,
	DATEPART(YEAR, S.sale_date) AS Y_Sale,
	SUM(S.total) as Total_Sale
from 
SALES AS S
JOIN customers AS CX
ON S.customer_id = CX.customer_id
JOIN city AS CT
ON CT.city_id = CX.city_id
GROUP BY 
	CT.city_name,
	MONTH(S.sale_date),
	YEAR(S.sale_date)
/*ORDER BY
	CT.city_name,
	MONTH(S.sale_date),
	YEAR(S.sale_date)*/
),

CTE_Sale_0ver_Time
AS
(
	SELECT 
		city_name,
		M_sale,
		Y_Sale,
		total_sale as T_sale,
		LAG(Total_Sale, 1) OVER(PARTITION BY city_name ORDER BY Y_Sale, M_sale) as Monthly_Growth
	FROM CTE_MandY
)

SELECT
	city_name,
	M_sale,
	Y_Sale,
	T_sale,
	Monthly_Growth,
		ROUND(Cast(T_sale as Decimal(20,2))/Cast(Monthly_Growth as Decimal(20,2)) *100 
		,2) as growth_ratio
FROM CTE_Sale_0ver_Time
WHERE Monthly_Growth IS NOT NULL	
ORDER BY 
	city_name,
	Y_Sale,
	M_sale
```

10. **Market Potential Analysis**  
    Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated  coffee consumer
```sql
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, 
-- AVG estimated 25% coffee consumer
-- AVG Rent Pr Cus

WITH CTE_Avg_CxSale
AS
(
		SELECT
	CT.City_name,
	SUM(S.total) as total_sale,
	COUNT(DISTINCT C.customer_id) as Total_CX,
	ROUND(CAST(SUM(S.total) as Decimal(38,2)) /  CAST(COUNT(DISTINCT C.customer_id) as Decimal(38,2)),2) as Avg_Sale_pr_CX
FROM customers as C
JOIN SALES AS S
ON C.customer_id = S.customer_id
JOIN city as CT
ON C.city_id = CT.city_id
GROUP BY CT.City_name
),


CTE_Avg_Coffee_Cunsumer
AS
(
	SELECT
	City_name,
	estimated_rent,
		ROUND(CAST(population *0.25 / 1000000 as Decimal(20,2)) ,2) as Est_Coffee_Cunsumer
	FROM city
)


SELECT
	TOP 3
	CTE_AvgS.city_name,
	CTE_AvgS.total_sale,
	CTE_CoffeeC.estimated_rent as Total_Rent,
	CTE_CoffeeC.Est_Coffee_Cunsumer,
	CTE_AvgS.Total_CX,
	CTE_AvgS.Avg_Sale_pr_CX,
	ROUND(
		CAST(CTE_CoffeeC.estimated_rent as Decimal(38,2)) /  
		CAST(CTE_AvgS.Total_CX as Decimal(38,2)),2)
	as Avg_Rent_pr_CX
FROM CTE_Avg_CxSale AS CTE_AvgS
JOIN CTE_Avg_Coffee_Cunsumer AS CTE_CoffeeC
ON CTE_AvgS.city_name = CTE_CoffeeC.city_name
ORDER BY
    CTE_AvgS.total_sale DESC
```

## Recommendations
After analyzing the data, the recommended top three cities for new store openings are:

**City 1: Pune**  
1. Average rent per customer is very low.  
2. Highest total revenue.  
3. Average sales per customer is also high.

**City 2: Delhi**  
1. Highest estimated coffee consumers at 7.7 million.  
2. Highest total number of customers, which is 68.  
3. Average rent per customer is 330 (still under 500).

**City 3: Jaipur**  
1. Highest number of customers, which is 69.  
2. Average rent per customer is very low at 156.  
3. Average sales per customer is better at 11.6k.

---

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into SALE, Growth Of Business, City vs Product trends.
- **Summary Reports**: Aggregated data on high-Cities performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing insigts of Coffee Business. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/najirh/Library-System-Management---P2.git
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Abbas Ali

This project showcases SQL skills essential for database management and analysis. 
- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/najirr)

Thank you for your interest in this project!
