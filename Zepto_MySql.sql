-- Create and select database
CREATE DATABASE Zepto_Sql_Project;
USE Zepto_Sql_Project;

-- Add primary key
ALTER TABLE zepto
ADD COLUMN sku_id INT AUTO_INCREMENT PRIMARY KEY FIRST;


-- ----------------------------
-- 🧭 Data Exploration
-- ----------------------------

-- Count of rows
SELECT COUNT(*) AS total_rows FROM zepto;

-- Sample data
SELECT * FROM zepto LIMIT 10;

-- Null value check
SELECT *
FROM zepto
WHERE category IS NULL 
   OR name IS NULL
   OR mrp IS NULL
   OR quantity IS NULL;

-- Different product categories
SELECT DISTINCT category
FROM zepto;


-- Product in stock vs out of stock
SELECT outofstock, COUNT(sku_id) AS product_count
FROM zepto
GROUP BY outofstock;

-- Product names that appear multiple times
SELECT 
    name, 
    COUNT(sku_id) AS num_of_times
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY num_of_times DESC;


-- ----------------------------
-- 🧹 Data Cleaning
-- ----------------------------

-- Products with zero price
SELECT * 
FROM zepto 
WHERE mrp = 0 OR discountedsellingprice = 0;

-- Allow data modification
SET SQL_SAFE_UPDATES = 0;

-- Remove invalid products
DELETE FROM zepto 
WHERE mrp = 0;

-- Convert paise to rupees
UPDATE zepto 
SET 
    mrp = mrp / 100.0,
    discountedsellingprice = discountedsellingprice / 100.0;

SELECT * FROM zepto LIMIT 10;


-- ----------------------------
-- 📊 Analysis Queries
-- ----------------------------

-- Q1: Top 10 best-value products based on discount percentage
SELECT 
    name, 
    mrp, 
    discountpercent
FROM zepto
ORDER BY discountpercent DESC
LIMIT 10;


-- Q2: Products with high MRP but out of stock
SELECT 
    name, 
    mrp
FROM zepto
WHERE outofstock = 'TRUE' 
  AND mrp > 300
ORDER BY mrp DESC;


-- Q3: Estimated Revenue by Category
SELECT 
    category, 
    SUM(discountedsellingprice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC;


-- Q4: Products with MRP > 500 and discount < 10%
SELECT 
    category, 
    name, 
    mrp, 
    discountpercent
FROM zepto
WHERE mrp > 500 
  AND discountpercent < 10
ORDER BY mrp DESC, discountpercent DESC;


-- Q5: Top 5 categories offering highest average discount %
SELECT 
    category, 
    AVG(discountpercent) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;


-- Q6: Price per gram for products above 100g (best value)
SELECT 
    name,
    weightingms,
    discountedsellingprice,
    ROUND(discountedsellingprice / weightingms, 2) AS price_per_gram
FROM zepto
WHERE weightingms > 100
ORDER BY price_per_gram ASC;  -- ASC = best value (cheapest per gram)


-- Q7: Categorize products by weight range
SELECT 
    name,
    weightingms,
    CASE
        WHEN weightingms < 500 THEN 'LOW'
        WHEN weightingms BETWEEN 500 AND 1000 THEN 'MEDIUM'
        ELSE 'BULK'
    END AS weight_category
FROM zepto;


-- Q8: Total inventory weight per category
SELECT 
    category,
    SUM(availableQuantity * weightingms) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight DESC;
