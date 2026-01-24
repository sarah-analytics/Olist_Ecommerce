/* =========================================================
   KPI #02 — Daily Revenue

   Type         : Base
   Description  : Track total revenue generated per day
   Numerator    : Total revenue
   Denominator  : Not applicable (absolute value)
   Grain        : 1 row per day
   Time Basis   : orders.order_purchase_timestamp
   Date Filter  : [start_ts, end_ts)
   Valid Orders : Orders with recorded payments
   Output       : order_date, daily_revenue
   Notes        : Revenue definition must remain consistent across all revenue KPIs
   ========================================================= */

WITH params AS (
    SELECT
        TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
        TIMESTAMP('2018-01-01 00:00:00') AS end_ts
)
SELECT
    DATE(o.order_purchase_timestamp) AS order_date,      -- day grain
    SUM(p.payment_value)            AS daily_revenue     -- total revenue per day
FROM orders AS o
JOIN order_payments AS p
  ON p.order_id = o.order_id
CROSS JOIN params AS prm
WHERE o.order_purchase_timestamp >= prm.start_ts
  AND o.order_purchase_timestamp <  prm.end_ts
GROUP BY
    DATE(o.order_purchase_timestamp)
ORDER BY
    order_date;
