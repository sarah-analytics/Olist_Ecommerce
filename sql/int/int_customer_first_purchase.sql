/* =========================================================
   INT — Customer First Purchase

   Grain        : 1 row per customer_unique_id
   Description  : Identify the first completed purchase timestamp per customer
   Source       : orders + customers
   ========================================================= */

SELECT
    c.customer_unique_id,
    MIN(o.order_purchase_timestamp) AS first_order_ts
FROM orders AS o
JOIN customers AS c
  ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY
    c.customer_unique_id;

