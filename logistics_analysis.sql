-- CREATE DATABASE ecommerce_logistics;
-- USE ecommerce_logistics;

-- DROP TABLE IF EXISTS orders;

-- SET GLOBAL local_infile = 1;

-- SHOW VARIABLES LIKE 'local_infile';

-- CREATE TABLE orders (
--     order_id VARCHAR(50),
--     order_date DATE,
--     customer_id VARCHAR(50),
--     customer_segment VARCHAR(50),
--     customer_city VARCHAR(100),
--     customer_country VARCHAR(100),
--     warehouse_id VARCHAR(50),
--     warehouse_city VARCHAR(100),
--     product_category VARCHAR(100),
--     product_weight_kg DECIMAL(10,2),
--     order_value_usd DECIMAL(12,2),
--     shipping_method VARCHAR(50),
--     carrier VARCHAR(50),
--     distance_km DECIMAL(10,2),
--     promised_delivery_days INT,
--     actual_delivery_days INT,
--     delivery_status VARCHAR(50),
--     late_delivery INT,
--     delivery_delay_days INT,
--     shipping_cost_usd DECIMAL(12,2),
--     package_size VARCHAR(50),
--     payment_method VARCHAR(50),
--     order_priority VARCHAR(50),
--     weather_condition VARCHAR(100),
--     customer_rating DECIMAL(3,2),
--     return_requested INT,
--     return_reason VARCHAR(255),
--     delivery_attempts INT,
--     warehouse_processing_hours DECIMAL(10,2),
--     tracking_status VARCHAR(100)
-- );

-- SHOW TABLES;

-- SHOW VARIABLES LIKE 'secure_file_priv';

-- USE ecommerce_logistics;

-- TRUNCATE TABLE orders;

-- USE ecommerce_logistics;

-- ALTER TABLE orders
-- MODIFY late_delivery VARCHAR(10);

-- ALTER TABLE orders
-- MODIFY return_requested VARCHAR(10);

-- TRUNCATE TABLE orders;

-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/E-commerce_Delivery_Shipping_Data_2026.csv'
-- INTO TABLE orders
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- TOTAL ORDERS
SELECT COUNT(*) AS total_orders
FROM orders;

-- DELIVERY STATUS
SELECT
    delivery_status,
    COUNT(*) AS orders
FROM orders
GROUP BY delivery_status;

-- LATE VS NON LATE ORDERS
SELECT
    late_delivery,
    COUNT(*) AS orders
FROM orders
GROUP BY late_delivery;

-- SHIPPING METHODS
SELECT
    shipping_method,
    COUNT(*) AS orders
FROM orders
GROUP BY shipping_method
ORDER BY orders DESC;

-- CARRIERS
SELECT
    carrier,
    COUNT(*) AS orders
FROM orders
GROUP BY carrier
ORDER BY orders DESC;


-- LATE DELIVERY RATE
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN late_delivery = 'Yes' THEN 1 ELSE 0 END) AS late_orders,
    ROUND(
        SUM(CASE WHEN late_delivery = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS late_delivery_rate
FROM orders;

-- COUNT LATE ORDERS
SELECT COUNT(*) AS late_orders
FROM orders
WHERE late_delivery = 'Yes';

-- Does delivery performance differ by shipping method?
SELECT
    shipping_method,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN late_delivery = 'Yes' THEN 1 ELSE 0 END) AS late_orders,
    ROUND(
        SUM(CASE WHEN late_delivery = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS late_delivery_rate
FROM orders
GROUP BY shipping_method
ORDER BY late_delivery_rate DESC;

-- Does delivery performance vary by carrier?
SELECT
    carrier,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN late_delivery = 'Yes' THEN 1 ELSE 0 END) AS late_orders,
    ROUND(
        SUM(CASE WHEN late_delivery = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS late_delivery_rate
FROM orders
GROUP BY carrier
ORDER BY late_delivery_rate DESC;


-- Are some warehouses associated with longer delays?
SELECT
    warehouse_id,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_delay_days), 2) AS avg_delay_days
FROM orders
GROUP BY warehouse_id
ORDER BY avg_delay_days DESC;

SELECT
    warehouse_id,
    ROUND(AVG(warehouse_processing_hours), 2) AS avg_processing_hours,
    ROUND(AVG(delivery_delay_days), 2) AS avg_delay_days
FROM orders
GROUP BY warehouse_id
ORDER BY avg_delay_days DESC;


-- Is there an observed relationship between delivery delays and customer ratings?
SELECT
    delivery_delay_days,
    COUNT(*) AS orders,
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating
FROM orders
GROUP BY delivery_delay_days
ORDER BY delivery_delay_days;


-- Are longer-distance orders associated with higher delivery delays?
SELECT
    CASE
        WHEN distance_km < 100 THEN '0-100 km'
        WHEN distance_km < 500 THEN '100-500 km'
        WHEN distance_km < 1000 THEN '500-1000 km'
        ELSE '1000+ km'
    END AS distance_group,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN late_delivery = 'Yes' THEN 1 ELSE 0 END) AS late_orders,
    ROUND(
        SUM(CASE WHEN late_delivery = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS late_delivery_rate,
    ROUND(AVG(delivery_delay_days), 2) AS avg_delay_days
FROM orders
GROUP BY distance_group
ORDER BY late_delivery_rate DESC;


-- Does delivery performance vary across weather conditions?
SELECT
    weather_condition,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN late_delivery = 'Yes' THEN 1 ELSE 0 END) AS late_orders,
    ROUND(
        SUM(CASE WHEN late_delivery = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS late_delivery_rate,
    ROUND(AVG(delivery_delay_days), 2) AS avg_delay_days
FROM orders
GROUP BY weather_condition
ORDER BY late_delivery_rate DESC;


-- Are orders requiring more delivery attempts associated with higher delays?
SELECT
    delivery_attempts,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN late_delivery = 'Yes' THEN 1 ELSE 0 END) AS late_orders,
    ROUND(
        SUM(CASE WHEN late_delivery = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS late_delivery_rate,
    ROUND(AVG(delivery_delay_days), 2) AS avg_delay_days
FROM orders
GROUP BY delivery_attempts
ORDER BY delivery_attempts;


-- Are longer warehouse processing times associated with delivery delays?
SELECT
    CASE
        WHEN warehouse_processing_hours < 12 THEN 'Under 12 hrs'
        WHEN warehouse_processing_hours < 24 THEN '12-24 hrs'
        WHEN warehouse_processing_hours < 48 THEN '24-48 hrs'
        ELSE '48+ hrs'
    END AS processing_group,
    COUNT(*) AS total_orders,
    ROUND(AVG(warehouse_processing_hours), 2) AS avg_processing_hours,
    ROUND(AVG(delivery_delay_days), 2) AS avg_delay_days,
    ROUND(
        SUM(CASE WHEN late_delivery = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS late_delivery_rate
FROM orders
GROUP BY processing_group
ORDER BY late_delivery_rate DESC;


-- Does delivery performance differ by order priority?
SELECT
    order_priority,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN late_delivery = 'Yes' THEN 1 ELSE 0 END) AS late_orders,
    ROUND(
        SUM(CASE WHEN late_delivery = 'Yes' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS late_delivery_rate
FROM orders
GROUP BY order_priority
ORDER BY late_delivery_rate DESC;


-- How much longer does delivery actually take compared with what was promised?
SELECT
    ROUND(AVG(promised_delivery_days), 2) AS avg_promised_days,
    ROUND(AVG(actual_delivery_days), 2) AS avg_actual_days,
    ROUND(
        AVG(actual_delivery_days - promised_delivery_days),
        2
    ) AS avg_delivery_variance
FROM orders;

