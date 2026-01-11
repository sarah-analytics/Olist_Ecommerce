/* =========================================================
   KPI #01 — Daily Orders

   Type         : Base
   Description  : Track the number of orders placed per day
   Numerator    : Count of distinct orders
   Denominator  : Not applicable (absolute count)
   Grain        : 1 row per day
   Time Basis   : orders.order_purchase_timestamp
   Date Filter  : [start_ts, end_ts)
   Valid Orders : All orders with valid order records
   Output       : order_date, daily_orders
   Notes        : Baseline volume KPI for overall business activity
   ========================================================= */

WITH params AS (
    SELECT
        TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
        TIMESTAMP('2018-01-01 00:00:00') AS end_ts
)

SELECT
    DATE(o.order_purchase_timestamp)      AS order_date,     -- day grain
    COUNT(DISTINCT o.order_id)            AS daily_orders    -- number of orders per day
FROM orders AS o
JOIN params AS prm
  ON o.order_purchase_timestamp >= prm.start_ts
 AND o.order_purchase_timestamp <  prm.end_ts
GROUP BY
    DATE(o.order_purchase_timestamp)
ORDER BY
    order_date;
