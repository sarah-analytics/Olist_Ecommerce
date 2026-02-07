/* =========================================================
   INT — Valid Orders

   Grain        : 1 row per order_id
   Definition   : Canonical set of delivered orders used across KPIs,
                  enriched with customer_unique_id via customers
   Source       : orders + customers
   ========================================================= */

CREATE TABLE int_valid_orders_tbl AS
SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    o.order_status,
    o.order_purchase_timestamp
FROM orders AS o
JOIN customers AS c
  ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered';
