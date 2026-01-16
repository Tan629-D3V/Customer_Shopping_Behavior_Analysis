USE customer_behavior;
-- Revenue Performance & ContributionBusiness Intent


SELECT 
    gender, ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM
    customer
GROUP BY gender;


-- Revenue Contribution by Age Group 
SELECT 
    age_group, ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM
    customer
GROUP BY age_group;
    
    
-- Shipping Type vs Spend
SELECT 
    shipping_type,
    COUNT(*) AS number_of_orders,
    ROUND(AVG(purchase_amount), 2) AS avg_order_value,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM
    customer
GROUP BY shipping_type;

-- Revenue Concentration by Customer Tier 
WITH customer_spend AS (
    SELECT
        customer_id,
        SUM(purchase_amount) AS total_spend
    FROM customer
    GROUP BY customer_id
),
customer_tiers AS (
    SELECT
        customer_id,
        total_spend,
        NTILE(5) OVER (ORDER BY total_spend DESC) AS spend_tier
    FROM customer_spend
)
SELECT
    spend_tier,
    COUNT(*) AS customers,
    ROUND(SUM(total_spend), 2) AS total_revenue
FROM customer_tiers
GROUP BY spend_tier
order by spend_tier;

