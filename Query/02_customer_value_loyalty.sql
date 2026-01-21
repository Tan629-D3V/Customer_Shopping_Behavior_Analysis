USE customer_behavior;




-- Q5: Subscribers vs Non-Subscribers Spend Comparison
SELECT subscription_status,
    COUNT(*) AS Total_orders,
    Round(AVG(purchase_amount), 2) AS Avg_spend,
    Round(SUM(purchase_amount), 2) AS Total_spend
FROM customer
GROUP BY subscription_status;




-- Q9: Repeat Buyers and Subscription Likelihood
SELECT subscription_status,
    COUNT(*) AS repeat_customers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;




-- Q7: Customer Lifecycle Segmentation
SELECT CASE
        WHEN previous_purchases = 1 THEN 'New'
        WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
        ELSE 'Loyal'
    END AS customer_segment,
    COUNT(*) AS customers
FROM customer
GROUP BY customer_segment;




-- Q12: Revenue per Customer Segment
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




-- Q13: Purchase Depth vs Spend
SELECT previous_purchases,
    COUNT(*) AS customers,
    ROUND(AVG(purchase_amount), 2) AS avg_order_value
FROM customer
GROUP BY previous_purchases
ORDER BY previous_purchases;