

-- Create and select database

CREATE DATABASE Zepto_Sql_Project;
USE Zepto_Sql_Project;

-- Add primary key
ALTER TABLE zepto
ADD COLUMN sku_id INT AUTO_INCREMENT PRIMARY KEY FIRST;


-- ----------------------------
-- 🧭 Data Exploration
-- ----------------------------

SELECT 
    COUNT(*) AS total_rows
FROM
    zepto;

-- Sample data

SELECT * FROM zepto LIMIT 10;


-- Different product categories

SELECT DISTINCT
    category
FROM
    zepto;


-- Missing Values Check

SELECT 
    *
FROM
    zepto
WHERE
    category IS NULL OR name IS NULL
        OR mrp IS NULL
        OR quantity IS NULL
        OR availableQuantity IS NULL;




-- STOCK AVAILABILITY OVERVIEW

SELECT 
    outofstock, COUNT(sku_id) AS product_count
FROM
    zepto
GROUP BY outofstock;



-- DUPLICATE PRODUCT NAMES

SELECT 
    name, COUNT(sku_id) AS num_of_times
FROM
    zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY num_of_times DESC;


-- ----------------------------
-- DATA CLEANING
-- ----------------------------

SELECT 
    *
FROM
    zepto
WHERE
    mrp = 0 OR discountedsellingprice = 0;


-- Allow data modification
SET SQL_SAFE_UPDATES = 0;

-- REMOVE INVALID RECORDS

DELETE FROM zepto 
WHERE mrp = 0;

-- CONVERT PAISA INTO RUPEES 

UPDATE zepto 
SET 
    mrp = mrp / 100.0,
    discountedsellingprice = discountedsellingprice / 100.0;



-- ----------------------------
-- 📊 Descriptive Statistics
-- ----------------------------

SELECT 
    ROUND(AVG(mrp), 2) AS avg_product_price
FROM
    zepto;
    
    
-- MOST EXPENSIVE PRODUCT 

SELECT name, category, mrp FROM zepto 
ORDER BY mrp DESC LIMIT 1;

-- CHEAPEST PRODUCT 

SELECT name, category, mrp FROM zepto 
ORDER BY mrp ASC LIMIT 1;



-- ------------------------------------
-- Business Analysis
-- ------------------------------------


--  Top 10 PRODUCT WITH HIGHEST DISCOUNT

SELECT 
    name, 
    mrp, 
    discountpercent
FROM zepto
ORDER BY discountpercent DESC
LIMIT 10;


-- HIGH MRP PRODUCT CURRENTLY OUT OF STOCK

SELECT 
    name, 
    mrp
FROM zepto
WHERE outofstock = 'TRUE' 
  AND mrp > 300
ORDER BY mrp DESC;


-- Estimated Revenue by Category

SELECT 
    category, 
    SUM(discountedsellingprice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC;


-- Q4: Premium Products with Low Discounts
SELECT 
    category, 
    name, 
    mrp, 
    discountpercent
FROM zepto
WHERE mrp > 500 
  AND discountpercent < 10
ORDER BY mrp DESC, discountpercent DESC;


--  Top 5 categories offering highest average discount %

SELECT 
    category, 
    AVG(discountpercent) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;


-- Best Value Products by Price per Gram

SELECT 
    name,
    weightingms,
    discountedsellingprice,
    ROUND(discountedsellingprice / weightingms, 2) AS price_per_gram
FROM zepto
WHERE weightingms > 100
ORDER BY price_per_gram ASC;  -- ASC = best value (cheapest per gram)


-- Product Weight Classification

SELECT 
    name,
    weightingms,
    CASE
        WHEN weightingms < 500 THEN 'LOW'
        WHEN weightingms BETWEEN 500 AND 1000 THEN 'MEDIUM'
        ELSE 'BULK'
    END AS weight_category
FROM zepto;


--  Total inventory weight per category

SELECT 
    category,
    SUM(availableQuantity * weightingms) AS total_weight
FROM
    zepto
GROUP BY category
ORDER BY total_weight DESC;




-- Revenue Contribution Percentage by Category

WITH category_revenue AS 
( SELECT category, SUM(discountedsellingprice * availableQuantity) AS revenue FROM zepto GROUP BY category )
 
 SELECT category, revenue, 
 
 ROUND( revenue * 100.0 / SUM(revenue) OVER (), 2 ) AS revenue_percentage 
 FROM category_revenue 
 ORDER BY revenue DESC;



-- Top 3 Most Expensive Products in Each Category

WITH ranked_products AS (
 SELECT category, name, mrp, DENSE_RANK() 
   OVER( PARTITION BY category ORDER BY mrp DESC ) AS rank_num 
           FROM zepto 
) SELECT * FROM ranked_products WHERE rank_num <= 3;


-- Most Discounted Product in Every Category

WITH discount_rank AS ( 
SELECT category, name, discountpercent, 
     ROW_NUMBER() 
      OVER( PARTITION BY category ORDER BY discountpercent DESC ) 
                          AS rn FROM zepto )
 SELECT * FROM discount_rank WHERE rn = 1;
 
 
 -- Product Price Segmentation
 
 SELECT 
 CASE WHEN mrp < 100 THEN 'Budget'
      WHEN mrp BETWEEN 100 AND 500 THEN 'Mid Range' 
      ELSE 'Premium' END 
                     AS price_segment, 
 COUNT(*) AS total_products FROM zepto 
                        GROUP BY price_segment;
                        
                        
-- ________________________________________________________________________________