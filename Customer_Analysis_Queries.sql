USE customer_behavior;
SHOW TABLES;

SELECT COUNT(*)
FROM customer_shopping_behavior;
SELECT gender, SUM(purchase_amount) AS revenue
FROM customer_shopping_behavior
GROUP BY gender;
DESCRIBE customer_shopping_behavior;
SELECT 
    Gender,
    SUM(`Purchase Amount (USD)`) AS revenue
FROM customer_shopping_behavior
GROUP BY Gender;
SELECT 
    `ï»¿Customer ID`,
    `Purchase Amount (USD)`
FROM customer_shopping_behavior
WHERE `Discount Applied` = 'Yes'
AND `Purchase Amount (USD)` >= (
    SELECT AVG(`Purchase Amount (USD)`)
    FROM customer_shopping_behavior
);
SELECT
    customer_id,
    `Purchase Amount (USD)` AS purchase_amount
FROM customer_shopping_behavior
WHERE `Discount Applied` = 'Yes'
AND `Purchase Amount (USD)` >= (
    SELECT AVG(`Purchase Amount (USD)`)
    FROM customer_shopping_behavior
);
SELECT
    `Item Purchased`,
    ROUND(AVG(`Review Rating`), 2) AS Average_Product_Rating
FROM customer_shopping_behavior
GROUP BY `Item Purchased`
ORDER BY Average_Product_Rating DESC
LIMIT 5;
SELECT
    `Shipping Type`,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS Average_Purchase
FROM customer_shopping_behavior
WHERE `Shipping Type` IN ('Standard', 'Express')
GROUP BY `Shipping Type`;
SELECT
    `Subscription Status`,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS avg_spend,
    ROUND(SUM(`Purchase Amount (USD)`), 2) AS total_revenue
FROM customer_shopping_behavior
GROUP BY `Subscription Status`
ORDER BY total_revenue, avg_spend DESC;

SELECT
    `Item Purchased`,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN `Discount Applied` = 'Yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*), 2
    ) AS discount_rate
FROM customer_shopping_behavior
GROUP BY `Item Purchased`
ORDER BY discount_rate DESC
LIMIT 5;


WITH customer_type AS (
    SELECT
        customer_id,
        `Previous Purchases`,
        CASE
            WHEN `Previous Purchases` = 1 THEN 'New'
            WHEN `Previous Purchases` BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customer_shopping_behavior
)

SELECT
    customer_segment,
    COUNT(*) AS Number_of_Customers
FROM customer_type
GROUP BY customer_segment;


WITH item_counts AS (
    SELECT
        `Category`,
        `Item Purchased`,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY `Category`
            ORDER BY COUNT(customer_id) DESC
        ) AS item_rank
    FROM customer_shopping_behavior
    GROUP BY `Category`, `Item Purchased`
)

SELECT
    item_rank,
    `Category`,
    `Item Purchased`,
    total_orders
FROM item_counts
WHERE item_rank <= 3;


SELECT
    `Subscription Status`,
    COUNT(customer_id) AS repeat_buyers
FROM customer_shopping_behavior
WHERE `Previous Purchases` > 5
GROUP BY `Subscription Status`;


SELECT
    CASE
        WHEN Age < 25 THEN '18-24'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    SUM(`Purchase Amount (USD)`) AS total_revenue
FROM customer_shopping_behavior
GROUP BY age_group
ORDER BY total_revenue DESC;