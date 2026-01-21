USE customer_behavior;


-- Subscribers vs Non-Subscribers Spend Comparison
SELECT subscription_status,
    COUNT(*) AS total_orders,
    ROUND(AVG(purchase_amount), 2) AS avg_order_value,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer
GROUP BY subscription_status;




-- Repeat Buyers and Subscription Likelihood
-- (Repeat buyers defined as customers with more than 3 previous purchases)
SELECT subscription_status,
    COUNT(*) AS repeat_customers
FROM customer
WHERE previous_purchases > 3
GROUP BY subscription_status;




-- Customer Lifecycle Segmentation (New / Returning / Loyal)
SELECT CASE
        WHEN previous_purchases = 1 THEN 'New'
        WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
        ELSE 'Loyal'
    END AS customer_segment,
    COUNT(*) AS customers
FROM customer
GROUP BY customer_segment;




-- Revenue per Customer Segment
SELECT CASE
        WHEN previous_purchases = 1 THEN 'New'
        WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
        ELSE 'Loyal'
    END AS customer_segment,
    COUNT(*) AS customers,
    ROUND(SUM(purchase_amount), 2) AS total_revenue,
    ROUND(SUM(purchase_amount) / COUNT(*), 2) AS revenue_per_customer
FROM customer
GROUP BY customer_segment;




-- Purchase Depth vs Spend
SELECT previous_purchases,
    COUNT(*) AS customers,
    ROUND(AVG(purchase_amount), 2) AS avg_order_value
FROM customer
GROUP BY previous_purchases
ORDER BY previous_purchases;