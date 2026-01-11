/* =========================================================
   INT — Customer First Purchase

   Grain        : 1 row per customer_unique_id
   Description  : Identify the first completed purchase timestamp per customer
   Source       : orders
   ========================================================= */

SELECT
    customer_unique_id,
    MIN(order_purchase_timestamp) AS first_order_ts
FROM orders 
WHERE order_status = 'delivered'
GROUP BY
     customer_unique_id;
