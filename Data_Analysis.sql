--SELECT count(*) FROM dbo.orders

--Find top 10 highest reveue generating products 

WITH sale_total AS
(
SELECT order_id,product_id, quantity * selling_price as order_total
FROM orders
--WHERE product_id='FUR-BO-10001798'

)
SELECT top 10 orders.product_id,SUM(order_total) as total
FROM orders
LEFT JOIN sale_total
ON orders.order_id = sale_total.order_id
GROUP BY orders.product_id
ORDER BY SUM(order_total) DESC

--Top 5 highest selling products in each region

WITH sale_total AS
(
SELECT order_id,product_id, quantity * selling_price as order_total
FROM orders

)
,region_wise_sell AS
(
SELECT orders.region, orders.product_id,SUM(order_total) as total
,ROW_NUMBER() OVER(PARTITION BY region ORDER BY SUM(order_total) DESC) AS rn
FROM orders
LEFT JOIN sale_total
ON orders.order_id = sale_total.order_id
GROUP BY orders.product_id, orders.region
--ORDER BY region,SUM(order_total) DESC
)
SELECT region, product_id, total
FROM region_wise_sell
WHERE rn<=5

--Month over month comparison for 2022 sales and 2023 sale e.g. Jan 2022 vs Jan 2023
--		2022		2023
--Jan
--Feb

WITH year_month_sale AS
(
SELECT YEAR(order_date) as order_year, month(order_date) AS order_month, sum(selling_price) as sales_price
FROM orders
GROUP BY YEAR(order_date) , month(order_date) 
--ORDER BY  month(order_date) ,YEAR(order_date)
)
SELECT order_month,
SUM(CASE WHEN order_year=2022 THEN sales_price ELSE 0 END) AS sales_2022,
SUM(CASE WHEN order_year=2023 THEN sales_price ELSE 0 END )AS sales_2023
FROM year_month_sale
GROUP BY order_month
ORDER BY order_month

--For each category which month had highest sales 

WITH category_month_wise_sales AS
(
SELECT category,month(order_date) as order_month, year(order_date) as order_year,sum(selling_price) as sales,
row_number() OVER (PARTITION BY category ORDER BY sum(selling_price) DESC) as rn
FROM orders
GROUP BY category,month(order_date),year(order_date) 
--order by 1,2,3,4 desc
)
SELECT *
FROM category_month_wise_sales
WHERE rn=1

----Which sub category had highest growth by profit in 2023 compare to 2022
WITH sub_category_wise_sale AS
(
SELECT sub_category,YEAR(order_date) as order_year, sum(selling_price) as sales_price
FROM orders
GROUP by sub_category,YEAR(order_date)
--ORDER BY 1,3 DESC
),
year_wise_sale AS
(
SELECT sub_category,SUM(CASE WHEN order_year=2022 THEN sales_price ELSE 0 END) AS sales_2022,
SUM(CASE WHEN order_year=2023 THEN sales_price ELSE 0 END) AS sales_2023

FROM sub_category_wise_sale --ORDER BY 1
GROUP BY sub_category 
)
SELECT top 1 sub_category, sales_2022 - sales_2023 as profit
FROM year_wise_sale
ORDER BY profit DESC