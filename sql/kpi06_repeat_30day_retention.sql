/* KPI #06 — 30-Day Repeat Retention
   Purpose: % of customers returning within 30 days of first purchase */

WITH first_purchase AS (
    SELECT
        customer_unique_id,
        MIN(order_purchase_timestamp) AS first_order_date
    FROM orders
    GROUP BY customer_unique_id
),
repeat_purchase AS (
    SELECT
        o.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS repeat_order_date
    FROM orders AS o
    JOIN first_purchase AS f
          ON o.customer_unique_id = f.customer_unique_id
         AND o.order_purchase_timestamp > f.first_order_date
         AND DATEDIFF(o.order_purchase_timestamp, f.first_order_date) <= 30
    GROUP BY o.customer_unique_id
)
SELECT
    (SELECT COUNT(*) FROM first_purchase) AS first_customers,
    (SELECT COUNT(*) FROM repeat_purchase) AS repeat_customers,
    ROUND(
        (SELECT COUNT(*) FROM repeat_purchase) * 100.0
        / (SELECT COUNT(*) FROM first_purchase),
        2
    ) AS retention;
