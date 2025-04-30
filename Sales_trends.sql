CREATE DATABASE sales_db;
USE sales_db;
CREATE TABLE online_sales (
    transaction_id INT PRIMARY KEY,
    order_date DATE,
    product_category VARCHAR(100),
    product_name VARCHAR(255),
    units_sold INT,
    unit_price DECIMAL(10,2),
    total_revenue DECIMAL(12,2),
    region VARCHAR(100),
    payment_method VARCHAR(50)
);
SELECT * FROM online_sales LIMIT 10;
-- 1) Create a CTE to extract year and month
WITH sales_by_month AS (
    SELECT
        EXTRACT(YEAR FROM order_date) AS order_year,
        EXTRACT(MONTH FROM order_date) AS order_month,
        COUNT(DISTINCT transaction_id) AS order_volume,
        SUM(total_revenue) AS total_revenue
    FROM online_sales
    GROUP BY 
        EXTRACT(YEAR FROM order_date), 
        EXTRACT(MONTH FROM order_date)
)
SELECT *
FROM sales_by_month
ORDER BY order_year, order_month;

-- 2)running total of revenue over time

WITH sales_by_month AS (
    SELECT
        EXTRACT(YEAR FROM order_date) AS order_year,
        EXTRACT(MONTH FROM order_date) AS order_month,
        COUNT(DISTINCT transaction_id) AS order_volume,
        SUM(total_revenue) AS total_revenue
    FROM online_sales
    GROUP BY order_year, order_month
)

SELECT 
    *,
    SUM(total_revenue) OVER (ORDER BY order_year, order_month) AS running_revenue
FROM sales_by_month
ORDER BY order_year, order_month;

-- 3) Compare Each Month's Revenue to Previous Month (Growth Trend)

WITH sales_by_month AS (
    SELECT
        EXTRACT(YEAR FROM order_date) AS order_year,
        EXTRACT(MONTH FROM order_date) AS order_month,
        COUNT(DISTINCT transaction_id) AS order_volume,
        SUM(total_revenue) AS total_revenue
    FROM online_sales
    GROUP BY order_year, order_month
)

SELECT 
    *,
    LAG(total_revenue) OVER (ORDER BY order_year, order_month) AS previous_month_revenue,
    total_revenue - LAG(total_revenue) OVER (ORDER BY order_year, order_month) AS revenue_change,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY order_year, order_month)) 
        / LAG(total_revenue) OVER (ORDER BY order_year, order_month) * 100, 2
    ) AS revenue_growth_percent
FROM sales_by_month
ORDER BY order_year, order_month;
