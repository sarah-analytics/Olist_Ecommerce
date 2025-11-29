/* KPI #01 — Daily Order Count
   Purpose: daily order volume */

SELECT
    DATE(order_purchase_timestamp) AS order_date,  -- date
    COUNT(*) AS order_count                        -- daily orders
FROM orders
GROUP BY order_date
ORDER BY order_date;

