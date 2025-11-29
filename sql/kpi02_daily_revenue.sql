/* KPI #02 — Daily Revenue
   Purpose: daily revenue */

SELECT
    DATE(o.order_purchase_timestamp) AS order_date,   -- date
    ROUND(SUM(p.payment_value), 2) AS daily_revenue   -- revenue
FROM orders AS o
JOIN order_payments AS p
      ON o.order_id = p.order_id
GROUP BY order_date
ORDER BY order_date;
