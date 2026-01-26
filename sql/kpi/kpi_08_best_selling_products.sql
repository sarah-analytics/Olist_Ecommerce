/* =========================================================
   KPI #08 — Best-selling Products

   Type         : Base
   Description  : Identify products with the highest sales volume
   Numerator    : Number of units sold
   Denominator  : Not applicable (absolute count)
   Grain        : 1 row per product
   Time Basis   : orders.order_purchase_timestamp
   Date Filter  : [start_ts, end_ts)
   Valid Orders : Completed (delivered) orders
   Output       : product_id, units_sold
   Notes        : Focuses on volume, not revenue
   ========================================================= */

WITH params AS (
  SELECT
    TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
    TIMESTAMP('2018-01-01 00:00:00') AS end_ts
)
SELECT
  oi.product_id,
  COUNT(*) AS units_sold
FROM orders AS o
JOIN order_items AS oi
  ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= (SELECT start_ts FROM params)
  AND o.order_purchase_timestamp <  (SELECT end_ts   FROM params)
GROUP BY
  oi.product_id
ORDER BY
  units_sold DESC;


