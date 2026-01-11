/* =========================================================
   INT — Customer First Purchase

   Grain        : 1 row per customer_unique_id
   Description  : Identify the first completed purchase timestamp per customer
   Source       : orders
   ========================================================= */

SELECT
    o.customer_unique_id,
    MIN(o.order_purchase_timestamp) AS first_order_ts
FROM orders AS o
WHERE o.order_status = 'delivered'
GROUP BY
    o.customer_unique_id;
