/* =========================================================
   INT — Valid Orders

   Grain       : 1 row per order
   Definition  : Canonical set of completed orders used across KPIs
   Source      : orders
   ========================================================= */

SELECT
    customer_unique_id,
    order_purchase_timestamp
FROM orders
WHERE order_status = 'delivered';
