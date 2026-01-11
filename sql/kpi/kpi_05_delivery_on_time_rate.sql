/* =========================================================
   KPI #05 — Delivery On-time Rate

   Type         : Derived
   Description  : Measure the proportion of orders delivered on or before the estimated date
   Numerator    : Count of on-time delivered orders
   Denominator  : Total delivered orders
   Grain        : 1 row (overall rate)
   Time Basis   : orders.order_delivered_customer_date
   Date Filter  : [start_ts, end_ts)
   Valid Orders : Delivered orders only
   Output       : on_time_rate_pct
   Notes        : Core operational reliability KPI
   ========================================================= */

WITH
params AS (
    SELECT
        TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
        TIMESTAMP('2018-01-01 00:00:00') AS end_ts
),
delivered_base AS (
    SELECT
        o.order_id,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date
    FROM orders AS o
    JOIN params AS prm
      ON o.order_delivered_customer_date >= prm.start_ts
     AND o.order_delivered_customer_date <  prm.end_ts
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)

SELECT
    SUM(
        CASE
            WHEN delivered_base.order_delivered_customer_date
                 <= delivered_base.order_estimated_delivery_date
            THEN 1 ELSE 0
        END
    ) / NULLIF(COUNT(*), 0) * 100.0 AS on_time_rate_pct
FROM delivered_base;
