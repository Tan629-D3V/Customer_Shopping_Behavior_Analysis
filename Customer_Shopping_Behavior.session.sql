-- SHOW TABLES
-- FROM customer;


SELECT * FROM customer_behavior.customer;


-- Revenue Performance & ContributionBusiness Intent
SELECT 
    gender, ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM
    customer_behavior.customer
GROUP BY gender;




-- Revenue Contribution by Age Group 
SELECT 
    age_group, ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM
    customer_behavior.customer
GROUP BY age_group;
    
    


-- Shipping Type vs Spend
SELECT 
    shipping_type,
    COUNT(*) AS number_of_orders,
    ROUND(AVG(purchase_amount), 2) AS avg_order_value,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM
    customer_behavior.customer
GROUP BY shipping_type;




-- Revenue Concentration by Customer Tier 
WITH customer_spend AS (
    SELECT
        customer_id,
        SUM(purchase_amount) AS total_spend
    FROM customer_behavior.customer
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




-- Monthly Revenue Trends
SELECT 
    DATE_FORMAT(purchase_date, '%Y-%m') AS month,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM
    customer_behavior.customer
GROUP BY month
ORDER BY month; 





-- Subscribers vs Non-Subscribers Spend Comparison
SELECT subscription_status,
    COUNT(*) AS total_orders,
    ROUND(AVG(purchase_amount), 2) AS avg_order_value,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer_behavior.customer
GROUP BY subscription_status;




-- Repeat Buyers and Subscription Likelihood
-- (Repeat buyers defined as customers with more than 3 previous purchases)
SELECT subscription_status,
    COUNT(*) AS repeat_customers
FROM customer_behavior.customer
WHERE previous_purchases > 3
GROUP BY subscription_status;




-- Customer Lifecycle Segmentation (New / Returning / Loyal)
SELECT CASE
        WHEN previous_purchases = 1 THEN 'New'
        WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
        ELSE 'Loyal'
    END AS customer_segment,
    COUNT(*) AS customers
FROM customer_behavior.customer
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
FROM customer_behavior.customer
GROUP BY customer_segment;




-- Purchase Depth vs Spend
SELECT previous_purchases,
    COUNT(*) AS customers,
    ROUND(AVG(purchase_amount), 2) AS avg_order_value
FROM customer_behavior.customer
GROUP BY previous_purchases
ORDER BY previous_purchases;



-- =====================================================
-- 3️⃣ PROMOTION & DISCOUNT EFFECTIVENESS
-- =====================================================

-- High-Spending Customers Who Used Discounts
SELECT 
    customer_id, 
    gender, 
    age_group,
    ROUND(SUM(purchase_amount), 2) AS total_spend
FROM customer_behavior.customer
WHERE discount_applied = 'Yes' -- Adjust to TRUE or 1 depending on your CSV format
GROUP BY customer_id, gender, age_group
HAVING total_spend > 100 -- Adjust this threshold based on your dataset's average spend
ORDER BY total_spend DESC;

-- Products with Highest Discount Dependency
SELECT 
    item_purchased,
    COUNT(*) AS total_units_sold,
    SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) AS units_sold_on_discount,
    ROUND((SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS discount_dependency_pct
FROM customer_behavior.customer
GROUP BY item_purchased
ORDER BY discount_dependency_pct DESC, total_units_sold DESC;

-- Customer Value vs Discount Usage
SELECT 
    discount_applied,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(AVG(purchase_amount), 2) AS avg_order_value,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer_behavior.customer
GROUP BY discount_applied;

-- Discount Dependency by Customer Segment 
WITH segment_data AS (
    SELECT CASE
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment,
        discount_applied
    FROM customer_behavior.customer
)
SELECT 
    customer_segment,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) AS discounted_transactions,
    ROUND((SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS segment_discount_dependency_pct
FROM segment_data
GROUP BY customer_segment
ORDER BY segment_discount_dependency_pct DESC;


-- =====================================================
-- 4️⃣ PRODUCT PERFORMANCE & CUSTOMER PREFERENCE
-- =====================================================

-- Top Products by Review Rating
SELECT 
    item_purchased,
    COUNT(*) AS purchase_volume,
    ROUND(AVG(review_rating), 2) AS avg_rating
FROM customer_behavior.customer
GROUP BY item_purchased
ORDER BY avg_rating DESC, purchase_volume DESC
LIMIT 10;

-- Top 3 Most Purchased Products per Category
WITH RankedProducts AS (
    SELECT 
        category,
        item_purchased,
        COUNT(*) AS total_purchases,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(*) DESC) as rank_in_category
    FROM customer_behavior.customer
    GROUP BY category, item_purchased
)
SELECT 
    category, 
    item_purchased, 
    total_purchases
FROM RankedProducts
WHERE rank_in_category <= 3;

-- Ratings vs Demand Comparison
SELECT 
    item_purchased,
    ROUND(AVG(review_rating), 2) AS avg_rating,
    COUNT(*) AS demand_volume,
    ROUND(SUM(purchase_amount), 2) AS total_revenue_generated
FROM customer_behavior.customer
GROUP BY item_purchased
ORDER BY demand_volume DESC;

-- Pricing Power by Product Rating
SELECT 
    CASE
        WHEN review_rating >= 4.5 THEN '1. Excellent (4.5-5.0)'
        WHEN review_rating >= 3.5 THEN '2. Good (3.5-4.4)'
        WHEN review_rating >= 2.5 THEN '3. Average (2.5-3.4)'
        ELSE '4. Poor (< 2.5)'
    END AS rating_tier,
    ROUND(AVG(purchase_amount), 2) AS avg_price_paid,
    COUNT(*) AS total_sales_volume
FROM customer_behavior.customer
GROUP BY rating_tier
ORDER BY rating_tier ASC;


-- =====================================================
-- 5️⃣ STRATEGIC CUSTOMER PRIORITIZATION (SUMMARY LAYER)
-- =====================================================

-- High-Impact Customer Segments for Retention
SELECT 
    age_group, 
    gender,
    COUNT(*) AS segment_size,
    ROUND(SUM(purchase_amount), 2) AS total_segment_value,
    ROUND(AVG(previous_purchases), 2) AS avg_loyalty_depth
FROM customer_behavior.customer
WHERE subscription_status = 'Yes' AND previous_purchases >= 5
GROUP BY age_group, gender
ORDER BY total_segment_value DESC
LIMIT 5;

-- Subscription Strategy: Growth vs Stability
SELECT 
    subscription_status,
    COUNT(*) AS total_user_base,
    ROUND(AVG(previous_purchases), 2) AS avg_retention_length,
    ROUND(SUM(purchase_amount), 2) AS gross_revenue,
    ROUND(SUM(purchase_amount) / COUNT(*), 2) AS lifetime_value_proxy
FROM customer_behavior.customer
GROUP BY subscription_status;

-- Discount Strategy: Value Creation vs Dependency
SELECT 
    discount_applied,
    ROUND(SUM(purchase_amount), 2) AS gross_revenue_contribution,
    ROUND(AVG(purchase_amount), 2) AS avg_ticket_size,
    ROUND(AVG(previous_purchases), 2) AS loyalty_indicator
FROM customer_behavior.customer
GROUP BY discount_applied;

-- Priority Products for Marketing and Investment
SELECT 
    item_purchased, 
    category,
    ROUND(SUM(purchase_amount), 2) AS total_revenue,
    ROUND(AVG(review_rating), 2) AS avg_rating,
    COUNT(*) as sales_velocity
FROM customer_behavior.customer
GROUP BY item_purchased, category
HAVING AVG(review_rating) >= 4.0 -- Only push highly rated products
ORDER BY total_revenue DESC
LIMIT 10;